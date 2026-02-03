import 'package:get/get.dart';

class ShiftItem {
  final String title;
  final String department;
  final String dateTime;
  final String rate;
  final String location;
  final String nurseName;
  final String rating;
  final List<String> skills;
  final String appliedAgo;

  ShiftItem({
    required this.title,
    required this.department,
    required this.dateTime,
    required this.rate,
    required this.location,
    required this.nurseName,
    required this.rating,
    required this.skills,
    required this.appliedAgo,
  });
}

class ViewAllController extends GetxController {
  RxInt currentTab = 0.obs; // 0=pending, 1=approved, 2=rejected

  RxList<ShiftItem> pending = <ShiftItem>[].obs;
  RxList<ShiftItem> approved = <ShiftItem>[].obs;
  RxList<ShiftItem> rejected = <ShiftItem>[].obs;

  @override
  void onInit() {
    super.onInit();

    /// Dummy sample data matching the UI EXACTLY
    pending.add(
      ShiftItem(
        title: "Registered Nurse (RN)",
        department: "Emergency Room",
        dateTime: "2025-10-25 • 7:00 AM - 7:00 PM",
        rate: "\$48.00/hour",
        location: "Emergency Room",
        nurseName: "Sarah Johnson",
        rating: "4.9",
        skills: ["BLS", "ACLS", "PALS"],
        appliedAgo: "Applied 2 hours ago",
      ),
    );
  }

  void approve(ShiftItem item) {
    pending.remove(item);
    approved.add(item);
    currentTab.value = 1; // switch to approved tab
  }

  void reject(ShiftItem item) {
    pending.remove(item);
    rejected.add(item);
    currentTab.value = 2; // switch to rejected tab
  }
}
