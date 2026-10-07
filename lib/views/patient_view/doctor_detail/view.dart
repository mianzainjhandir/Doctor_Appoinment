import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorDetailView extends StatefulWidget {
  final Map<String, dynamic> doctorData;
  final VoidCallback onBack;
  final VoidCallback? onBookAppointment;

  const DoctorDetailView({
    super.key,
    required this.doctorData,
    required this.onBack,
    this.onBookAppointment,
  });

  @override
  State<DoctorDetailView> createState() => _DoctorDetailViewState();
}

class _DoctorDetailViewState extends State<DoctorDetailView> {
  int activeTab = 0; // 0: About, 1: Reviews, 2: Education, 3: Availability

  final List<String> tabTitles = [
    'About',
    'Reviews',
    'Education',
    'Availability'
  ];

  @override
  Widget build(BuildContext context) {
    final data = widget.doctorData;

    final String? profileImgBase64 = data['profileImage'];
    final String name = data['fullName'] ?? 'Dr. Ayesha Khan';
    final String spec = data['specialty'] ?? 'Cardiologist';
    final String qual = data['qualification'] ?? 'MBBS, FCPS';
    final String exp = data['experience'] ?? '10+';
    final String fee = data['fee'] ?? '1,500';
    final String about = data['shortDescription'] ??
        data['about'] ??
        '$name is a highly qualified $spec with over $exp years of experience in treating patients. Known for patient-centric care and modern treatment methods.';

    Widget avatarWidget;
    if (profileImgBase64 != null &&
        profileImgBase64.isNotEmpty &&
        profileImgBase64.contains('base64,')) {
      try {
        final String cleanBase64 = profileImgBase64.split('base64,').last;
        final Uint8List bytes = base64Decode(cleanBase64);
        avatarWidget = Image.memory(
          bytes,
          width: 140,
          height: 140,
          fit: BoxFit.cover,
        );
      } catch (e) {
        avatarWidget = const Icon(Icons.person_rounded,
            size: 80, color: Color(0xFF2563EB));
      }
    } else {
      avatarWidget = const Icon(Icons.person_rounded,
          size: 80, color: Color(0xFF2563EB));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button
          InkWell(
            onTap: widget.onBack,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back,
                      size: 18, color: Color(0xFF2563EB)),
                  const SizedBox(width: 6),
                  Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Top Section Layout (Main Info Card + Booking Action Card)
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 850;

              Widget profileCard = Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                    // Avatar Column
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: const Color(0xFFDBEAFE),
                          child: ClipOval(child: avatarWidget),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$exp Years Experience',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '4.8 Doctor',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 32),

                    // Middle Info Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified_rounded,
                                color: Color(0xFF2563EB),
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            spec,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$qual  |  $exp Years Experience',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Rating & Badges
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '4.8 ',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '(256 reviews)',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              _buildPillBadge('Verified Doctor', Colors.green),
                              const SizedBox(width: 10),
                              _buildPillBadge('Available Today', Colors.green),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Text(
                            'Specialist in $spec with a focus on preventive healthcare and patient management.',
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              color: const Color(0xFF475569),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Specialty Tags
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildTag(spec),
                              _buildTag('Heart Health'),
                              _buildTag('Preventive Care'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 12),

                          // Experience & Hospital List
                          Row(
                            children: [
                              const Icon(Icons.medical_services_outlined,
                                  size: 18, color: Color(0xFF2563EB)),
                              const SizedBox(width: 10),
                              Text(
                                'Experience: ',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF334155),
                                ),
                              ),
                              Text(
                                '$exp Years',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.local_hospital_outlined,
                                  size: 18, color: Color(0xFF2563EB)),
                              const SizedBox(width: 10),
                              Text(
                                'Hospital: ',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF334155),
                                ),
                              ),
                              Text(
                                'Lahore General Hospital',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 18, color: Color(0xFF2563EB)),
                              const SizedBox(width: 10),
                              Text(
                                'Location: ',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF334155),
                                ),
                              ),
                              Text(
                                'Lahore, Pakistan',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              Widget bookingActionCard = Container(
                width: 280,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rs. $fee',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Consultation Fee',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Book Appointment Button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.onBookAppointment != null) {
                            widget.onBookAppointment!();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Book Appointment',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Chat with Doctor Button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.snackbar(
                            'Chat',
                            'Starting chat session with $name...',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.blue.shade100,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          side: const BorderSide(color: Color(0xFFBFDBFE)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.chat_bubble_outline_rounded,
                            size: 18),
                        label: Text(
                          'Chat with Doctor',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: profileCard),
                    const SizedBox(width: 24),
                    bookingActionCard,
                  ],
                );
              } else {
                return Column(
                  children: [
                    profileCard,
                    const SizedBox(height: 20),
                    bookingActionCard,
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 32),

          // Bottom Tabs Header (About, Reviews, Education, Availability)
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
              children: List.generate(tabTitles.length, (index) {
                final bool isSelected = activeTab == index;
                return InkWell(
                  onTap: () {
                    setState(() {
                      activeTab = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Text(
                      tabTitles[index],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),

          // Tab Content Area
          _buildTabContent(about, spec, exp),
        ],
      ),
    );
  }

  Widget _buildTabContent(String aboutText, String spec, String exp) {
    if (activeTab == 0) {
      // ABOUT TAB
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Doctor',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            aboutText,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF475569),
              height: 1.6,
            ),
          ),
        ],
      );
    } else if (activeTab == 1) {
      // REVIEWS TAB
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient Reviews',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          _buildReviewCard('Usman R.', '⭐ 5.0',
              'Excellent experience with the doctor. Very attentive and caring.'),
          const SizedBox(height: 12),
          _buildReviewCard('Fatima A.', '⭐ 4.8',
              'Very knowledgeable specialist. Answered all my questions clearly.'),
        ],
      );
    } else if (activeTab == 2) {
      // EDUCATION TAB
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Education & Qualifications',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Text('• MBBS - King Edward Medical University',
              style: GoogleFonts.poppins(fontSize: 13.5, color: const Color(0xFF334155))),
          const SizedBox(height: 6),
          Text('• FCPS ($spec) - College of Physicians & Surgeons',
              style: GoogleFonts.poppins(fontSize: 13.5, color: const Color(0xFF334155))),
        ],
      );
    } else {
      // AVAILABILITY TAB
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Working Hours & Availability',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Text('• Monday - Friday: 09:00 AM - 05:00 PM',
              style: GoogleFonts.poppins(fontSize: 13.5, color: const Color(0xFF334155))),
          const SizedBox(height: 6),
          Text('• Saturday: 10:00 AM - 02:00 PM',
              style: GoogleFonts.poppins(fontSize: 13.5, color: const Color(0xFF334155))),
        ],
      );
    }
  }

  Widget _buildReviewCard(String author, String rating, String comment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(author,
                  style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A))),
              Text(rating,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade800)),
            ],
          ),
          const SizedBox(height: 6),
          Text(comment,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildPillBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF16A34A)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2563EB),
        ),
      ),
    );
  }
}
