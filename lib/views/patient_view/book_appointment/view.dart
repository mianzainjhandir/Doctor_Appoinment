import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class BookAppointmentView extends StatefulWidget {
  final Map<String, dynamic> doctorData;
  final VoidCallback onBack;
  final VoidCallback onBookingSuccess;

  const BookAppointmentView({
    super.key,
    required this.doctorData,
    required this.onBack,
    required this.onBookingSuccess,
  });

  @override
  State<BookAppointmentView> createState() => _BookAppointmentViewState();
}

class _BookAppointmentViewState extends State<BookAppointmentView> {
  DateTime selectedDate = DateTime.now();
  DateTime currentMonth = DateTime.now();

  String selectedTimeSlot = '10:00 AM';
  String selectedReason = 'General Checkup';
  final TextEditingController notesCtrl = TextEditingController();

  bool isConfirming = false;

  final List<String> timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
  ];

  final List<String> reasons = [
    'General Checkup',
    'Routine Consultation',
    'Follow-up Visit',
    'Report / Test Review',
    'Urgent Health Concern',
  ];

  @override
  void dispose() {
    notesCtrl.dispose();
    super.dispose();
  }

  // Save Appointment to Firestore
  Future<void> _confirmAppointment() async {
    setState(() {
      isConfirming = true;
    });

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      final data = widget.doctorData;

      final Map<String, dynamic> appointmentData = {
        'patientId': currentUser?.uid ?? 'guest_patient',
        'patientName': currentUser?.displayName ?? 'Patient User',
        'patientEmail': currentUser?.email ?? 'patient@example.com',
        'doctorName': data['fullName'] ?? 'Dr. Specialist',
        'doctorSpecialty': data['specialty'] ?? 'Cardiologist',
        'doctorImage': data['profileImage'] ?? '',
        'fee': data['fee'] ?? '1,500',
        'appointmentDate':
            '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
        'appointmentTime': selectedTimeSlot,
        'reason': selectedReason,
        'notes': notesCtrl.text.trim(),
        'status': 'Confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('appointments')
          .add(appointmentData);

      setState(() {
        isConfirming = false;
      });

      Get.snackbar(
        'Appointment Confirmed! 🎉',
        'Your appointment with ${data['fullName'] ?? 'Doctor'} for $selectedTimeSlot has been booked.',
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );

      widget.onBookingSuccess();
    } catch (e) {
      setState(() {
        isConfirming = false;
      });
      Get.snackbar(
        'Booking Failed',
        'Could not confirm appointment: $e',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doctorData;

    final String? profileImgBase64 = data['profileImage'];
    final String name = data['fullName'] ?? 'Dr. Ayesha Khan';
    final String spec = data['specialty'] ?? 'Cardiologist';
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
          const SizedBox(height: 12),

          // Main Header Title
          Text(
            'Book Appointment',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Select date, time and reason for your visit.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),

          // Top Doctor Summary Banner Card
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Row(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: const Color(0xFFDBEAFE),
                  child: ClipOval(child: avatarWidget),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF2563EB),
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        spec,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rs. $fee',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '4.8 (214 reviews)',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
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
          ),
          const SizedBox(height: 24),

          // Main 2-Column Grid: Calendar Left + Time/Reason Right
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 850;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Calendar Card
                    Expanded(
                      flex: 5,
                      child: _buildCalendarCard(),
                    ),
                    const SizedBox(width: 24),

                    // Right Column: Time Slots & Notes Form
                    Expanded(
                      flex: 6,
                      child: _buildBookingForm(),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildCalendarCard(),
                    const SizedBox(height: 24),
                    _buildBookingForm(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // ================= CALENDAR CARD =================
  Widget _buildCalendarCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
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
              // Month Header Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        currentMonth =
                            DateTime(currentMonth.year, currentMonth.month - 1);
                      });
                    },
                    icon: const Icon(Icons.chevron_left_rounded,
                        color: Color(0xFF2563EB)),
                  ),
                  Text(
                    _getMonthYearString(currentMonth),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        currentMonth =
                            DateTime(currentMonth.year, currentMonth.month + 1);
                      });
                    },
                    icon: const Icon(Icons.chevron_right_rounded,
                        color: Color(0xFF2563EB)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Days of week header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                    .map((d) => SizedBox(
                          width: 36,
                          child: Center(
                            child: Text(
                              d,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const Divider(height: 20, color: Color(0xFFF1F5F9)),

              // Days Grid Builder
              _buildDaysGrid(),
            ],
          ),
        ),
      ],
    );
  }

  String _getMonthYearString(DateTime dt) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  Widget _buildDaysGrid() {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday % 7; // 0 for Sun

    List<Widget> dayWidgets = [];

    // Empty lead cells
    for (int i = 0; i < startingWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 36, height: 36));
    }

    // Days cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(currentMonth.year, currentMonth.month, day);
      final bool isSelected = selectedDate.year == date.year &&
          selectedDate.month == date.month &&
          selectedDate.day == date.day;

      dayWidgets.add(
        InkWell(
          onTap: () {
            setState(() {
              selectedDate = date;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$day',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: dayWidgets,
    );
  }

  // ================= RIGHT BOOKING FORM =================
  Widget _buildBookingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Available Time Slots Header
        Text(
          'Available Time Slots',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),

        // Time Slots Grid
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: timeSlots.map((slot) {
            final bool isSelected = selectedTimeSlot == slot;
            return InkWell(
              onTap: () {
                setState(() {
                  selectedTimeSlot = slot;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x04000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  slot,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // 2. Reason for Visit Dropdown
        Text(
          'Reason for Visit',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          initialValue: selectedReason,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Color(0xFF64748B), size: 20),
          style: GoogleFonts.poppins(
              fontSize: 13.5, color: const Color(0xFF0F172A)),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
          ),
          items: reasons.map((r) {
            return DropdownMenuItem(value: r, child: Text(r));
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                selectedReason = val;
              });
            }
          },
        ),
        const SizedBox(height: 24),

        // 3. Additional Notes (optional)
        Text(
          'Additional notes (optional)',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),

        TextField(
          controller: notesCtrl,
          maxLines: 3,
          style: GoogleFonts.poppins(
              fontSize: 13.5, color: const Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: 'Any specific concerns or symptoms...',
            hintStyle: GoogleFonts.poppins(
                color: const Color(0xFF94A3B8), fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Confirm Appointment Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isConfirming ? null : _confirmAppointment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isConfirming
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Confirm Appointment',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
//I will work later..