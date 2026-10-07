import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package0:google_fonts/google_fonts.dart';

class DoctorMessagesView extends StatefulWidget {
  const DoctorMessagesView({super.key});

  @override
  State<DoctorMessagesView> createState() => _DoctorMessagesViewState();
}

class _DoctorMessagesViewState extends State<DoctorMessagesView> {
  final TextEditingController messageCtrl = TextEditingController();
  String? selectedChatId;
  Map<String, dynamic>? selectedChatMeta;

  @override
  void dispose() {
    messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final String text = messageCtrl.text.trim();
    if (text.isEmpty || selectedChatId == null) return;

    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String doctorUid = currentUser?.uid ?? 'guest_doctor';

    messageCtrl.clear();

    try {
      final messageData = {
        'senderId': doctorUid,
        'senderName': currentUser?.displayName ?? 'Doctor',
        'message': text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(selectedChatId)
          .collection('messages')
          .add(messageData);

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(selectedChatId)
          .set({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not send message: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 800;

          if (isWide) {
            return Row(
              children: [
                SizedBox(
                  width: 320,
                  child: _buildPatientChatsSidebar(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildChatRoomArea(),
                ),
              ],
            );
          } else {
            if (selectedChatId != null) {
              return Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          selectedChatId = null;
                        });
                      },
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF2563EB)),
                    ),
                  ),
                  Expanded(child: _buildChatRoomArea()),
                ],
              );
            }
            return _buildPatientChatsSidebar();
          }
        },
      ),
    );
  }

  Widget _buildPatientChatsSidebar() {
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
          Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              'Patient Consultations',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .orderBy('lastMessageTime', descending: true)
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
                      'No Active Patient Chats',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final String chatId = doc.id;

                    final bool isSelected = selectedChatId == chatId;
                    final String pName = data['patientName'] ?? 'Patient User';
                    final String lastMsg = data['lastMessage'] ?? 'Started chat';

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedChatId = chatId;
                          selectedChatMeta = data;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        color:
                            isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFFDCFCE7),
                              child: const Icon(Icons.person_rounded,
                                  color: Color(0xFF16A34A), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    lastMsg,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFF64748B),
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
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomArea() {
    if (selectedChatId == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: Text(
            'Select a patient chat from the list to reply.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
      );
    }

    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String doctorUid = currentUser?.uid ?? 'guest_doctor';
    final String pName = selectedChatMeta?['patientName'] ?? 'Patient User';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFDCFCE7),
                  child: const Icon(Icons.person_rounded,
                      color: Color(0xFF16A34A), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  pName,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(selectedChatId)
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
                    child: Text('No messages in this chat.',
                        style: GoogleFonts.poppins(color: const Color(0xFF94A3B8))),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final bool isMe = data['senderId'] == doctorUid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        constraints: const BoxConstraints(maxWidth: 340),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          data['message'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            color: isMe ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageCtrl,
                    style: GoogleFonts.poppins(fontSize: 13.5),
                    onSubmitted: (val) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Type response to patient...',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send_rounded,
                      color: Color(0xFF2563EB)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
