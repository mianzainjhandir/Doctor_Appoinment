import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminAppointmentsView extends StatefulWidget {
  const AdminAppointmentsView({super.key});

  @override
  State<AdminAppointmentsView> createState() => _AdminAppointmentsViewState();
}

class _AdminAppointmentsViewState extends State<AdminAppointmentsView> {
  String selectedFilter = 'All Status';

  final List<String> statusOptions = [
    'All Status',
    'Confirmed',
    'Pending',
    'Cancelled'
  ];

  Future<void> _updateStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(docId)
          .update({'status': newStatus});

      Get.snackbar(
        'Status Updated',
        'Appointment status changed to $newStatus',
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not update status: $e',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hospital Appointments Management',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E1B4B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Manage all patient bookings, approvals & schedules',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),

              // Status Dropdown Filter
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedFilter,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: Color(0xFF64748B), size: 18),
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: const Color(0xFF0F172A)),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          selectedFilter = val;
                        });
                      }
                    },
                    items: statusOptions.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s));
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Main Appointments List Container
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
                    .collection('appointments')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.event_note_outlined,
                              size: 54, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 12),
                          Text(
                            'No Patient Appointments Booked Yet',
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

                  final appointments = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final String status = data['status'] ?? 'Confirmed';
                    return selectedFilter == 'All Status' ||
                        status == selectedFilter;
                  }).toList();

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: appointments.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, index) {
                      final doc = appointments[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final String docId = doc.id;

                      final String patientName =
                          data['patientName'] ?? 'Patient User';
                      final String doctorName =
                          data['doctorName'] ?? 'Dr. Specialist';
                      final String dateStr =
                          data['appointmentDate'] ?? '2026-09-30';
                      final String timeStr =
                          data['appointmentTime'] ?? '10:00 AM';
                      final String reason =
                          data['reason'] ?? 'General Checkup';
                      final String fee = data['fee'] ?? '1,500';
                      final String status = data['status'] ?? 'Confirmed';

                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFFDBEAFE),
                            child: const Icon(Icons.person_rounded,
                                color: Color(0xFF2563EB), size: 26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      patientName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '• $reason',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.5,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Doctor: $doctorName  |  Rs. $fee',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2563EB),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded,
                                        size: 13, color: Color(0xFF64748B)),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$dateStr - $timeStr',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: const Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: status == 'Confirmed'
                                  ? const Color(0xFFDCFCE7)
                                  : status == 'Cancelled'
                                      ? const Color(0xFFFEE2E2)
                                      : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
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
                          ),
                          const SizedBox(width: 14),

                          // Action Popup Options
                          PopupMenuButton<String>(
                            onSelected: (val) => _updateStatus(docId, val),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'Confirmed',
                                child: Text('Mark Confirmed'),
                              ),
                              const PopupMenuItem(
                                value: 'Cancelled',
                                child: Text('Cancel Appointment'),
                              ),
                            ],
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Icon(Icons.more_vert_rounded,
                                  color: Color(0xFF64748B), size: 18),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
