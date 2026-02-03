import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:edm_solutions/Common_Widgets/safe_snackbar_helper.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import '../../../consts/api_constants.dart';
import '../../../controllers/auth_controller.dart';

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({super.key});

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  final AuthController auth = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();

  final _facilityCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  File? _avatarFile;
  String? _avatarUrl;

  bool _loading = false;
  Map<String, String> _apiErrors = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ================= IMAGE URL FIX =================
  String? _resolveImageUrl(String? image) {
    if (image == null || image.isEmpty) return null;

    // Already full URL
    if (image.startsWith('http')) return image;

    // Backend returns relative path
    return '${ApiConstants.baseUrl}/storage/$image';

  }

  // ================= LOAD PROFILE =================
  Future<void> _loadProfile() async {
    try {
      setState(() => _loading = true);

      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) return;

      final res = await ApiService.get(
        endpoint: '/api/facility/profile',
        token: token,
      );

      if (res.success == true && res.data != null) {
        final data = res.data['data'];

        _facilityCtrl.text = data['facility_name'] ?? '';
        _contactCtrl.text = data['full_name'] ?? '';
        _emailCtrl.text = data['email'] ?? '';
        _phoneCtrl.text = data['phone_number'] ?? '';
        _addressCtrl.text = data['address'] ?? '';

        _avatarUrl = _resolveImageUrl(data['image']);

        auth.currentUser.update((u) {
          if (u != null) {
            auth.currentUser.value = u.copyWith(image: _avatarUrl);
          }
        });
        auth.currentUser.refresh();
        await StorageService.saveUser(auth.currentUser.value!);
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  // ================= IMAGE PICKER =================
  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
      });
    }
  }

  void _showImagePicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= SAVE =================
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _loading = true;
        _apiErrors.clear();
      });

      final token = await StorageService.getToken();
      if (token == null) return;

      final response = await ApiService.postMultipart(
        endpoint: ApiConstants.facilityProfileUpdate,
        token: token,
        fields: {
          'facility_name': _facilityCtrl.text.trim(),
          'full_name': _contactCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'phone_number': _phoneCtrl.text.trim(),
          'address': _addressCtrl.text.trim(),
        },
        files: _avatarFile != null ? {'image': _avatarFile!} : null,
      );

      if (response.success == true) {
        final updatedImage = response.data?['data']?['image'];

        if (updatedImage != null) {
          final resolved = _resolveImageUrl(updatedImage);

          auth.currentUser.update((u) {
            if (u != null) {
              auth.currentUser.value = u.copyWith(image: resolved);
            }
          });
          auth.currentUser.refresh();
          await StorageService.saveUser(auth.currentUser.value!);

          _avatarUrl = resolved;
        }

        SafeSnackbarHelper.showSafeSnackbar(
          title: 'Success',
          message: 'Account details updated',
        );

        setState(() => _avatarFile = null);
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (_avatarFile != null) {
      imageProvider = FileImage(_avatarFile!);
    } else if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_avatarUrl!);
    } else {
      imageProvider = null;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Account Details',
          style: TextStyle(color: Color(0xFF1E3A8A)),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: const Color(0xFF1E3A8A),
                          backgroundImage: imageProvider,
                          child: imageProvider == null
                              ? const Text(
                                  'CGH',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showImagePicker,
                            child: const CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.camera_alt, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _field('Facility Name', _facilityCtrl),
                    _field('Contact Person', _contactCtrl),
                    _field('Email Address', _emailCtrl,
                        type: TextInputType.emailAddress),
                    _field('Phone Number', _phoneCtrl,
                        type: TextInputType.phone),
                    _field('Address', _addressCtrl, maxLines: 2),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _field(
    String label,
    TextEditingController c, {
    int maxLines = 1,
    TextInputType type = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: c,
          keyboardType: type,
          maxLines: maxLines,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Required' : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
