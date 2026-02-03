import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:edm_solutions/controllers/shift_controller.dart';
import 'package:edm_solutions/models/shift_models.dart';
import 'package:edm_solutions/views/FacilityApp/Home/dashboard.dart';

class ViewAllScreen extends StatefulWidget {
  const ViewAllScreen({super.key});

  @override
  State<ViewAllScreen> createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final ShiftController shiftController = Get.find<ShiftController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    shiftController.fetchAll();
  }

  // ================= FILTERS =================

  /// status == 2
  List<Shift> get pending => shiftController.pendingShifts;

  /// status == 3 ONLY (Approved / Confirmed)
  List<Shift> get approved =>
      shiftController.filledShifts.where((s) => s.status == 3).toList();

  /// No reject API yet
  List<Shift> get rejected => const [];

  // ================= CARD =================
  Widget _buildCard(Shift s, {required bool showActions}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E9EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE + STATUS
          Row(
            children: [
              Expanded(
                child: Text(
                  s.licenseType ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _statusPill(s),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            s.location ?? '',
            style: const TextStyle(color: Color(0xFF637085)),
          ),

          const SizedBox(height: 10),

          _row(
            Icons.access_time,
            '${s.createdAt ?? ''} • ${s.startTime ?? ''} - ${s.endTime ?? ''}',
          ),
          _row(
            Icons.attach_money,
            '\$${s.payPerHour?.toStringAsFixed(0) ?? ''}/hour',
          ),

          const SizedBox(height: 12),

          /// ACTIONS — ONLY FOR PENDING
          if (showActions && s.status == 2)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await shiftController.approveShift(s.id!);
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      'Approve',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
    Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () {
          Get.defaultDialog(
            title: 'Reject Shift',
            middleText: 'Are you sure?',
            onConfirm: () {
              shiftController.rejectShift(s. id!);
              Get.back();
            },
            textConfirm: 'Reject',
            textCancel: 'Cancel',
          );
        },
        child: const Text('Reject'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF8A97A7)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF8A97A7)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(Shift s) {
    if (s.status == 1) {
      return _pill('Open', const Color(0xFFEFF6FF), const Color(0xFF1E3A8A));
    }
    if (s.status == 2) {
      return _pill(
        'Pending',
        const Color(0xFFFFF5E6),
        const Color(0xFF8A5A00),
      );
    }
    if (s.status == 3) {
      return _pill(
        'Approved',
        const Color(0xFFEFFAF1),
        const Color(0xFF197A3A),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _pill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildList(List<Shift> list, {required bool showActions}) {
    if (list.isEmpty) {
      return const Center(child: Text('No items'));
    }
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) =>
          _buildCard(list[i], showActions: showActions),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            _tabs(),
            Expanded(
              child: Obx(
                () => TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(pending, showActions: true),
                    _buildList(approved, showActions: false),
                    _buildList(rejected, showActions: false),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.off(() => DashboardScreen()),
            icon: const Icon(Icons.arrow_back),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: 'Pending (${pending.length})'),
          Tab(text: 'Approved (${approved.length})'),
          Tab(text: 'Rejected (${rejected.length})'),
        ],
      ),
    );
  }
}
