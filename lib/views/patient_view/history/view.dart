import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientHistoryView extends StatelessWidget {
  const PatientHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Medical Consultation History',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'View your past completed doctor consultations, prescriptions & diagnosis records',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),

          // History Stream Builder from Firestore "appointments" where status == "Completed" or all appointments
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('appointments')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                  ),
                );
              }

              final allDocs = snapshot.hasData ? snapshot.data!.docs : [];

              final historyAppts = allDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final String pId = data['patientId'] ?? '';
                if (currentUser != null && pId.isNotEmpty) {
                  return pId == currentUser.uid || pId == 'guest_patient';
                }
                return true;
              }).toList();

              if (historyAppts.isEmpty) {
                return Column(
                  children: [
                    _buildHistoryCard(
                      doctorName: 'Dr. Ayesha Khan',
                      specialty: 'Cardiologist',
                      date: '28 Sep 2026',
                      time: '10:00 AM',
                      diagnosis:
                          'Routine Cardiovascular Checkup. Blood Pressure: 120/80 mmHg. Normal ECG.',
                      prescription:
                          'Tab Aspirin 75mg daily after breakfast • Multivitamin once daily.',
                    ),
                    const SizedBox(height: 16),
                    _buildHistoryCard(
                      doctorName: 'Dr. Muhammad Asif',
                      specialty: 'General Physician',
                      date: '15 Aug 2026',
                      time: '11:30 AM',
                      diagnosis:
                          'Seasonal Fever & Mild Fatigue. Recommended rest and hydration.',
                      prescription:
                          'Tab Panadol 500mg as needed • ORS Oral Hydration Salts.',
                    ),
                  ],
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: historyAppts.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final data =
                      historyAppts[index].data() as Map<String, dynamic>;

                  final String doctorName =
                      data['doctorName'] ?? 'Dr. Specialist';
                  final String specialty =
                      data['doctorSpecialty'] ?? 'Specialist';
                  final String date = data['appointmentDate'] ?? '2026-09-30';
                  final String time = data['appointmentTime'] ?? '10:00 AM';
                  final String reason = data['reason'] ?? 'General Checkup';

                  return _buildHistoryCard(
                    doctorName: doctorName,
                    specialty: specialty,
                    date: date,
                    time: time,
                    diagnosis: 'Reason for visit: $reason',
                    prescription:
                        'Consultation Record Saved • Fee: Rs. ${data['fee'] ?? '1,500'}',
                    imageBytesBase64: data['doctorImage'],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required String doctorName,
    required String specialty,
    required String date,
    required String time,
    required String diagnosis,
    required String prescription,
    String? imageBytesBase64,
  }) {
    Widget avatarWidget;
    if (imageBytesBase64 != null &&
        imageBytesBase64.isNotEmpty &&
        imageBytesBase64.contains('base64,')) {
      try {
        final String cleanBase64 = imageBytesBase64.split('base64,').last;
        final Uint8List bytes = base64Decode(cleanBase64);
        avatarWidget = Image.memory(
          bytes,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        );
      } catch (e) {
        avatarWidget = const Icon(Icons.person_rounded,
            size: 28, color: Color(0xFF2563EB));
      }
    } else {
      avatarWidget = const Icon(Icons.person_rounded,
          size: 28, color: Color(0xFF2563EB));
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFFDBEAFE),
                child: ClipOval(child: avatarWidget),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      specialty,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$date • $time',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Diagnosis Summary
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.description_outlined,
                  size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  diagnosis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Prescription
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.medication_outlined,
                  size: 16, color: Color(0xFF16A34A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  prescription,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF16A34A),
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
