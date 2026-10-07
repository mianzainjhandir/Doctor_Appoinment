import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientChatView extends StatefulWidget {
  const PatientChatView({super.key});

  @override
  State<PatientChatView> createState() => _PatientChatViewState();
}

class _PatientChatViewState extends State<PatientChatView> {
  final TextEditingController searchCtrl = TextEditingController();
  final TextEditingController messageCtrl = TextEditingController();

  Map<String, dynamic>? selectedDoctor;
  String? selectedDoctorId;

  @override
  void dispose() {
    searchCtrl.dispose();
    messageCtrl.dispose();
    super.dispose();
  }

  // Generate unique chatId between Patient & Doctor
  String _getChatId(String patientUid, String doctorId) {
    if (patientUid.compareTo(doctorId) < 0) {
      return '${patientUid}_$doctorId';
    } else {
      return '${doctorId}_$patientUid';
    }
  }

  // Send Message Action
  Future<void> _sendMessage() async {
    final String text = messageCtrl.text.trim();
    if (text.isEmpty || selectedDoctorId == null) return;

    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String patientUid = currentUser?.uid ?? 'guest_patient';
    final String chatId = _getChatId(patientUid, selectedDoctorId!);

    messageCtrl.clear();

    try {
      final messageData = {
        'senderId': patientUid,
        'senderName': currentUser?.displayName ?? 'Patient',
        'receiverId': selectedDoctorId,
        'message': text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Save message in subcollection
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(messageData);

      // Update parent chat document meta
      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'patientId': patientUid,
        'doctorId': selectedDoctorId,
        'doctorName': selectedDoctor?['fullName'] ?? 'Doctor',
      }, SetOptions(merge: true));
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send message: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 800;

          if (isWide) {
            return Row(
              children: [
                // Left Column: WhatsApp-style Doctors List Sidebar
                SizedBox(
                  width: 320,
                  child: _buildDoctorsListSidebar(),
                ),
                const SizedBox(width: 16),

                // Right Column: WhatsApp Chat Room Area
                Expanded(
                  child: _buildChatRoomArea(),
                ),
              ],
            );
          } else {
            // Mobile View
            if (selectedDoctorId != null) {
              return Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          selectedDoctorId = null;
                          selectedDoctor = null;
                        });
                      },
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF2563EB)),
                    ),
                  ),
                  Expanded(child: _buildChatRoomArea()),
                ],
              );
            }
            return _buildDoctorsListSidebar();
          }
        },
      ),
    );
  }

  // ================= LEFT DOCTORS CHAT LIST (WHATSAPP STYLE) =================
  Widget _buildDoctorsListSidebar() {
    return Container(
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
          // Header Title
          Padding(
            padding: const EdgeInsets.only(left: 18, right: 18, top: 18, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Messages & Doctors',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_rounded,
                    size: 16,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: searchCtrl,
                onChanged: (val) {
                  setState(() {});
                },
                style: GoogleFonts.poppins(fontSize: 12.5),
                decoration: InputDecoration(
                  hintText: 'Search doctor...',
                  hintStyle: GoogleFonts.poppins(
                    color: const Color(0xFF94A3B8),
                    fontSize: 12.5,
                  ),
                  prefixIcon: const Icon(Icons.search,
                      color: Color(0xFF64748B), size: 16),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Live StreamBuilder from Firestore "doctor" collection
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('doctor').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No Doctors Available',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  );
                }

                final allDocs = snapshot.data!.docs;

                final doctors = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final String name =
                      (data['fullName'] ?? '').toString().toLowerCase();
                  final String spec =
                      (data['specialty'] ?? '').toString().toLowerCase();
                  final String query = searchCtrl.text.toLowerCase().trim();

                  return query.isEmpty ||
                      name.contains(query) ||
                      spec.contains(query);
                }).toList();

                return ListView.separated(
                  itemCount: doctors.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final doc = doctors[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final String docId = doc.id;

                    final bool isSelected = selectedDoctorId == docId;

                    return _buildDoctorChatItem(docId, data, isSelected);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Doctor Item Card in WhatsApp List
  Widget _buildDoctorChatItem(
      String docId, Map<String, dynamic> data, bool isSelected) {
    final String? profileImgBase64 = data['profileImage'];
    final String name = data['fullName'] ?? 'Dr. Specialist';
    final String spec = data['specialty'] ?? 'Cardiologist';

    Widget avatarWidget;
    if (profileImgBase64 != null &&
        profileImgBase64.isNotEmpty &&
        profileImgBase64.contains('base64,')) {
      try {
        final String cleanBase64 = profileImgBase64.split('base64,').last;
        final Uint8List bytes = base64Decode(cleanBase64);
        avatarWidget = Image.memory(
          bytes,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
        );
      } catch (e) {
        avatarWidget = const Icon(Icons.person_rounded,
            size: 24, color: Color(0xFF2563EB));
      }
    } else {
      avatarWidget = const Icon(Icons.person_rounded,
          size: 24, color: Color(0xFF2563EB));
    }

    return InkWell(
      onTap: () {
        setState(() {
          selectedDoctorId = docId;
          selectedDoctor = data;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
        child: Row(
          children: [
            // Avatar with Online Green Status Dot
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFDBEAFE),
                  child: ClipOval(child: avatarWidget),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    spec,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= RIGHT CHAT ROOM AREA =================
  Widget _buildChatRoomArea() {
    if (selectedDoctorId == null || selectedDoctor == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.chat_outlined,
                  size: 60, color: Color(0xFF94A3B8)),
              const SizedBox(height: 14),
              Text(
                'Select a Doctor to Start Consultation Chat',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Click on any doctor from the list on the left to begin messaging.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String patientUid = currentUser?.uid ?? 'guest_patient';
    final String chatId = _getChatId(patientUid, selectedDoctorId!);

    final String name = selectedDoctor!['fullName'] ?? 'Dr. Specialist';
    final String spec = selectedDoctor!['specialty'] ?? 'Cardiologist';

    return Container(
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
          // Chat Room Top Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFDBEAFE),
                  child: const Icon(Icons.person_rounded,
                      color: Color(0xFF2563EB), size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$spec • Online',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.phone_outlined,
                      color: Color(0xFF2563EB), size: 20),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.videocam_outlined,
                      color: Color(0xFF2563EB), size: 20),
                ),
              ],
            ),
          ),

          // Messages List Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet. Say hello to $name!',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data =
                        messages[index].data() as Map<String, dynamic>;
                    final bool isMe = data['senderId'] == patientUid;

                    return _buildMessageBubble(
                        data['message'] ?? '', isMe, data['timestamp']);
                  },
                );
              },
            ),
          ),

          // Chat Input Bar (WhatsApp Style)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.attach_file_rounded,
                      color: Color(0xFF64748B), size: 22),
                ),
                Expanded(
                  child: TextField(
                    controller: messageCtrl,
                    style: GoogleFonts.poppins(fontSize: 13.5),
                    onSubmitted: (val) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: GoogleFonts.poppins(
                        color: const Color(0xFF94A3B8),
                        fontSize: 13.5,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                            color: Color(0xFF2563EB), width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: _sendMessage,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Message Bubble
  Widget _buildMessageBubble(String text, bool isMe, dynamic timestamp) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight:
                isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            color: isMe ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }
}
