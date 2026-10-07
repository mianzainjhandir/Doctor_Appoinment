import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../home/view.dart';

class PatientProfileView extends StatefulWidget {
  const PatientProfileView({super.key});

  @override
  State<PatientProfileView> createState() => _PatientProfileViewState();
}

class _PatientProfileViewState extends State<PatientProfileView> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();

  bool isEditing = false;
  bool isLoading = true;
  bool isSaving = false;

  Uint8List? newAvatarBytes;
  String? profileImageBase64;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    locationCtrl.dispose();
    super.dispose();
  }

  // Load Patient Profile Data from Firebase
  Future<void> _loadPatientData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        emailCtrl.text = user.email ?? '';
        nameCtrl.text = user.displayName ?? 'Zain Ul Abedine';

        // Fetch additional fields from Firestore "patient" collection
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('patient')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['fullName'] != null && data['fullName'].toString().isNotEmpty) {
            nameCtrl.text = data['fullName'];
          }
          phoneCtrl.text = data['phoneNumber'] ?? '+92 300 1234567';
          locationCtrl.text = data['location'] ?? 'Lahore, Pakistan';
          profileImageBase64 = data['profileImage'];
        } else {
          phoneCtrl.text = '+92 300 1234567';
          locationCtrl.text = 'Lahore, Pakistan';
        }
      }
    } catch (e) {
      // Fallback defaults
      phoneCtrl.text = '+92 300 1234567';
      locationCtrl.text = 'Lahore, Pakistan';
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Pick Profile Avatar Photo
  Future<void> _pickAvatarPhoto() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final Uint8List? bytes = result.files.first.bytes;
        if (bytes != null) {
          setState(() {
            newAvatarBytes = bytes;
            profileImageBase64 =
                'data:image/png;base64,${base64Encode(bytes)}';
          });
          Get.snackbar(
            'Photo Updated',
            'New profile picture selected!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue.shade100,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Picker Notice',
        'Could not pick photo: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }

  // Save Updated Profile to Firebase
  Future<void> _saveProfile() async {
    setState(() {
      isSaving = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // 1. Update Firebase Auth displayName
        await user.updateDisplayName(nameCtrl.text.trim());

        // 2. Update Firestore "patient" document
        final Map<String, dynamic> updateData = {
          'fullName': nameCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
          'phoneNumber': phoneCtrl.text.trim(),
          'location': locationCtrl.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (profileImageBase64 != null) {
          updateData['profileImage'] = profileImageBase64;
        }

        await FirebaseFirestore.instance
            .collection('patient')
            .doc(user.uid)
            .set(updateData, SetOptions(merge: true));

        setState(() {
          isSaving = false;
          isEditing = false;
        });

        Get.snackbar(
          'Profile Saved 🎉',
          'Your personal information has been updated.',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      setState(() {
        isSaving = false;
      });
      Get.snackbar(
        'Save Error',
        'Failed to save profile: $e',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Change Password Prompt
  Future<void> _changePassword() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user?.email != null) {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: user!.email!);
        Get.snackbar(
          'Reset Link Sent',
          'Password reset link has been sent to ${user.email}',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Could not send reset link: $e',
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: Color(0xFF2563EB)),
        ),
      );
    }

    Widget avatarWidget;
    if (newAvatarBytes != null) {
      avatarWidget = Image.memory(
        newAvatarBytes!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else if (profileImageBase64 != null &&
        profileImageBase64!.isNotEmpty &&
        profileImageBase64!.contains('base64,')) {
      try {
        final String cleanBase64 = profileImageBase64!.split('base64,').last;
        final Uint8List bytes = base64Decode(cleanBase64);
        avatarWidget = Image.memory(
          bytes,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        );
      } catch (e) {
        avatarWidget = const Icon(Icons.person_rounded,
            size: 50, color: Color(0xFF2563EB));
      }
    } else {
      avatarWidget = const Icon(Icons.person_rounded,
          size: 50, color: Color(0xFF2563EB));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Personal Information Header
          Text(
            'Personal Information',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),

          // Main Card: Profile Photo + Form Fields
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Row
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: const Color(0xFFDBEAFE),
                          child: ClipOval(child: avatarWidget),
                        ),
                        if (isEditing)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: InkWell(
                              onTap: _pickAvatarPhoto,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2563EB),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt_rounded,
                                    color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 20),

                    // User Name & Email Summary
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nameCtrl.text.isEmpty
                                ? 'Zain Ul Abedine'
                                : nameCtrl.text,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            emailCtrl.text.isEmpty
                                ? 'zain@example.com'
                                : emailCtrl.text,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () {
                              if (!isEditing) {
                                setState(() {
                                  isEditing = true;
                                });
                              }
                              _pickAvatarPhoto();
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Edit Profile',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Edit / Save Profile Action Button
                    OutlinedButton(
                      onPressed: isSaving
                          ? null
                          : () {
                              if (isEditing) {
                                _saveProfile();
                              } else {
                                setState(() {
                                  isEditing = true;
                                });
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                        side: const BorderSide(color: Color(0xFFBFDBFE)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF2563EB),
                              ),
                            )
                          : Text(
                              isEditing ? 'Save Changes' : 'Edit Profile',
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: Color(0xFFF1F5F9)),
                const SizedBox(height: 16),

                // Form Fields (2 Columns Layout)
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWide = constraints.maxWidth > 600;

                    if (isWide) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormField('Full Name', nameCtrl,
                                    enabled: isEditing),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildFormField('Email', emailCtrl,
                                    enabled: false), // Email non-editable
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormField(
                                    'Phone Number', phoneCtrl,
                                    enabled: isEditing),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildFormField('Location', locationCtrl,
                                    enabled: isEditing),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildFormField('Full Name', nameCtrl,
                              enabled: isEditing),
                          const SizedBox(height: 14),
                          _buildFormField('Email', emailCtrl, enabled: false),
                          const SizedBox(height: 14),
                          _buildFormField('Phone Number', phoneCtrl,
                              enabled: isEditing),
                          const SizedBox(height: 14),
                          _buildFormField('Location', locationCtrl,
                              enabled: isEditing),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Section 2: Account Settings Card
          Text(
            'Account Settings',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Change Password',
                  onTap: _changePassword,
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildSettingsTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Notification Preferences',
                  onTap: () {
                    Get.snackbar('Notifications',
                        'Notifications enabled for appointments',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.blue.shade100);
                  },
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildSettingsTile(
                  icon: Icons.security_outlined,
                  title: 'Privacy & Security',
                  onTap: () {
                    Get.snackbar(
                        'Privacy', 'Your health data is 100% encrypted',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.blue.shade100);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Section 3: Log Out Red Outlined Card Button
          InkWell(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Get.offAll(() => const HomeScreen());
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded,
                      color: Color(0xFFDC2626), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Log Out',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller,
      {required bool enabled}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            color: enabled ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor:
                enabled ? const Color(0xFFFAFAFA) : const Color(0xFFF1F5F9),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF2563EB), size: 18),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF334155),
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8), size: 20),
          ],
        ),
      ),
    );
  }
}
