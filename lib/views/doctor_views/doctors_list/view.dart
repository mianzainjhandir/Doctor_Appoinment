import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorsListView extends StatefulWidget {
  final VoidCallback onAddDoctorPressed;

  const DoctorsListView({
    super.key,
    required this.onAddDoctorPressed,
  });

  @override
  State<DoctorsListView> createState() => _DoctorsListViewState();
}

class _DoctorsListViewState extends State<DoctorsListView> {
  final TextEditingController searchCtrl = TextEditingController();
  String selectedSpecialization = 'All Specializations';
  String selectedStatus = 'All Status';

  final List<String> specializationFilters = [
    'All Specializations',
    'Cardiologist',
    'Dermatologist',
    'General Physician',
    'Pediatrician',
    'Neurologist',
    'Orthopedic Surgeon',
  ];

  final List<String> statusFilters = [
    'All Status',
    'Active',
    'Inactive',
  ];

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  // Delete Doctor function
  Future<void> _deleteDoctor(String docId, String name) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Delete Doctor',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: const Color(0xFF0F172A),
              ),
            ),
            content: Text(
              'Are you sure you want to delete "$name" from the directory? This action cannot be undone.',
              style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF475569)),
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
                child: Text('Delete', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await FirebaseFirestore.instance.collection('doctor').doc(docId).delete();
        Get.snackbar(
          'Deleted',
          '$name has been removed successfully',
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete: $e',
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  // Edit Doctor Dialog Function
  void _editDoctorDialog(String docId, Map<String, dynamic> data) {
    final nameEditCtrl = TextEditingController(text: data['fullName'] ?? '');
    final specEditCtrl = TextEditingController(text: data['specialty'] ?? '');
    final expEditCtrl = TextEditingController(text: data['experience'] ?? '');
    final feeEditCtrl = TextEditingController(text: data['fee'] ?? '');
    String currentStatus = data['status'] ?? 'Active';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Edit Doctor Details',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color(0xFF0F172A),
                ),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDialogInput('Full Name', nameEditCtrl),
                      const SizedBox(height: 12),
                      _buildDialogInput('Specialization', specEditCtrl),
                      const SizedBox(height: 12),
                      _buildDialogInput('Experience (Years)', expEditCtrl),
                      const SizedBox(height: 12),
                      _buildDialogInput('Consultation Fee (PKR)', feeEditCtrl),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: currentStatus,
                        items: ['Active', 'Inactive'].map((s) {
                          return DropdownMenuItem(value: s, child: Text(s));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              currentStatus = val;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: GoogleFonts.poppins()),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('doctor')
                          .doc(docId)
                          .update({
                        'fullName': nameEditCtrl.text.trim(),
                        'specialty': specEditCtrl.text.trim(),
                        'experience': expEditCtrl.text.trim(),
                        'fee': feeEditCtrl.text.trim(),
                        'status': currentStatus,
                      });

                      if (context.mounted) {
                        Navigator.pop(context);
                      }

                      Get.snackbar(
                        'Success',
                        'Doctor profile updated successfully',
                        backgroundColor: Colors.green.shade600,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    } catch (e) {
                      Get.snackbar('Error', 'Update failed: $e',
                          backgroundColor: Colors.red.shade400,
                          colorText: Colors.white);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Save Changes', style: GoogleFonts.poppins()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(fontSize: 13.5),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Title
          Text(
            'Doctors List (Admin)',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Manage all doctors, edit details, activate or deactivate accounts.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),

          // Search & Filter Action Bar
          Row(
            children: [
              // Search Input
              Expanded(
                flex: 4,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: searchCtrl,
                    onChanged: (val) {
                      setState(() {});
                    },
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search by name, specialization, or email...',
                      hintStyle: GoogleFonts.poppins(
                        color: const Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFF64748B), size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Filter 1: Specialization Dropdown
              Expanded(
                flex: 2,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedSpecialization,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Color(0xFF64748B), size: 18),
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: const Color(0xFF334155)),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedSpecialization = val;
                          });
                        }
                      },
                      items: specializationFilters.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s));
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Filter 2: Status Dropdown
              Expanded(
                flex: 2,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedStatus,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Color(0xFF64748B), size: 18),
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: const Color(0xFF334155)),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedStatus = val;
                          });
                        }
                      },
                      items: statusFilters.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s));
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Right Button: Add Doctor
              ElevatedButton.icon(
                onPressed: widget.onAddDoctorPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  height: 44,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  'Add Doctor',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main Data Table Container
          Expanded(
            child: Container(
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
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('doctor')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF2563EB)),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.medical_services_outlined,
                              size: 50, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 12),
                          Text(
                            'No Doctors Found',
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

                  // Filter logic
                  final docs = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final String name =
                        (data['fullName'] ?? '').toString().toLowerCase();
                    final String spec =
                        (data['specialty'] ?? '').toString().toLowerCase();
                    final String email =
                        (data['email'] ?? '').toString().toLowerCase();
                    final String status = data['status'] ?? 'Active';

                    final String query = searchCtrl.text.toLowerCase().trim();

                    bool matchesSearch = query.isEmpty ||
                        name.contains(query) ||
                        spec.contains(query) ||
                        email.contains(query);

                    bool matchesSpec = selectedSpecialization ==
                            'All Specializations' ||
                        spec.contains(selectedSpecialization.toLowerCase());

                    bool matchesStatus =
                        selectedStatus == 'All Status' || status == selectedStatus;

                    return matchesSearch && matchesSpec && matchesStatus;
                  }).toList();

                  return Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Text('#',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF475569))),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text('Doctor',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF475569))),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text('Specialization',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF475569))),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('Experience',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF475569))),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('Fee (PKR)',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF475569))),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('Status',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF475569))),
                            ),
                            const SizedBox(
                              width: 90,
                              child: Text('Actions',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF475569))),
                            ),
                          ],
                        ),
                      ),

                      // Table Body List
                      Expanded(
                        child: ListView.separated(
                          itemCount: docs.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final String docId = doc.id;

                            final String? profileImg = data['profileImage'];
                            final String name = data['fullName'] ?? 'Dr. Doctor';
                            final String spec =
                                data['specialty'] ?? 'Cardiologist';
                            final String exp = data['experience'] ?? '5';
                            final String fee = data['fee'] ?? '1500';
                            final String status = data['status'] ?? 'Active';
                            final bool isActive = status == 'Active';

                            Widget avatarChild;
                            if (profileImg != null &&
                                profileImg.isNotEmpty &&
                                profileImg.contains('base64,')) {
                              try {
                                final String cleanBase64 =
                                    profileImg.split('base64,').last;
                                final Uint8List bytes =
                                    base64Decode(cleanBase64);
                                avatarChild = Image.memory(
                                  bytes,
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.cover,
                                );
                              } catch (e) {
                                avatarChild = const Icon(Icons.person_rounded,
                                    size: 20, color: Color(0xFF2563EB));
                              }
                            } else {
                              avatarChild = const Icon(Icons.person_rounded,
                                  size: 20, color: Color(0xFF2563EB));
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              child: Row(
                                children: [
                                  // Index #
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      '${index + 1}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),

                                  // Doctor Profile
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor:
                                              const Color(0xFFDBEAFE),
                                          child: ClipOval(child: avatarChild),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF0F172A),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Specialization
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      spec,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: const Color(0xFF334155),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  // Experience
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      exp.contains('Years')
                                          ? exp
                                          : '$exp Years',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: const Color(0xFF334155),
                                      ),
                                    ),
                                  ),

                                  // Fee (PKR)
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      fee,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF334155),
                                      ),
                                    ),
                                  ),

                                  // Status Badge
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? const Color(0xFFDCFCE7)
                                              : const Color(0xFFFEE2E2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          isActive ? 'Active' : 'Inactive',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: isActive
                                                ? const Color(0xFF16A34A)
                                                : const Color(0xFFDC2626),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Actions: Edit & Delete
                                  SizedBox(
                                    width: 90,
                                    child: Row(
                                      children: [
                                        // Edit Button
                                        InkWell(
                                          onTap: () =>
                                              _editDoctorDialog(docId, data),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEFF6FF),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.edit_outlined,
                                              size: 16,
                                              color: Color(0xFF2563EB),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Delete Button
                                        InkWell(
                                          onTap: () =>
                                              _deleteDoctor(docId, name),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFEE2E2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.delete_outline_rounded,
                                              size: 16,
                                              color: Color(0xFFDC2626),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Footer Pagination Bar
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          border: Border(
                            top: BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Showing 1 to ${docs.length} of ${docs.length} doctors',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const Spacer(),
                            // Pagination Buttons
                            Row(
                              children: [
                                _buildPageBtn('<', false),
                                const SizedBox(width: 6),
                                _buildPageBtn('1', true),
                                const SizedBox(width: 6),
                                _buildPageBtn('2', false),
                                const SizedBox(width: 6),
                                _buildPageBtn('>', false),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageBtn(String text, bool isActive) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2563EB) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : const Color(0xFF475569),
        ),
      ),
    );
  }
}
