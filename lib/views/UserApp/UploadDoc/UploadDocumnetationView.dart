import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import 'package:edm_solutions/views/UserApp/ProfilePicUpload/WorkerProfilePicUploadView.dart';

import '../../../../consts/colors.dart';
import '../../../consts/buttons.dart';
import 'package:edm_solutions/consts/api_constants.dart';

class UploadDocumnetationView extends StatefulWidget {
  const UploadDocumnetationView({super.key});

  @override
  State<UploadDocumnetationView> createState() =>
      _UploadDocumnetationViewState();
}

class _UploadDocumnetationViewState extends State<UploadDocumnetationView> {
  final ImagePicker _picker = ImagePicker();

  bool uploading = false;

  // MULTI DOCUMENT STATE
  final List<File> documents = [];
  final List<TextEditingController> typeControllers = [];

  // ==========================================================
  // CAMERA PICKER
  // ==========================================================
  Future<void> pickFromCamera() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        documents.add(File(picked.path));
        typeControllers.add(TextEditingController());
      });
    }
  }

  // ==========================================================
  // UPLOAD DOCUMENTS (ONE API CALL PER DOCUMENT)
  // ==========================================================
  Future<void> uploadDocuments() async {
    if (documents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one document')),
      );
      return;
    }

    for (int i = 0; i < typeControllers.length; i++) {
      if (typeControllers[i].text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter type for all documents')),
        );
        return;
      }
    }

    final token = await StorageService.getToken();
    if (token == null) return;

    setState(() => uploading = true);

    try {
      for (int i = 0; i < documents.length; i++) {
        await ApiService.postMultipart(
          endpoint: ApiConstants.uploadComplianceDocument, // ✅ CORRECT API
          token: token,
          files: {
            'document': documents[i], // ✅ backend expects "document"
          },
          fields: {
            'type': typeControllers[i].text.trim(), // ✅ backend expects "type"
          },
        );
      }

      setState(() => uploading = false);

      // Navigate only AFTER all uploads succeed
      Get.off(() => const WorkerProfilePicUploadView());
    } catch (e) {
      setState(() => uploading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload failed. Please try again'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================================
  // UI (UNCHANGED)
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconCircleButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Upload Document",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 25),
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 140,
                  decoration: BoxDecoration(
                    color: appPrimeryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const Text(
              "Please upload a copy of\nyour Professional license or\ncertificate.",
              style: TextStyle(
                fontSize: 18,
                height: 1.4,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 25),
            _optionCard(
              title:
                  "Take a Picture of your Professional license or Certificate now",
              onTap: pickFromCamera,
            ),
            const SizedBox(height: 15),
            _optionCard(
              title:
                  "Upload an existing copy of your Professional license or certificate",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'File upload will be added soon. Please use camera for now.'),
                  ),
                );
              },
            ),
            const SizedBox(height: 25),
            Expanded(
              child: ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xffEAF6F8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: appPrimeryColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.insert_drive_file,
                                color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                documents[index].path.split('/').last,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  documents.removeAt(index);
                                  typeControllers[index].dispose();
                                  typeControllers.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: typeControllers[index],
                          decoration: InputDecoration(
                            hintText:
                                'Enter document type (e.g. CNIC, License)',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: appPrimeryColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            PrimaryButton(
              label: uploading ? "Uploading..." : "Submit Documents",
              icon: Icons.arrow_forward,
              onPressed: uploading ? null : uploadDocuments,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _optionCard({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
