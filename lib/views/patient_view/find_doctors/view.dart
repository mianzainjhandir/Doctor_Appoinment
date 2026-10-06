import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FindDoctorsView extends StatefulWidget {
  const FindDoctorsView({super.key});

  @override
  State<FindDoctorsView> createState() => _FindDoctorsViewState();
}

class _FindDoctorsViewState extends State<FindDoctorsView> {
  // Search & Filters State
  final TextEditingController searchCtrl = TextEditingController();

  String selectedSpecialization = 'All Specializations';
  String selectedLocation = 'Lahore, Pakistan';
  RangeValues feeRange = const RangeValues(500, 5000);

  bool isAvailableToday = false;
  bool isAvailableTomorrow = false;
  bool isAvailableThisWeek = false;

  final List<String> specializations = [
    'All Specializations',
    'Cardiologist',
    'Dermatologist',
    'General Physician',
    'Pediatrician',
    'Neurologist',
    'Orthopedic Surgeon',
    'Gynecologist',
  ];

  final List<String> locations = [
    'All Locations',
    'Lahore, Pakistan',
    'Karachi, Pakistan',
    'Islamabad, Pakistan',
    'Rawalpindi, Pakistan',
  ];

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      searchCtrl.clear();
      selectedSpecialization = 'All Specializations';
      selectedLocation = 'Lahore, Pakistan';
      feeRange = const RangeValues(500, 5000);
      isAvailableToday = false;
      isAvailableTomorrow = false;
      isAvailableThisWeek = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Layout: Left Filters + Right Doctors List
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 850;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Filters Sidebar Card
                    SizedBox(
                      width: 280,
                      child: _buildFiltersCard(),
                    ),
                    const SizedBox(width: 24),

