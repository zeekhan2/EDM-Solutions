import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edm_solutions/consts/consts.dart';
import 'package:edm_solutions/Common_Widgets/safe_snackbar_helper.dart';
import 'package:edm_solutions/services/api_service.dart';
import 'package:edm_solutions/services/storage_service.dart';

class StaffProfilePage extends StatefulWidget {
  final int workerId;

  const StaffProfilePage({
    super.key,
    required this.workerId,
  });

  @override
  State<StaffProfilePage> createState() => _StaffProfilePageState();
}

class _StaffProfilePageState extends State<StaffProfilePage> {
  bool isLoading = true;
  Map<String, dynamic>? worker;

  @override
  void initState() {
    super.initState();
    _fetchWorkerDetails();
  }

  Future<void> _fetchWorkerDetails() async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) return;

      final res = await ApiService.get(
        endpoint: '/api/get/worker-details/${widget.workerId}',
        token: token,
      );

      if (res.success == true && res.data != null) {
        setState(() {
          worker = Map<String, dynamic>.from(res.data['worker']);
          isLoading = false;
        });
      } else {
        isLoading = false;
      }
    } catch (_) {
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final w = worker ?? {};
    final invited = (w['invited'] as bool?) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// HEADER
              Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFF2F80ED),
                    backgroundImage: w['image'] != null
                        ? NetworkImage(w['image'])
                        : null,
                    child: w['image'] == null
                        ? Text(
                            (w['name'] ?? '—')
                                .toString()
                                .substring(0, 1),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(w['name'] ?? '—',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Row(children: [
                            const Icon(Icons.star,
                                size: 16, color: Colors.amber),
                            const SizedBox(width: 6),
                            Text(w['rating'] ?? '0.0',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(width: 12),
                            const Icon(Icons.calendar_today_outlined, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${w['total_shifts'] ?? 0} shifts',
                              style: TextStyle(
                                  color: AppColors.textSecondary),
                            ),
                          ]),
                        ]),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              /// LOCATION
              Row(children: [
                const Icon(Icons.location_on_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    w['city'] ?? '—',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ]),

              const SizedBox(height: 18),

              /// CREDENTIALS
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Credentials',
                    style: TextStyle(
                        fontFamily: semibold,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    (w['credentials'] as List? ?? []).map<Widget>((c) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                        color: Colors.white),
                    child: Text('$c'),
                  );
                }).toList(),
              ),

              const Spacer(),

              /// INVITE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: invited
                      ? null
                      : () {
                          w['invited'] = true;
                          SafeSnackbarHelper.showSafeSnackbar(
                            title: 'Invitation sent',
                            message:
                                '${w['name']} has been invited.',
                            backgroundColor:
                                Colors.green.withOpacity(0.95),
                            colorText: Colors.white,
                          );
                          Get.back();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        invited ? Colors.grey : AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    invited ? 'Invited' : 'Invite to Shift',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
