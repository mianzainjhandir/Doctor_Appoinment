import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPatientsView extends StatefulWidget {
  const AdminPatientsView({super.key});

  @override
  State<AdminPatientsView> createState() => _AdminPatientsViewState();
}

class _AdminPatientsViewState extends State<AdminPatientsView> {
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Patients Directory',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Manage all registered patients & their medical records',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),

          // Search Field Bar
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: searchCtrl,
              onChanged: (val) {
                setState(() {});
              },
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search patients by name or email...',
                hintStyle: GoogleFonts.poppins(
                  color: const Color(0xFF94A3B8),
                  fontSize: 13,
                ),
                prefixIcon:
                    const Icon(Icons.search, color: Color(0xFF64748B), size: 18),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Patients List Stream
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
                stream:
                    FirebaseFirestore.instance.collection('patient').snapshots(),
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
                          const Icon(Icons.people_outline_rounded,
                              size: 54, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 12),
                          Text(
                            'No Registered Patients Found',
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

                  final patients = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final String name =
                        (data['fullName'] ?? '').toString().toLowerCase();
                    final String email =
                        (data['email'] ?? '').toString().toLowerCase();
                    final String query = searchCtrl.text.toLowerCase().trim();

                    return query.isEmpty ||
                        name.contains(query) ||
                        email.contains(query);
                  }).toList();

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: patients.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, index) {
                      final doc = patients[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final String name =
                          data['fullName'] ?? 'Patient User';
                      final String email =
                          data['email'] ?? 'patient@example.com';
                      final String phone =
                          data['phoneNumber'] ?? '+92 300 1234567';
                      final String location =
                          data['location'] ?? 'Lahore, Pakistan';

                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFFDCFCE7),
                            child: const Icon(Icons.person_rounded,
                                color: Color(0xFF16A34A), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  '$email  •  $phone',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            location,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF334155),
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
