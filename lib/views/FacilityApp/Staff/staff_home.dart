import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edm_solutions/consts/consts.dart';

import 'staff_profile.dart';
import '../../../controllers/staff_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/facility_dashboard_controller.dart';

import 'staff_chat_list.dart';
import 'staff_chat_screen.dart';
import 'invite_worker_page.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  final AuthController authController = Get.find<AuthController>();
  final FacilityDashboardController facilityController =
      Get.find<FacilityDashboardController>();
  final StaffController staffController = Get.find<StaffController>();

  final List<String> _roles = ['ALL'];
  final List<String> _locations = ['ALL'];

  String _selectedRole = 'ALL';
  String _selectedLocation = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
  staffController.fetchStaff();
  facilityController.fetchFacilityName();

  final facilityUid =
      authController.currentUser.value?.firebaseUid ?? '';

  if (facilityUid.isNotEmpty) {
    staffController.listenUnreadMessages(facilityUid);
  }
});

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            /// FACILITY AVATAR
            Obx(() {
              final user = authController.currentUser.value;

              final ImageProvider<Object>? avatar =
                  (user?.image != null && user!.image!.isNotEmpty)
                      ? NetworkImage(user.image!)
                      : null;

              final String initial =
                  (user?.fullName != null && user!.fullName!.isNotEmpty)
                      ? user.fullName![0].toUpperCase()
                      : 'F';

              return CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                backgroundImage: avatar,
                child: avatar == null
                    ? Text(
                        initial,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )
                    : null,
              );
            }),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Obx(() => Text(
                      facilityController.facility_name.value.isEmpty
                          ? '—'
                          : facilityController.facility_name.value,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    )),
              ],
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          children: [
            /// FILTERS + CHAT
            Row(
              children: [
                Row(
                  children: const [
                    Icon(Icons.tune_outlined,
                        size: 18, color: Color(0xFF1E3A8A)),
                    SizedBox(width: 6),
                    Text(
                      'Filters',
                      style: TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
  height: 38,
  child: Stack(
    clipBehavior: Clip.none,
    children: [
      ElevatedButton.icon(
        onPressed: () => Get.to(() => const StaffChatList()),
        icon: const Icon(
          Icons.chat_bubble_outline,
          size: 16,
          color: Colors.white,
        ),
        label: const Text(
          'Chat',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),

      /// 🔴 UNREAD BADGE
      Positioned(
        right: -4,
        top: -4,
        child: Obx(() {
          final int count = staffController.unreadCount.value;

          if (count == 0) return const SizedBox();

          return Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }),
      ),
    ],
  ),
),

              ],
            ),

            const SizedBox(height: 10),

            /// DROPDOWNS
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _dropdown(
                      value: _selectedRole,
                      items: _roles,
                      onChanged: (v) =>
                          setState(() => _selectedRole = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dropdown(
                      value: _selectedLocation,
                      items: _locations,
                      onChanged: (v) =>
                          setState(() => _selectedLocation = v!),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Obx(() => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${staffController.staff.length} candidates found',
                    style:
                        const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                )),

            const SizedBox(height: 12),

            /// STAFF LIST
            Expanded(
              child: Obx(() {
                if (staffController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (staffController.staff.isEmpty) {
                  return const Center(child: Text('No workers found'));
                }

                return ListView.separated(
                  itemCount: staffController.staff.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 14),
                  itemBuilder: (_, index) {
                    final data = staffController.staff[index];

                    return _WorkerCard(
                      data: data,
                      onViewProfile: () => Get.to(
                          () => StaffProfilePage(workerId: data['id'])),

                      onInvite: () => Get.to(
                          () => InviteWorkersPage(workerId: data['id'])),

                      onChat: () {
                        final workerUid = data['firebase_uid'] ?? '';
                        final facilityUid =
                            authController.currentUser.value?.firebaseUid ?? '';

                        if (workerUid.isEmpty || facilityUid.isEmpty) return;

                        final chatId =
                            'facility_${authController.currentUser.value?.id}_worker_${data['id']}';

                        Get.to(() => StaffChatScreen(
                              contactName: data['name'],
                              chatId: chatId,
                              otherUserFirebaseUid: workerUid,
                              workerId: data['id'],
                              facilityId:
                                  authController.currentUser.value?.id ?? 0,
                              workerName: data['name'],
                              facilityName:
                                  facilityController.facility_name.value,
                            ));
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items
              .map((e) =>
                  DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// ================= WORKER CARD =================

class _WorkerCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onViewProfile;
  final VoidCallback onInvite;
  final VoidCallback onChat;

  const _WorkerCard({
    required this.data,
    required this.onViewProfile,
    required this.onInvite,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = data['profile_visibility'] == 1;

    final ImageProvider<Object>? avatar =
        (data['image'] != null && data['image'].toString().isNotEmpty)
            ? NetworkImage(data['image'])
            : null;

    final String initial =
        (data['name'] ?? 'W')[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        /// HEADER
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary,
              backgroundImage: avatar,
              child: avatar == null
                  ? Text(
                      initial,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['name'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700)),
                    Text(data['job_title'] ?? '',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13)),
                  ]),
            ),
            if (isAvailable)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    borderRadius: BorderRadius.circular(12)),
                child: const Text('Available',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: onChat,
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            _stat(Icons.star, '${data['rating'] ?? '0.0'}'),
            _stat(Icons.work_outline,
                '${data['total_shifts'] ?? 0} shifts'),
            _stat(Icons.location_on_outlined, data['city'] ?? ''),
          ],
        ),

        const SizedBox(height: 6),
        Text('${data['experience_years'] ?? 0} years experience',
            style: const TextStyle(color: Colors.grey)),

        /// ✅ CREDENTIALS ONLY (SPECIALITIES REMOVED)
        if ((data['credentials'] as List?)?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: (data['credentials'] as List)
                .map<Widget>((e) => _chip(e.toString()))
                .toList(),
          ),
        ],

        const SizedBox(height: 14),

        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onViewProfile,
              child: const Text('View Profile'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onInvite,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child: const Text('Invite to Shift',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _stat(IconData icon, String text) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ]),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11, color: Color(0xFF1E3A8A))),
    );
  }
}
