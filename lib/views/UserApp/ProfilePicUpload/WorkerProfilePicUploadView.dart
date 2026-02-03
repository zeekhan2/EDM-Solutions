import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:edm_solutions/views/UserApp/Home/workerhomeview_new.dart';
import '../../../../consts/colors.dart';
import '../../../consts/buttons.dart';

import '../../../controllers/auth_controller.dart';
import '../../../services/storage_service.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

class WorkerProfilePicUploadView extends StatefulWidget {
  const WorkerProfilePicUploadView({super.key});

  @override
  State<WorkerProfilePicUploadView> createState() =>
      _WorkerProfilePicUploadViewState();
}

class _WorkerProfilePicUploadViewState
    extends State<WorkerProfilePicUploadView> {
  final ImagePicker _picker = ImagePicker();
  final AuthController _auth = Get.find<AuthController>();

  File? selectedImage;
  bool isLoading = false;

  // ================= PICK IMAGE =================
  Future<void> pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
    });
  }

  // ================= UPLOAD + SAVE =================
  Future<void> _save() async {
  if (selectedImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select a profile picture'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  try {
    setState(() => isLoading = true);

    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token missing');
    }

    final res = await ApiService.postMultipart(
      endpoint: '/api/profile/update',
      token: token,
      files: {
        'image': selectedImage!, // ✅ correct field
      },
      fields: {},
    );

    if (res.success != true) {
      throw Exception('Upload failed');
    }

    final userRes = await AuthService.getUser(token);
    if (userRes.success && userRes.data != null) {
      await StorageService.saveUser(userRes.data!);
      _auth.currentUser.value = userRes.data!;
      _auth.currentUser.refresh();
    }

    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 100));
    Get.offAll(() => const WorkerHomeViewNew());
  } catch (_) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile image upload failed'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) {
      setState(() => isLoading = false);
    }
  }
}


  // ================= USER INITIALS =================
  String get initials {
    final name = _auth.currentUser.value?.fullName ?? '';
    if (name.isEmpty) return 'U';
    return name
        .split(' ')
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Profile Picture",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 40),

          // ================= AVATAR =================
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: appPrimeryColor,
                backgroundImage:
                    selectedImage != null ? FileImage(selectedImage!) : null,
                child: selectedImage == null
                    ? Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),

              Positioned(
                right: 4,
                bottom: 4,
                child: GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: appPrimeryColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          GestureDetector(
            onTap: pickImage,
            child: Text(
              "Upload Photo",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: appPrimeryColor,
              ),
            ),
          ),

          const Spacer(),

          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
  child: SizedBox(
    width: double.infinity,
    height: 50, // 👈 same height as PrimaryButton
    child: isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : PrimaryButton(
            label: "Save",
            onPressed: _save,
          ),
  ),
),

        ],
      ),
    );
  }
}