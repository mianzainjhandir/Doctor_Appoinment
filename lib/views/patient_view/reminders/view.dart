import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientRemindersView extends StatefulWidget {
  const PatientRemindersView({super.key});

  @override
  State<PatientRemindersView> createState() => _PatientRemindersViewState();
}

class _PatientRemindersViewState extends State<PatientRemindersView> {
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController timeCtrl = TextEditingController();
  String selectedType = 'Appointment';

  final List<String> reminderTypes = [
    'Appointment',
    'Medication',
    'Lab Test',
  ];

  @override
  void dispose() {
    titleCtrl.dispose();
    timeCtrl.dispose();
    super.dispose();
  }

  // Add New Reminder Dialog
  void _showAddReminderDialog() {
    titleCtrl.clear();
    timeCtrl.text = '10:00 AM';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Add New Reminder',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: const Color(0xFF0F172A),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reminder Type',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                items: reminderTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    selectedType = val;
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Title / Note',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: titleCtrl,
                style: GoogleFonts.poppins(fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'e.g., Take Aspirin 75mg or Doctor Visit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Time',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: timeCtrl,
                style: GoogleFonts.poppins(fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'e.g., 10:00 AM or Daily 02:00 PM',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: _saveReminder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              child: Text('Save Reminder', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveReminder() async {
    final String title = titleCtrl.text.trim();
    if (title.isEmpty) return;

    final User? user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance.collection('reminders').add({
        'patientId': user?.uid ?? 'guest_patient',
        'title': title,
        'type': selectedType,
        'time': timeCtrl.text.trim(),
        'isEnabled': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context);

      Get.snackbar(
        'Reminder Added',
        'Automated reminder set for $title',
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to save reminder: $e',
          backgroundColor: Colors.red.shade400, colorText: Colors.white);
    }
  }

  Future<void> _toggleReminder(String docId, bool currentVal) async {
    try {
      await FirebaseFirestore.instance
          .collection('reminders')
          .doc(docId)
          .update({'isEnabled': !currentVal});
    } catch (_) {}
  }

  Future<void> _deleteReminder(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('reminders')
          .doc(docId)
          .delete();
      Get.snackbar('Deleted', 'Reminder removed',
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
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
                    'Health & Medication Reminders',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Set automated alerts for your appointments, medicine & lab tests',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddReminderDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  'Add Reminder',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Reminders Stream List
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reminders')
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

              final patientReminders = allDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final String pId = data['patientId'] ?? '';
                if (currentUser != null && pId.isNotEmpty) {
                  return pId == currentUser.uid || pId == 'guest_patient';
                }
                return true;
              }).toList();

              if (patientReminders.isEmpty) {
                return Column(
                  children: [
                    _buildDefaultReminderCard(
                      'Dr. Ayesha Khan Consultation',
                      'Appointment • Today at 10:00 AM',
                      Icons.alarm_rounded,
                      const Color(0xFF2563EB),
                      const Color(0xFFEFF6FF),
                    ),
                    const SizedBox(height: 12),
                    _buildDefaultReminderCard(
                      'Aspirin 75mg Medicine',
                      'Medication • Daily at 02:00 PM',
                      Icons.medication_outlined,
                      const Color(0xFF16A34A),
                      const Color(0xFFDCFCE7),
                    ),
                    const SizedBox(height: 12),
                    _buildDefaultReminderCard(
                      'Blood Test Report Submission',
                      'Lab Test • Tomorrow at 09:00 AM',
                      Icons.assignment_outlined,
                      const Color(0xFFD97706),
                      const Color(0xFFFEF3C7),
                    ),
                  ],
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: patientReminders.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doc = patientReminders[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final String docId = doc.id;

                  final String title = data['title'] ?? 'Reminder';
                  final String type = data['type'] ?? 'Appointment';
                  final String time = data['time'] ?? '10:00 AM';
                  final bool isEnabled = data['isEnabled'] ?? true;

                  IconData icon = Icons.alarm_rounded;
                  Color color = const Color(0xFF2563EB);
                  Color bgColor = const Color(0xFFEFF6FF);

                  if (type == 'Medication') {
                    icon = Icons.medication_outlined;
                    color = const Color(0xFF16A34A);
                    bgColor = const Color(0xFFDCFCE7);
                  } else if (type == 'Lab Test') {
                    icon = Icons.assignment_outlined;
                    color = const Color(0xFFD97706);
                    bgColor = const Color(0xFFFEF3C7);
                  }

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.poppins(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '$type • $time',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isEnabled,
                          activeThumbColor: const Color(0xFF2563EB),
                          onChanged: (val) =>
                              _toggleReminder(docId, isEnabled),
                        ),
                        IconButton(
                          onPressed: () => _deleteReminder(docId),
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Color(0xFFDC2626), size: 18),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultReminderCard(String title, String subtitle, IconData icon,
      Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: true,
            activeThumbColor: const Color(0xFF2563EB),
            onChanged: (val) {},
          ),
        ],
      ),
    );
  }
}
