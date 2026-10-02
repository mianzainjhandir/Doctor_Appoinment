import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddDoctorView extends StatefulWidget {
  final VoidCallback? onSuccess;

  const AddDoctorView({super.key, this.onSuccess});

  @override
  State<AddDoctorView> createState() => _AddDoctorViewState();
}

class _AddDoctorViewState extends State<AddDoctorView> {
  final nameCtrl = TextEditingController();
  final specialtyCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final licenseCtrl = TextEditingController();
  final feeCtrl = TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    specialtyCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    licenseCtrl.dispose();
    feeCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveDoctor() async {
    if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter Full Name and Email',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('doctor').add({
        'fullName': nameCtrl.text.trim(),
        'specialty': specialtyCtrl.text.trim().isEmpty
            ? 'Cardiologist'
            : specialtyCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'licenseNumber': licenseCtrl.text.trim(),
        'fee': feeCtrl.text.trim(),
        'role': 'doctor',
        'createdAt': FieldValue.serverTimestamp(),
      });

      nameCtrl.clear();
      specialtyCtrl.clear();
      emailCtrl.clear();
      phoneCtrl.clear();
      licenseCtrl.clear();
      feeCtrl.clear();

      setState(() {
        isSaving = false;
      });

      Get.snackbar(
        'Success',
        'Doctor added successfully!',
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      if (widget.onSuccess != null) {
        widget.onSuccess!();
      }
    } catch (e) {
      setState(() {
        isSaving = false;
      });
      Get.snackbar(
        'Error',
        'Failed to add doctor: $e',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1_rounded,
                    color: Color(0xFF2563EB),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Doctor Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Register a new medical specialist to the platform',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Divider(color: Color(0xFFF1F5F9)),
            const SizedBox(height: 20),

            // Form Inputs
            _buildFormLabelField(
                'Full Name', 'e.g. Dr. Usman Ali', Icons.person_outline, nameCtrl),
            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _buildFormLabelField('Specialty', 'e.g. Cardiologist',
                      Icons.medical_services_outlined, specialtyCtrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFormLabelField('PMC License No.',
                      'e.g. PMC-98765', Icons.badge_outlined, licenseCtrl),
                ),
              ],
            ),
            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _buildFormLabelField('Email Address',
                      'doctor@healthai.com', Icons.email_outlined, emailCtrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFormLabelField('Phone Number',
                      '+92 300 1234567', Icons.phone_outlined, phoneCtrl),
                ),
              ],
            ),
            const SizedBox(height: 18),

            _buildFormLabelField('Consultation Fee', 'e.g. Rs. 2000',
                Icons.payments_outlined, feeCtrl),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 48,
              width: 200,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveDoctor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Save Doctor',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormLabelField(
      String label, String hint, IconData icon, TextEditingController ctrl) {
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
          controller: ctrl,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              borderSide:
                  const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
