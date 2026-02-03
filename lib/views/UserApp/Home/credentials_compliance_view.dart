import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import '../../../consts/api_constants.dart';
import '../../../../consts/colors.dart';

enum CredentialStatus { verified, pending, rejected, required }

class CredentialItem {
  int id;
  String title;
  CredentialStatus status;
  String document;
  DateTime uploadedAt;
  DateTime updatedAt;

  CredentialItem({
    required this.id,
    required this.title,
    required this.status,
    required this.document,
    required this.uploadedAt,
    required this.updatedAt,
  });

  factory CredentialItem.fromJson(Map<String, dynamic> json) {
    return CredentialItem(
      id: json['id'],
      title: json['type'] ?? 'Document',
      document: json['document'] ?? '',
      uploadedAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      status: _mapStatus(json['status']),
    );
  }

  static CredentialStatus _mapStatus(dynamic status) {
    if (status == 1) return CredentialStatus.verified;
    if (status == 0) return CredentialStatus.pending;
    if (status == 2) return CredentialStatus.rejected;
    return CredentialStatus.required;
  }
}

class CredentialsComplianceView extends StatefulWidget {
  const CredentialsComplianceView({super.key});

  @override
  State<CredentialsComplianceView> createState() =>
      _CredentialsComplianceViewState();
}

class _CredentialsComplianceViewState
    extends State<CredentialsComplianceView> {
  final ImagePicker _picker = ImagePicker();
  final List<CredentialItem> credentials = [];

  bool loading = false;
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    _getComplianceDocuments();
  }

  Future<void> _getComplianceDocuments() async {
    final token = await StorageService.getToken();
    if (token == null) return;

    setState(() => loading = true);

    final resp = await ApiService.get(
      endpoint: ApiConstants.getComplianceDocuments,
      token: token,
    );

    credentials.clear();

    if (resp.data?['data'] is List) {
      for (final item in resp.data['data']) {
        credentials.add(CredentialItem.fromJson(item));
      }
    }

    setState(() => loading = false);
  }

  // ==========================================================
  // PICK + UPLOAD (BACKEND-CORRECT LOGIC)
  // ==========================================================
  Future<void> _pickAndUpload({CredentialItem? existingItem}) async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    final token = await StorageService.getToken();
    if (token == null) return;

    String type;
    CredentialItem? targetItem = existingItem;

    // ================= NEW DOCUMENT =================
    if (existingItem == null) {
      final ctrl = TextEditingController();

      final enteredType = await Get.dialog<String>(
        Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Document Type'),
                const SizedBox(height: 12),
                TextField(controller: ctrl),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (ctrl.text.trim().isNotEmpty) {
                      Get.back(result: ctrl.text.trim());
                    }
                  },
                  child: const Text('Upload'),
                ),
              ],
            ),
          ),
        ),
      );

      if (enteredType == null) return;
      type = enteredType;

      final normalized = type.replaceAll('\n', ' ').trim().toLowerCase();

      final match = credentials.firstWhereOrNull(
        (e) =>
            e.title.replaceAll('\n', ' ').trim().toLowerCase() ==
            normalized,
      );

      if (match != null) {
        targetItem = match;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Same document type detected. Existing document will be updated.',
            ),
          ),
        );
      }
    } else {
      // ================= RE-UPLOAD =================
      type = existingItem.title;
    }

    setState(() => uploading = true);

    await ApiService.postMultipart(
      endpoint: targetItem == null
          ? ApiConstants.uploadComplianceDocument
          : ApiConstants.updateComplianceDocument,
      token: token,
      files: {
        'document': File(picked.path),
      },
      fields: {
        'type': type,
      },
    );

    setState(() => uploading = false);
    await _getComplianceDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: Get.back,
        ),
        title: const Text(
          'Credentials & Compliance',
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (loading) const CircularProgressIndicator(),
            Expanded(
              child: ListView.builder(
                itemCount: credentials.length,
                itemBuilder: (_, i) {
                  return CredentialCard(
                    item: credentials[i],
                    onReupload: () =>
                        _pickAndUpload(existingItem: credentials[i]),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: uploading ? null : () => _pickAndUpload(),
                icon: const Icon(Icons.cloud_upload, color: Colors.white),
                label: const Text(
                  'Upload Document',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// CARD (UPDATED DATE SHOWN ONLY AFTER REAL UPDATE)
// ==========================================================
class CredentialCard extends StatelessWidget {
  final CredentialItem item;
  final VoidCallback onReupload;

  const CredentialCard({
    super.key,
    required this.item,
    required this.onReupload,
  });

  @override
  Widget build(BuildContext context) {
    final bool showUpdated =
        item.updatedAt.difference(item.uploadedAt).inSeconds > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.folder_open,
                  color: Color(0xFF1E3A8A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildStatusBadge(item.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Uploaded: ${item.uploadedAt.toLocal().toString().split(' ').first}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          if (showUpdated)
            Text(
              'Updated: ${item.updatedAt.toLocal().toString().split(' ').first}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: item.document.isEmpty
                      ? null
                      : () => Get.to(() => Image.network(item.document)),
                  child: const Text('View'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReupload,
                  icon: const Icon(Icons.cloud_upload, size: 16),
                  label: const Text('Re-upload'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(CredentialStatus status) {
    late Color bg, color;
    late String text;
    late IconData icon;

    switch (status) {
      case CredentialStatus.verified:
        bg = Colors.green[50]!;
        color = Colors.green;
        text = 'Verified';
        icon = Icons.check_circle;
        break;
      case CredentialStatus.pending:
        bg = Colors.amber[50]!;
        color = Colors.amber[700]!;
        text = 'Pending';
        icon = Icons.schedule;
        break;
      case CredentialStatus.rejected:
        bg = Colors.red[50]!;
        color = Colors.red;
        text = 'Rejected';
        icon = Icons.error;
        break;
      case CredentialStatus.required:
        bg = Colors.red[50]!;
        color = Colors.red;
        text = 'Required';
        icon = Icons.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
