import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientAppointmentsView extends StatefulWidget {
  const PatientAppointmentsView({super.key});

  @override
  State<PatientAppointmentsView> createState() =>
      _PatientAppointmentsViewState();
}

class _PatientAppointmentsViewState extends State<PatientAppointmentsView> {
  int activeTab = 0; // 0: Upcoming, 1: Past, 2: Cancelled

  final List<String> tabTitles = ['Upcoming', 'Past', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Header
          Text(
            'Appointments & History',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),

          // Filter Tabs Container
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: List.generate(tabTitles.length, (index) {
                final bool isSelected = activeTab == index;
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        activeTab = index;
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: Color(0x10000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tabTitles[index],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color:
                              isSelected ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),

          // StreamBuilder connected to Firestore "appointments" collection
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('appointments')
                .orderBy('createdAt', descending: true)
                .snapshots(),
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
                      const Icon(Icons.event_busy_outlined,
                          size: 54, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 12),
                      Text(
                        'No Appointments Found',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your booked doctor appointments will appear here.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final allDocs = snapshot.data!.docs;

              // Filter by logged-in patient and active tab status
              final appointments = allDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final String patientId = data['patientId'] ?? '';
                final String status = data['status'] ?? 'Confirmed';

                // Match currentUser uid if present
                if (currentUser != null && patientId.isNotEmpty) {
                  if (patientId != currentUser.uid && patientId != 'guest_patient') {
                    return false;
                  }
                }

                if (activeTab == 0) {
                  // Upcoming Tab
                  return status == 'Confirmed' || status == 'Pending';
                } else if (activeTab == 1) {
                  // Past Tab
                  return status == 'Completed';
                } else {
                  // Cancelled Tab
                  return status == 'Cancelled';
                }
              }).toList();

              if (appointments.isEmpty) {
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
                      'No ${tabTitles[activeTab].toLowerCase()} appointments.',
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
                itemCount: appointments.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final doc = appointments[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final String docId = doc.id;

                  return _buildAppointmentCard(docId, data);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= APPOINTMENT CARD ITEM =================
  Widget _buildAppointmentCard(String docId, Map<String, dynamic> data) {
    final String? profileImgBase64 = data['doctorImage'];
    final String doctorName = data['doctorName'] ?? 'Dr. Ayesha Khan';
    final String specialty = data['doctorSpecialty'] ?? 'Cardiologist';
    final String dateStr = data['appointmentDate'] ?? '2026-09-30';
    final String timeStr = data['appointmentTime'] ?? '10:00 AM';
    final String status = data['status'] ?? 'Confirmed';

    Widget avatarWidget;
    if (profileImgBase64 != null &&
        profileImgBase64.isNotEmpty &&
        profileImgBase64.contains('base64,')) {
      try {
        final String cleanBase64 = profileImgBase64.split('base64,').last;
        final Uint8List bytes = base64Decode(cleanBase64);
        avatarWidget = Image.memory(
          bytes,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
        );
      } catch (e) {
        avatarWidget = const Icon(Icons.person_rounded,
            size: 36, color: Color(0xFF2563EB));
      }
    } else {
      avatarWidget = const Icon(Icons.person_rounded,
          size: 36, color: Color(0xFF2563EB));
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
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Doctor Avatar
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFFDBEAFE),
            child: ClipOval(child: avatarWidget),
          ),
          const SizedBox(width: 18),

          // Appointment Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  specialty,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      '$dateStr  -  $timeStr',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status Badge & Options
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: status == 'Confirmed'
                      ? const Color(0xFFDCFCE7)
                      : status == 'Cancelled'
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      status == 'Confirmed'
                          ? Icons.check_circle_rounded
                          : status == 'Cancelled'
                              ? Icons.cancel_rounded
                              : Icons.access_time_filled_rounded,
                      size: 14,
                      color: status == 'Confirmed'
                          ? const Color(0xFF16A34A)
                          : status == 'Cancelled'
                              ? const Color(0xFFDC2626)
                              : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: status == 'Confirmed'
                            ? const Color(0xFF16A34A)
                            : status == 'Cancelled'
                                ? const Color(0xFFDC2626)
                                : const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
              if (status == 'Confirmed' || status == 'Pending') ...[
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => _cancelAppointment(docId, doctorName),
                  child: Text(
                    'Cancel Booking',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Cancel Appointment Action
  Future<void> _cancelAppointment(String docId, String docName) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Cancel Appointment',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            content: Text(
              'Are you sure you want to cancel your appointment with $docName?',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('No', style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
                child: Text('Yes, Cancel', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(docId)
            .update({'status': 'Cancelled'});

        Get.snackbar(
          'Cancelled',
          'Appointment cancelled successfully',
          backgroundColor: Colors.orange.shade800,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to cancel appointment: $e',
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
      }
    }
  }
}
