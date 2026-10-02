import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'availability_view.dart';

class AddDoctorView extends StatefulWidget {
  final VoidCallback? onSuccess;

  const AddDoctorView({super.key, this.onSuccess});

  @override
  State<AddDoctorView> createState() => _AddDoctorViewState();
}

class _AddDoctorViewState extends State<AddDoctorView> {
  int currentStep = 1;

  // Step 1 Data Controllers
  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final expCtrl = TextEditingController();
  String? selectedGender;

  String? selectedSpecialization;
  final qualificationCtrl = TextEditingController();
  final licenseCtrl = TextEditingController();
  final aboutCtrl = TextEditingController();

  Map<String, dynamic> step1Data = {};

  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> specializationOptions = [
    'Cardiologist',
    'Neurologist',
    'Pediatrician',
    'Dermatologist',
    'Orthopedic Surgeon',
    'General Physician',
    'Gynecologist',
    'Psychiatrist',
  ];

  @override
  void dispose() {
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    dobCtrl.dispose();
    expCtrl.dispose();
    qualificationCtrl.dispose();
    licenseCtrl.dispose();
    aboutCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        dobCtrl.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _goToNextStep() {
    if (fullNameCtrl.text.trim().isEmpty) {
      Get.snackbar('Required', 'Please enter Full Name',
          backgroundColor: Colors.red.shade400, colorText: Colors.white);
      return;
    }
    if (emailCtrl.text.trim().isEmpty) {
      Get.snackbar('Required', 'Please enter Email Address',
          backgroundColor: Colors.red.shade400, colorText: Colors.white);
      return;
    }

    step1Data = {
      'fullName': fullNameCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
      'gender': selectedGender ?? 'Male',
      'dob': dobCtrl.text.trim(),
      'experience': expCtrl.text.trim(),
      'specialty': selectedSpecialization ?? 'General Physician',
      'qualification': qualificationCtrl.text.trim(),
      'licenseNumber': licenseCtrl.text.trim(),
      'about': aboutCtrl.text.trim(),
    };

    setState(() {
      currentStep = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentStep == 2) {
      return AddDoctorAvailabilityView(
        doctorDataStep1: step1Data,
        onBack: () {
          setState(() {
            currentStep = 1;
          });
        },
        onSuccess: () {
          if (widget.onSuccess != null) {
            widget.onSuccess!();
          }
        },
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Title
          Text(
            'Add Doctor',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Fill in the details to add a new doctor to the platform.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),

          // Main White Form Container
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
                // SECTION 1: Personal Information
                Text(
                  'Personal Information',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                const SizedBox(height: 18),

                // Row 1: Full Name & Email Address
                Row(
                  children: [
                    Expanded(
                      child: _buildFieldWithLabel(
                        label: 'Full Name *',
                        hint: 'Dr. John Smith',
                        controller: fullNameCtrl,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildFieldWithLabel(
                        label: 'Email Address *',
                        hint: 'doctor@hospital.com',
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Row 2: Phone Number & Gender
                Row(
                  children: [
                    Expanded(
                      child: _buildPhoneField(),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Gender *',
                        hint: 'Select Gender',
                        value: selectedGender,
                        items: genderOptions,
                        onChanged: (val) {
                          setState(() {
                            selectedGender = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Row 3: Date of Birth & Experience
                Row(
                  children: [
                    Expanded(
                      child: _buildFieldWithLabel(
                        label: 'Date of Birth *',
                        hint: 'dd/mm/yyyy',
                        controller: dobCtrl,
                        readOnly: true,
                        suffixIcon: Icons.calendar_today_outlined,
                        onTap: () => _selectDateOfBirth(context),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildFieldWithLabel(
                        label: 'Experience (Years) *',
                        hint: 'e.g. 5',
                        controller: expCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: Color(0xFFF1F5F9)),
                const SizedBox(height: 20),

                // SECTION 2: Professional Information
                Text(
                  'Professional Information',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                const SizedBox(height: 18),

                // Row 1: Specialization & Qualification
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Specialization *',
                        hint: 'Select Specialization',
                        value: selectedSpecialization,
                        items: specializationOptions,
                        onChanged: (val) {
                          setState(() {
                            selectedSpecialization = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildFieldWithLabel(
                        label: 'Qualification *',
                        hint: 'e.g. MBBS, FCPS',
                        controller: qualificationCtrl,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Row 2: License Number & About Doctor
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildFieldWithLabel(
                        label: 'License Number *',
                        hint: 'e.g. PMC-12345',
                        controller: licenseCtrl,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildFieldWithLabel(
                        label: 'About Doctor *',
                        hint: 'Write a short bio about the doctor...',
                        controller: aboutCtrl,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Action Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel Button
                    OutlinedButton(
                      onPressed: () {
                        if (widget.onSuccess != null) {
                          widget.onSuccess!();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF475569),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Next Button
                    ElevatedButton(
                      onPressed: _goToNextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Next',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
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
  }

  // ================= FIELD HELPER WIDGETS =================
  Widget _buildFieldWithLabel({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    IconData? suffixIcon,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
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
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(fontSize: 13.5, color: const Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
                color: const Color(0xFF94A3B8), fontSize: 13),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: const Color(0xFF64748B), size: 18)
                : null,
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
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

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number *',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            // Country Prefix Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/img.png', // Fallback or flag icon
                    height: 18,
                    width: 22,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('🇵🇰', style: TextStyle(fontSize: 16));
                    },
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+92',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 16, color: Color(0xFF64748B)),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Number Input
            Expanded(
              child: TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.poppins(
                    fontSize: 13.5, color: const Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: '300 1234567',
                  hintStyle: GoogleFonts.poppins(
                      color: const Color(0xFF94A3B8), fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFFFAFAFA),
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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
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
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Color(0xFF64748B), size: 20),
          style: GoogleFonts.poppins(
              fontSize: 13.5, color: const Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
                color: const Color(0xFF94A3B8), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
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
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: GoogleFonts.poppins(fontSize: 13.5)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
