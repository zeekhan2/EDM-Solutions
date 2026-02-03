import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../consts/app_text_styles.dart';
import '../../../consts/colors.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/worker_home_controller.dart';
import '../../../models/shift_models.dart';
import 'chat_view.dart';
import 'profile_view.dart';
import 'workerhomewidgets.dart';
import 'package:edm_solutions/views/UserApp/Clock/clock_in_out_view.dart';
import 'Shift_Details/workershiftdetailsview.dart';
import 'available_shifts_view_new.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerHomeViewNew extends StatefulWidget {
  const WorkerHomeViewNew({super.key});

  @override
  State<WorkerHomeViewNew> createState() => _WorkerHomeViewNewState();
}

class _WorkerHomeViewNewState extends State<WorkerHomeViewNew> {
  int bottomIndex = 0;

  final AuthController authController = Get.find<AuthController>();
  final WorkerHomeController workerController =
      Get.find<WorkerHomeController>();
  int unreadChatCount = 0;
  late final Stream<QuerySnapshot> _chatStream;

  @override
  void initState() {
    super.initState();

    if (authController.currentUser.value == null) {
      authController.checkLoginStatus();
    }

    final workerUid = authController.currentUser.value?.firebaseUid;
    if (workerUid != null && workerUid.isNotEmpty) {
      _chatStream = FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: workerUid)
          .snapshots();

      _chatStream.listen((snapshot) {
        int count = 0;

        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;

          // unread if last message NOT sent by me
          if (data['last_sender_uid'] != workerUid &&
              (data['unread_by'] as List?)?.contains(workerUid) == true) {
            count++;
          }
        }

        if (mounted) {
          setState(() => unreadChatCount = count);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _getBodyForIndex()),
      bottomNavigationBar: Stack(
        children: [
          WorkerBottomNavBar(
            currentIndex: bottomIndex,
            onTap: (i) async {
              if (i == bottomIndex) return;
              setState(() => bottomIndex = i);
              if (i == 0) {
                await workerController.fetchShifts();
              }
            },
          ),

          // 🔴 CHAT UNREAD BADGE (index = 2)
          if (unreadChatCount > 0)
            Positioned(
              right: 26,
              bottom: 42,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadChatCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _getBodyForIndex() {
    if (bottomIndex == 1) return const AvailableShiftsViewNew();
    if (bottomIndex == 2) return ChatView();
    if (bottomIndex == 3) return ProfileView();
    return _buildHomeContent();
  }

  // ================= HOME =================
  Widget _buildHomeContent() {
    return Obx(() {
      if (workerController.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      return RefreshIndicator(
        onRefresh: workerController.fetchShifts,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Text(
              'Dashboard',
              style: AppTextStyles.h1.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildCalendar(),
            const SizedBox(height: 20),
            _buildUpcomingShiftsSection(),
          ],
        ),
      );
    });
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Obx(() {
      final user = authController.currentUser.value;
      final name = user?.fullName ?? 'User';

      final ImageProvider<Object>? avatarImage =
          (user?.image != null && user!.image!.isNotEmpty)
              ? NetworkImage(user.image!) as ImageProvider<Object>
              : null;

      return Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            backgroundImage: avatarImage,
            child: avatarImage == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Welcome',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary),
            ),
            Text(
              name,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ]),
        ],
      );
    });
  }

  // ================= CALENDAR =================
  Widget _buildCalendar() {
    return Obx(() {
      final month = workerController.currentMonth.value;
      final selected = workerController.selectedDate.value;

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: workerController.previousMonth,
                icon: _navIcon(Icons.chevron_left),
              ),
              const SizedBox(width: 16),
              Text(
                workerController.monthYearText,
                style: AppTextStyles.h3.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: workerController.nextMonth,
                icon: _navIcon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildCalendarDays(month, selected),
        ],
      );
    });
  }

  Widget _navIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _buildCalendarDays(DateTime month, DateTime selected) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final startWeekday = firstDay.weekday;

    final days = <Widget>[];

    for (int i = 1; i < startWeekday; i++) {
      days.add(const SizedBox(width: 38, height: 38));
    }

    for (int d = 1; d <= lastDay.day; d++) {
      final date = DateTime(month.year, month.month, d);
      final isSelected = DateUtils.isSameDay(date, selected);

      days.add(
        GestureDetector(
          onTap: () => workerController.selectDate(date),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$d',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Wrap(spacing: 8, runSpacing: 8, children: days);
  }

  // ================= UPCOMING SHIFTS =================
  Widget _buildUpcomingShiftsSection() {
    return Obx(() {
      final now = DateTime.now();

      final shifts = workerController.todayShifts.where((s) {
        // status filter
        if (!(s.status == 2 || s.status == 3 || s.status == 4)) {
          return false;
        }

        if (s.date == null || s.endTime == null) {
          return false;
        }

        try {
          final shiftDate = DateFormat('yyyy-MM-dd').parse(s.date!);

          DateTime shiftEndTime;

          try {
            final t = DateFormat('hh:mm a').parse(s.endTime!);
            shiftEndTime = DateTime(
              shiftDate.year,
              shiftDate.month,
              shiftDate.day,
              t.hour,
              t.minute,
            );
          } catch (_) {
            final t = DateFormat('HH:mm').parse(s.endTime!);
            shiftEndTime = DateTime(
              shiftDate.year,
              shiftDate.month,
              shiftDate.day,
              t.hour,
              t.minute,
            );
          }

          return true;
        } catch (_) {
          return false;
        }
      }).toList();

      if (shifts.isEmpty) {
        return Text(
          'No upcoming shifts',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        );
      }

      /// 🔔 UPCOMING SHIFT WARNING (less than 5 hours)
      // Duration? remaining;

      // for (final s in shifts) {
      //   if (s.startTime == null || s.date == null) continue;

      //   try {
      //     final shiftDate = DateFormat('yyyy-MM-dd').parse(s.date!);

      //     DateTime start;

      //     try {
      //       final t = DateFormat('hh:mm a').parse(s.startTime!);
      //       start = DateTime(
      //         shiftDate.year,
      //         shiftDate.month,
      //         shiftDate.day,
      //         t.hour,
      //         t.minute,
      //       );
      //     } catch (_) {
      //       final t = DateFormat('HH:mm').parse(s.startTime!);
      //       start = DateTime(
      //         shiftDate.year,
      //         shiftDate.month,
      //         shiftDate.day,
      //         t.hour,
      //         t.minute,
      //       );
      //     }

      //     if (start.isAfter(now)) {
      //       remaining = start.difference(now);
      //       break;
      //     }
      //   } catch (_) {}
      // }

      /// 🔔 Less than 5 hours remaining
      if (workerController.hasUpcomingShiftSoon) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Shifts',
              style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(() => Text(
                          'Your next shift starts in '
                          '${workerController.upcomingShiftCountdownText}',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ],
        );
      }

      /// 🟢 Normal shift list
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today Shifts',
            style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...shifts.map(_buildShiftCard),
        ],
      );
    });
  }

  Widget _buildShiftCard(Shift shift) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${shift.startTime ?? ''} - ${shift.endTime ?? ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shift.location ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                  ],
                ),
              ),
              _statusChip(shift.status),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final result =
                      await Get.to<bool>(() => WorkerShiftDetailsView(
                            claimedShiftId: shift.realShiftId!,
                          ));

                  if (result == true) {
                    await workerController.fetchShiftsByDate(
                      workerController.selectedDate.value,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: const Text(
                  'Details',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildClockButton(shift),
        ],
      ),
    );
  }

  Widget _statusChip(int? status) {
    String text = 'Pending';
    Color color = Colors.red;

    if (status == 3) {
      text = 'Approved';
      color = Colors.green;
    } else if (status == 4) {
      text = 'In Progress';
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildClockButton(Shift shift) {
    if (shift.status == 2) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await Get.to(() => ClockInOutView(shift: shift));
          await workerController.fetchShifts();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          shift.status == 4 ? 'Clock Out' : 'Clock in / Out',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
