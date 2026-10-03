import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorsListView extends StatelessWidget {
  final VoidCallback onAddDoctorPressed;

  const DoctorsListView({
    super.key,
    required this.onAddDoctorPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action Bar Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Doctors Directory',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Manage medical specialist profiles & registration',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: onAddDoctorPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(
                  'Add New Doctor',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // StreamBuilder from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('doctor')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.medical_services_outlined,
                          size: 60,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Doctors Registered Yet',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Click "Add New Doctor" button above to add a specialist.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 380,
                    mainAxisExtent: 220,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final String? profileImgBase64 = data['profileImage'];

                    Widget avatarWidget;
                    if (profileImgBase64 != null &&
                        profileImgBase64.isNotEmpty &&
                        profileImgBase64.contains('base64,')) {
                      try {
                        final String cleanBase64 = profileImgBase64.split('base64,').last;
                        final Uint8List bytes = base64Decode(cleanBase64);
                        avatarWidget = Image.memory(
                          bytes,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                        );
                      } catch (e) {
                        avatarWidget = const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF2563EB),
                          size: 28,
                        );
                      }
                    } else {
                      avatarWidget = const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF2563EB),
                        size: 28,
                      );
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
                            blurRadius: 10,
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
                                radius: 26,
                                backgroundColor: const Color(0xFFDBEAFE),
                                child: ClipOval(
                                  child: avatarWidget,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['fullName'] ?? 'Dr. Specialist',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F172A),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        data['specialty'] ?? 'Cardiologist',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Divider(color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(Icons.email_outlined,
                                  size: 16, color: Color(0xFF64748B)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  data['email'] ?? 'doctor@example.com',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFF475569),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.badge_outlined,
                                  size: 16, color: Color(0xFF64748B)),
                              const SizedBox(width: 8),
                              Text(
                                'Reg: ${data['licenseNumber'] ?? 'PMC-12345'}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
