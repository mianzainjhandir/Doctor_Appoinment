import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddDoctorAvailabilityView extends StatefulWidget {
  final Map<String, dynamic> doctorDataStep1;
  final VoidCallback onBack;
  final VoidCallback onSuccess;

  const AddDoctorAvailabilityView({
    super.key,
    required this.doctorDataStep1,
    required this.onBack,
    required this.onSuccess,
  });

  @override
  State<AddDoctorAvailabilityView> createState() =>
      _AddDoctorAvailabilityViewState();
}

class _AddDoctorAvailabilityViewState
    extends State<AddDoctorAvailabilityView> {
  // Fee Controllers
  final feeCtrl = TextEditingController();
  final followUpFeeCtrl = TextEditingController();

  // Schedule State & Controllers
  final List<String> allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final Set<String> selectedDays = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri'};

  final startTimeCtrl = TextEditingController(text: '09:00 AM');
  final endTimeCtrl = TextEditingController(text: '05:00 PM');
  final breakTimeCtrl = TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    feeCtrl.dispose();
    followUpFeeCtrl.dispose();
    startTimeCtrl.dispose();
    endTimeCtrl.dispose();
    breakTimeCtrl.dispose();
    super.dispose();
  }

  void _toggleDay(String day) {
    setState(() {
      if (selectedDays.contains(day)) {
        if (selectedDays.length > 1) {
          selectedDays.remove(day);
        }
      } else {
        selectedDays.add(day);
      }
    });
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
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
      final formattedTime = picked.format(context);
      setState(() {
        controller.text = formattedTime;
      });
    }
  }

  Future<void> _saveCompleteDoctor() async {
    if (feeCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter Consultation Fee',
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
      // Combine Step 1 data with Step 2 (Fee & Availability)
      final Map<String, dynamic> fullDoctorData = {
        ...widget.doctorDataStep1,
        'fee': feeCtrl.text.trim(),
        'followUpFee': followUpFeeCtrl.text.trim(),
        'availableDays': selectedDays.toList(),
        'startTime': startTimeCtrl.text.trim(),
        'endTime': endTimeCtrl.text.trim(),
        'breakTime': breakTimeCtrl.text.trim(),
        'role': 'doctor',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore "doctor" collection
      await FirebaseFirestore.instance
          .collection('doctor')
          .add(fullDoctorData);

      setState(() {
        isSaving = false;
      });

      Get.snackbar(
        'Success',
        'Doctor added successfully with availability schedule!',
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
          // Header Title & Subtitle
          Text(
            'Add Doctor - Availability & Fee',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Set the doctor's consultation fee and availability schedule.",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),

          // SECTION 1: Consultation Fee Card
          Container(
            padding: const EdgeInsets.all(24),
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
                Text(
                  'Consultation Fee',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                const SizedBox(height: 16),

                // Row: Consultation Fee & Follow-up Fee
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: 'Consultation Fee (PKR) *',
                        hint: 'e.g. 1500',
                        controller: feeCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildInputField(
                        label: 'Follow-up Fee (PKR) (Optional)',
                        hint: 'e.g. 1000',
                        controller: followUpFeeCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // SECTION 2: Availability Schedule Card
          Container(
            padding: const EdgeInsets.all(24),
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
                Text(
                  'Availability Schedule',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                const SizedBox(height: 16),

                // Select Days Label & Pills
                Text(
                  'Select Days *',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 10),

                // Days Selection Pills
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: allDays.map((day) {
                    final bool isSelected = selectedDays.contains(day);
                    return InkWell(
                      onTap: () => _toggleDay(day),
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFE2E8F0),
                          ),
                          boxShadow: isSelected
                              ? const [
                                  BoxShadow(
                                    color: Color(0x202563EB),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          day,
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
                const SizedBox(height: 20),

                // Row: Start Time & End Time
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: 'Start Time *',
                        hint: '09:00 AM',
                        controller: startTimeCtrl,
                        readOnly: true,
                        suffixIcon: Icons.access_time_rounded,
                        onTap: () => _selectTime(context, startTimeCtrl),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildInputField(
                        label: 'End Time *',
                        hint: '05:00 PM',
                        controller: endTimeCtrl,
                        readOnly: true,
                        suffixIcon: Icons.access_time_rounded,
                        onTap: () => _selectTime(context, endTimeCtrl),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Row: Break Time (Optional)
                _buildInputField(
                  label: 'Break Time (Optional)',
                  hint: 'e.g. 01:00 PM - 02:00 PM',
                  controller: breakTimeCtrl,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Bottom Actions Row (Right-aligned)
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

              // Save / Next Button
              ElevatedButton(
                onPressed: isSaving ? null : _saveCompleteDoctor,
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
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Save Doctor',
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
    );
  }

  // ================= INPUT FIELD HELPER =================
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    IconData? suffixIcon,
    VoidCallback? onTap,
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
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(
              fontSize: 13.5, color: const Color(0xFF0F172A)),
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
}
