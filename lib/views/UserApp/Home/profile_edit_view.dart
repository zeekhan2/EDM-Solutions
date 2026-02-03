import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controllers/auth_controller.dart';
import '../../../services/worker_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/auth_service.dart';
import '../../../models/worker_models.dart';

class ProfileEditView extends StatefulWidget {
  const ProfileEditView({super.key});

  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView> {
  final _formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  final AuthController authController = Get.find<AuthController>();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;

  bool _loadingUser = true; // ✅ NEW

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLatestUser();
  }

  Future<void> _loadLatestUser() async {
    try {
      final token = await StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        final res = await AuthService.getUser(token);
        if (res.success && res.data != null) {
          await StorageService.saveUser(res.data!);
          authController.currentUser.value = res.data;
        }
      }
      _prefillFields();
    } finally {
      if (mounted) {
        setState(() => _loadingUser = false);
      }
    }
  }

  void _prefillFields() {
    final user = authController.currentUser.value;
    final parts = (user?.fullName ?? '').split(' ');

    _firstNameController.text = parts.isNotEmpty ? parts.first : '';
    _lastNameController.text = parts.length > 1 ? parts.last : '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phoneNumber ?? '';
    _addressController.text = user?.address ?? '';
    _cityController.text = user?.city ?? '';
    _zipCodeController.text = user?.zipCode ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  String get initials {
    final name = authController.currentUser.value?.fullName ?? '';
    if (name.isEmpty) return 'U';
    return name
        .split(' ')
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();
  }

  Future<void> _changePhoto() async {
    Get.bottomSheet(
      SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Get.back();
                final image =
                    await _picker.pickImage(source: ImageSource.camera);
                if (image == null) return;
                setState(() {
                  _selectedImage = File(image.path);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Get.back();
                final image =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    _selectedImage = File(image.path);
                  });
                }
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white, // ✅ THIS FIXES TRANSPARENCY
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) return;

      final request = ProfileUpdateRequest(
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text
            : null,
        city: _cityController.text.trim().isNotEmpty
            ? _cityController.text
            : null,
        zipCode: _zipCodeController.text.trim().isNotEmpty
            ? _zipCodeController.text
            : null,
      );

      final response =
          await WorkerService.profileUpdate(token, request, _selectedImage);

      if (response.success) {
        final userResponse = await AuthService.getUser(token);
        if (userResponse.success && userResponse.data != null) {
          final updatedUser = userResponse.data!;
          authController.currentUser.value = updatedUser;
          await StorageService.saveUser(updatedUser);
          authController.currentUser.refresh();
        }
        Get.back();
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      // ✅ LOADER GATE (NO UI CHANGE)
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = authController.currentUser.value;

    final ImageProvider<Object>? avatarImage = _selectedImage != null
        ? FileImage(_selectedImage!) as ImageProvider<Object>
        : (user?.image != null && user!.image!.isNotEmpty
            ? NetworkImage(user.image!) as ImageProvider<Object>
            : null);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFF1E3A8A),
                    backgroundImage: avatarImage,
                    child: avatarImage == null
                        ? Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 6,
                    child: InkWell(
                      onTap: _changePhoto,
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Color(0xFF1E3A8A),
                        child: Icon(Icons.camera_alt,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Change Photo',
                style: TextStyle(color: Color(0xFF1E3A8A)),
              ),
              const SizedBox(height: 24),
              _field('First Name', _firstNameController),
              _field('Last Name', _lastNameController),
              _field('Email', _emailController),
              _field('Phone Number', _phoneController),
              _field('Address', _addressController),
              Row(
                children: [
                  Expanded(child: _field('City', _cityController)),
                  const SizedBox(width: 12),
                  Expanded(child: _field('ZIP Code', _zipCodeController)),
                ],
              ),
              const SizedBox(height: 30),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isLoading.value ? null : _saveChanges,
                    child: isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save Changes',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF1E3A8A), fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
