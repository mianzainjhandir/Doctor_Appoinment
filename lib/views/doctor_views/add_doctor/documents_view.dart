import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddDoctorDocumentsView extends StatefulWidget {
  final Map<String, dynamic> doctorDataStep1And2;
  final VoidCallback onBack;
  final VoidCallback onSuccess;

  const AddDoctorDocumentsView({
    super.key,
    required this.doctorDataStep1And2,
    required this.onBack,
    required this.onSuccess,
  });

  @override
  State<AddDoctorDocumentsView> createState() => _AddDoctorDocumentsViewState();
}

class _AddDoctorDocumentsViewState extends State<AddDoctorDocumentsView> {
  final descriptionCtrl = TextEditingController();

  PlatformFile? _selectedImageFile;
  Uint8List? _selectedImageBytes;

  final List<String> allSpecialties = [
    'Cardiology',
    'Heart Surgery',
    'General Medicine',
    'Internal Medicine',
    'Diabetes Care',
    'Other',
  ];

  final Set<String> selectedSpecialties = {'Cardiology'};

  bool isDegreeUploaded = false;
  bool isExperienceUploaded = false;
  bool isSaving = false;

  Future<void> _pickProfileImage() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final PlatformFile file = result.files.first;
        final Uint8List? bytes = file.bytes;

        if (bytes != null) {
          setState(() {
            _selectedImageFile = file;
            _selectedImageBytes = bytes;
          });
          Get.snackbar(
            'Photo Selected',
            'Profile image (${file.name}) selected successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue.shade100,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Picker Notice',
        'Could not pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    descriptionCtrl.dispose();
    super.dispose();
  }

  void _toggleSpecialty(String specialty) {
    setState(() {
      if (selectedSpecialties.contains(specialty)) {
        if (selectedSpecialties.length > 1) {
          selectedSpecialties.remove(specialty);
        }
      } else {
        selectedSpecialties.add(specialty);
      }
    });
  }

  Future<void> _saveFinalDoctor() async {
    setState(() {
      isSaving = true;
    });

    try {
      // Base64 image string for storing directly in Firestore
      String profileImageBase64 = '';
      if (_selectedImageBytes != null) {
        profileImageBase64 =
            'data:image/png;base64,${base64Encode(_selectedImageBytes!)}';
      }

      // Combine Step 1, Step 2, and Step 3 data
      final Map<String, dynamic> completeDoctorData = {
        ...widget.doctorDataStep1And2,
        'profileImage': profileImageBase64,
        'shortDescription': descriptionCtrl.text.trim(),
        'selectedSpecialties': selectedSpecialties.toList(),
        'degreeUploaded': isDegreeUploaded,
        'experienceCertUploaded': isExperienceUploaded,
        'role': 'doctor',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save complete object in Firestore "doctor" collection
      await FirebaseFirestore.instance
          .collection('doctor')
          .add(completeDoctorData);

      setState(() {
        isSaving = false;
      });

      Get.snackbar(
        'Success',
        'Doctor profile created successfully!',
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      widget.onSuccess();
    } catch (e) {
      setState(() {
        isSaving = false;
      });
      Get.snackbar(
        'Error',
        'Failed to save doctor: $e',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Title
          Text(
            'Add Doctor - Profile & Documents',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 20),

          // Main Card Container
          Container(
            padding: const EdgeInsets.all(28),
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
                // SECTION 1: Upload Profile Photo
                Text(
                  'Upload Profile Photo',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: const Color(0xFFDBEAFE),
                      child: ClipOval(
                        child: _selectedImageBytes != null
                            ? Image.memory(
                                _selectedImageBytes!,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.person_rounded,
                                size: 42,
                                color: Color(0xFF94A3B8),
                              ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OutlinedButton(
                          onPressed: _pickProfileImage,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2563EB),
                            side: const BorderSide(color: Color(0xFFBFDBFE)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            _selectedImageFile != null ? 'Change Photo' : 'Upload Photo',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'JPG, PNG (Max 2MB)',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // SECTION 2: Short Description
                Text(
                  'Short Description',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: descriptionCtrl,
                  maxLines: 3,
                  style: GoogleFonts.poppins(
                      fontSize: 13.5, color: const Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: 'Write a short description about the doctor...',
                    hintStyle: GoogleFonts.poppins(
                        color: const Color(0xFF94A3B8), fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFFAFAFA),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
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
                      borderSide: const BorderSide(
                          color: Color(0xFF2563EB), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // SECTION 3: Specialties (Select multiple)
                Text(
                  'Specialties (Select multiple)',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: allSpecialties.map((specialty) {
                    final bool isSelected =
                        selectedSpecialties.contains(specialty);

                    return InkWell(
                      onTap: () => _toggleSpecialty(specialty),
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          specialty,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // SECTION 4: Documents Upload Box
                Text(
                  'Documents',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      // Document 1: Medical Degree & License
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.verified_user_outlined,
                              color: Color(0xFF2563EB),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Medical Degree (PDF)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                                Text(
                                  'License / PMC (PDF)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                isDegreeUploaded = true;
                              });
                              Get.snackbar('Document Upload',
                                  'Degree document attached',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.blue.shade100);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2563EB),
                              side: const BorderSide(
                                  color: Color(0xFFBFDBFE)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                            icon: Icon(
                              isDegreeUploaded
                                  ? Icons.check_circle_rounded
                                  : Icons.upload_outlined,
                              size: 16,
                              color: isDegreeUploaded
                                  ? Colors.green
                                  : const Color(0xFF2563EB),
                            ),
                            label: Text(
                              isDegreeUploaded ? 'Uploaded' : 'Upload',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: Color(0xFFE2E8F0)),
                      ),

                      // Document 2: Experience Certificate
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.badge_outlined,
                              color: Color(0xFF2563EB),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Experience Certificate (PDF)',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                isExperienceUploaded = true;
                              });
                              Get.snackbar('Document Upload',
                                  'Experience certificate attached',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.blue.shade100);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2563EB),
                              side: const BorderSide(
                                  color: Color(0xFFBFDBFE)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                            icon: Icon(
                              isExperienceUploaded
                                  ? Icons.check_circle_rounded
                                  : Icons.upload_outlined,
                              size: 16,
                              color: isExperienceUploaded
                                  ? Colors.green
                                  : const Color(0xFF2563EB),
                            ),
                            label: Text(
                              isExperienceUploaded ? 'Uploaded' : 'Upload',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Bottom Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Back Button
              OutlinedButton.icon(
                onPressed: widget.onBack,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF475569),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 26, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: Text(
                  'Back',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Save Doctor Final Button
              ElevatedButton(
                onPressed: isSaving ? null : _saveFinalDoctor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Save Doctor',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
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