                    // Right Doctors List & Search
                    Expanded(
                      child: _buildRightDoctorSection(),
                    ),
                  ],
                );
              } else {
                // Mobile/Narrow View
                return Column(
                  children: [
                    _buildFiltersCard(),
                    const SizedBox(height: 24),
                    _buildRightDoctorSection(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavLink(String label, bool isSelected) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 13.5,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
      ),
    );
  }

  // ================= LEFT FILTERS SIDEBAR CARD =================
  Widget _buildFiltersCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              InkWell(
                onTap: _resetFilters,
                child: Text(
                  'Reset',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 1. Specialization
          Text(
            'Specialization',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedSpecialization,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down,
                color: Color(0xFF64748B), size: 18),
            style: GoogleFonts.poppins(
                fontSize: 13, color: const Color(0xFF0F172A)),
            decoration: _filterInputDecoration(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  selectedSpecialization = val;
                });
              }
            },
            items: specializations.map((s) {
              return DropdownMenuItem(value: s, child: Text(s));
            }).toList(),
          ),
          const SizedBox(height: 20),

          // 2. Location
          Text(
            'Location',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedLocation,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down,
                color: Color(0xFF64748B), size: 18),
            style: GoogleFonts.poppins(
                fontSize: 13, color: const Color(0xFF0F172A)),
            decoration: _filterInputDecoration(
              prefixIcon: Icons.location_on_outlined,
            ),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  selectedLocation = val;
                });
              }
            },
            items: locations.map((loc) {
              return DropdownMenuItem(value: loc, child: Text(loc));
            }).toList(),
          ),
          const SizedBox(height: 20),

          // 3. Fee Range
          Text(
            'Fee Range',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 4),
          RangeSlider(
            values: feeRange,
            min: 500,
            max: 10000,
            divisions: 19,
            activeColor: const Color(0xFF2563EB),
            inactiveColor: const Color(0xFFE2E8F0),
            labels: RangeLabels(
              'Rs. ${feeRange.start.round()}',
              'Rs. ${feeRange.end.round()}',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                feeRange = values;
              });
            },
          ),
          Text(
            'Rs. ${feeRange.start.round()} — Rs. ${feeRange.end.round()}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),

          // 4. Availability Checkboxes
          Text(
            'Availability',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          _buildCheckbox('Today', isAvailableToday, (val) {
            setState(() {
              isAvailableToday = val ?? false;
            });
          }),
          _buildCheckbox('Tomorrow', isAvailableTomorrow, (val) {
            setState(() {
              isAvailableTomorrow = val ?? false;
            });
          }),
          _buildCheckbox('This Week', isAvailableThisWeek, (val) {
            setState(() {
              isAvailableThisWeek = val ?? false;
            });
          }),
          const SizedBox(height: 24),

          // Apply Filters Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        SizedBox(
          height: 32,
          width: 24,
          child: Checkbox(
            value: value,
            activeColor: const Color(0xFF2563EB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  InputDecoration _filterInputDecoration({IconData? prefixIcon}) {
    return InputDecoration(
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: const Color(0xFF2563EB), size: 18)
          : null,
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }

  // ================= RIGHT DOCTORS SEARCH & LIST =================
  Widget _buildRightDoctorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Header
        Text(
          'Find the Right Doctor for You',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Search from our verified doctors and book your appointment easily.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 20),

        // Live Search Bar
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: searchCtrl,
            onChanged: (val) {
              setState(() {});
            },
            style: GoogleFonts.poppins(fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'Search by name, specialty...',
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFF94A3B8),
                fontSize: 13.5,
              ),
              prefixIcon: const Icon(Icons.search,
                  color: Color(0xFF64748B), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // StreamBuilder connected to Firestore "doctor" collection
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('doctor').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.person_search_outlined,
                        size: 54, color: Color(0xFF94A3B8)),
                    const SizedBox(height: 12),
                    Text(
                      'No Verified Doctors Found',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              );
            }

            final allDocs = snapshot.data!.docs;

            // Live Filters Logic
            final doctors = allDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final String name =
                  (data['fullName'] ?? '').toString().toLowerCase();
              final String spec =
                  (data['specialty'] ?? '').toString().toLowerCase();
              final double fee =
                  double.tryParse((data['fee'] ?? '1500').toString()) ?? 1500;

              final String query = searchCtrl.text.toLowerCase().trim();

              bool matchesQuery =
                  query.isEmpty || name.contains(query) || spec.contains(query);

              bool matchesSpec = selectedSpecialization ==
                      'All Specializations' ||
                  spec.contains(selectedSpecialization.toLowerCase());

              bool matchesFee =
                  fee >= feeRange.start && fee <= feeRange.end;

              return matchesQuery && matchesSpec && matchesFee;
            }).toList();

            if (doctors.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Text(
                    'No doctors match your filter criteria.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: doctors.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final data = doctors[index].data() as Map<String, dynamic>;
                return _buildDoctorCard(context, data);
              },
            );
          },
        ),
      ],
    );
  }

  // ================= DOCTOR CARD ITEM =================
  Widget _buildDoctorCard(BuildContext context, Map<String, dynamic> data) {
    final String? profileImgBase64 = data['profileImage'];
    final String name = data['fullName'] ?? 'Dr. Ayesha Khan';
    final String spec = data['specialty'] ?? 'Cardiologist';
    final String qual = data['qualification'] ?? 'MBBS, FCPS';
    final String fee = data['fee'] ?? '1,500';

    Widget avatarWidget;
    if (profileImgBase64 != null &&
        profileImgBase64.isNotEmpty &&
        profileImgBase64.contains('base64,')) {
      try {
        final String cleanBase64 = profileImgBase64.split('base64,').last;
        final Uint8List bytes = base64Decode(cleanBase64);
        avatarWidget = Image.memory(
          bytes,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        );
      } catch (e) {
        avatarWidget = const Icon(Icons.person_rounded,
            size: 44, color: Color(0xFF2563EB));
      }
    } else {
      avatarWidget = const Icon(Icons.person_rounded,
          size: 44, color: Color(0xFF2563EB));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFDBEAFE),
            child: ClipOval(child: avatarWidget),
          ),
          const SizedBox(width: 20),

          // Doctor Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  spec,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2563EB),
                  ),
                ),
                Text(
                  qual,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 10),

                // Rating & Availability Pill
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '4.8 ',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '(214 reviews)',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Available Today Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              size: 12, color: Color(0xFF16A34A)),
                          const SizedBox(width: 4),
                          Text(
                            'Available Today',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Fee & Book Appointment Button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs. $fee',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 36),

              // Book Appointment Button
              ElevatedButton(
                onPressed: () {
                  Get.snackbar(
                    'Booking',
                    'Opening appointment booking for $name...',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.blue.shade100,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Book Appointment',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
