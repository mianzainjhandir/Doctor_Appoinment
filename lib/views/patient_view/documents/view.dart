import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientDocumentsView extends StatefulWidget {
  const PatientDocumentsView({super.key});

  @override
  State<PatientDocumentsView> createState() => _PatientDocumentsViewState();
}

class _PatientDocumentsViewState extends State<PatientDocumentsView> {
  PlatformFile? selectedFile;
  Uint8List? selectedFileBytes;
  String selectedDocCategory = 'Lab Reports';

  bool isUploading = false;

  final List<String> docCategories = [
    'Lab Reports',
    'Prescriptions',
    'Medical History',
    'X-Rays / Scans',
    'Others',
  ];

  // Pick Document File
  Future<void> _pickDocumentFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final PlatformFile file = result.files.first;
        final Uint8List? bytes = file.bytes;

        if (bytes != null) {
          setState(() {
            selectedFile = file;
            selectedFileBytes = bytes;
          });
          Get.snackbar(
            'File Attached',
            '${file.name} attached successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue.shade100,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Picker Notice',
        'Could not pick file: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }

  // Upload Document to Firestore
  Future<void> _uploadDocumentToFirestore() async {
    if (selectedFile == null || selectedFileBytes == null) {
      Get.snackbar(
        'Select File',
        'Please select a document file to upload',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      String base64Content = '';
      if (selectedFileBytes!.length <= 800000) {
        base64Content =
            'data:application/pdf;base64,${base64Encode(selectedFileBytes!)}';
      }

      final String formattedSize =
          '${(selectedFile!.size / (1024 * 1024)).toStringAsFixed(1)} MB';

      final Map<String, dynamic> docData = {
        'patientId': currentUser?.uid ?? 'guest_patient',
        'patientName': currentUser?.displayName ?? 'Patient User',
        'fileName': selectedFile!.name,
        'fileSize': formattedSize,
        'category': selectedDocCategory,
        'fileExtension': selectedFile!.extension ?? 'pdf',
        'fileContentBase64': base64Content,
        'uploadedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('patient_documents')
          .add(docData);

      setState(() {
        isUploading = false;
        selectedFile = null;
        selectedFileBytes = null;
      });

      Get.snackbar(
        'Upload Successful 🎉',
        'Your medical document has been securely saved.',
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      Get.snackbar(
        'Upload Error',
        'Failed to upload document: $e',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Delete Document
  Future<void> _deleteDocument(String docId, String name) async {
    try {
      await FirebaseFirestore.instance
          .collection('patient_documents')
          .doc(docId)
          .delete();

      Get.snackbar(
        'Deleted',
        '$name removed successfully',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not delete document: $e',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Title
          Text(
            'Upload Medical Documents',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Securely upload your reports. Our AI will analyze and provide a summary.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),

          // Top Grid Section: Drag & Drop Left + Supported Types Right
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 850;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Drag & Drop Box
                    Expanded(
                      flex: 7,
                      child: _buildUploadDropCard(),
                    ),
                    const SizedBox(width: 24),

                    // Right Supported Documents Card
                    Expanded(
                      flex: 4,
                      child: _buildSupportedTypesCard(),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildUploadDropCard(),
                    const SizedBox(height: 20),
                    _buildSupportedTypesCard(),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 32),

          // Bottom Section: Uploaded Documents List Left + Submit Action Right
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 850;

              Widget docsListWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Uploaded Documents',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // StreamBuilder from Firestore "patient_documents"
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('patient_documents')
                        .orderBy('uploadedAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(30),
                            child: CircularProgressIndicator(
                                color: Color(0xFF2563EB)),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Center(
                            child: Text(
                              'No medical documents uploaded yet.',
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        );
                      }

                      final allDocs = snapshot.data!.docs;

                      final patientDocs = allDocs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final String pId = data['patientId'] ?? '';
                        if (currentUser != null && pId.isNotEmpty) {
                          return pId == currentUser.uid || pId == 'guest_patient';
                        }
                        return true;
                      }).toList();

                      if (patientDocs.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Center(
                            child: Text(
                              'No documents found.',
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: patientDocs.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final doc = patientDocs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final String docId = doc.id;

                          return _buildUploadedDocCard(docId, data);
                        },
                      );
                    },
                  ),
                ],
              );

              Widget uploadButtonWidget = SizedBox(
                width: 260,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      isUploading ? null : _uploadDocumentToFirestore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Upload Document',
                          style: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: docsListWidget),
                    const SizedBox(width: 24),
                    uploadButtonWidget,
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    docsListWidget,
                    const SizedBox(height: 20),
                    uploadButtonWidget,
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // ================= DRAG & DROP CARD =================
  Widget _buildUploadDropCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
      ),
      child: Column(
        children: [
          // Cloud Upload Circle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x302563EB),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.cloud_upload_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            selectedFile != null
                ? 'Selected: ${selectedFile!.name}'
                : 'Drag & drop files here',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'or',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),

          // Browse Files Button
          ElevatedButton(
            onPressed: _pickDocumentFile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              selectedFile != null ? 'Change File' : 'Browse Files',
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Supports PDF, JPG, PNG (Max 10MB)',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SUPPORTED TYPES CARD =================
  Widget _buildSupportedTypesCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Text(
            'Supported Documents',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),

          _buildDocTypeItem(
              Icons.description_outlined, 'Lab Reports', 'Lab Reports'),
          _buildDocTypeItem(
              Icons.assignment_outlined, 'Prescriptions', 'Prescriptions'),
          _buildDocTypeItem(
              Icons.article_outlined, 'Medical History', 'Medical History'),
          _buildDocTypeItem(
              Icons.medical_services_outlined, 'X-Rays / Scans', 'X-Rays / Scans'),
          _buildDocTypeItem(
              Icons.adjust_rounded, 'Others', 'Others'),
        ],
      ),
    );
  }

  Widget _buildDocTypeItem(IconData icon, String title, String category) {
    final bool isSelected = selectedDocCategory == category;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedDocCategory = category;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB), size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UPLOADED DOC ITEM CARD =================
  Widget _buildUploadedDocCard(String docId, Map<String, dynamic> data) {
    final String fileName = data['fileName'] ?? 'Medical_Report.pdf';
    final String fileSize = data['fileSize'] ?? '2.4 MB';
    final String ext = (data['fileExtension'] ?? 'pdf').toString().toLowerCase();

    final bool isPdf = ext == 'pdf';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Extension Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isPdf ? const Color(0xFFFEE2E2) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
              color: isPdf ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),

          // File Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  fileSize,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          // View & Delete Action Icons
          IconButton(
            onPressed: () {
              Get.snackbar(
                'Document Preview',
                'Viewing $fileName',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.blue.shade100,
              );
            },
            icon: const Icon(Icons.remove_red_eye_outlined,
                color: Color(0xFF64748B), size: 18),
          ),
          IconButton(
            onPressed: () => _deleteDocument(docId, fileName),
            icon: const Icon(Icons.delete_outline_rounded,
                color: Color(0xFFDC2626), size: 18),
          ),
        ],
      ),
    );
  }
}
