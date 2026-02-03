import 'package:flutter/material.dart';
import 'package:edm_solutions/consts/colors.dart';
import 'package:edm_solutions/views/UserApp/OnBoard/OnBoard_Views.dart';
import 'package:get/get.dart';

import '../../consts/ModeCard.dart';

class ChooseModeViews extends StatefulWidget {
  const ChooseModeViews({super.key});

  @override
  State<ChooseModeViews> createState() => _ChooseModeViewsState();
}

class _ChooseModeViewsState extends State<ChooseModeViews> {
  String selectedMode = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              const Text(
                "Choose Your Mode",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 40),

              // Worker Mode Card
              ModeCard(
                emoji: "👷",
                title: "Worker Mode",
                subtitle: "Find shifts, manage work, and get paid",
                selected: selectedMode == "Worker",
                onTap: () {
                  setState(() => selectedMode = "Worker");
                },
              ),

              const SizedBox(height: 20),

              // Facility Mode Card
              ModeCard(
                emoji: "🏢",
                title: "Facility Mode",
                subtitle:
                    "Post shifts, manage staff, and streamline staffing.",
                selected: selectedMode == "Facility",
                onTap: () {
                  setState(() => selectedMode = "Facility");
                },
              ),

              const Spacer(),

              // ✅ Continue Button (ONLY CHANGE)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedMode.isEmpty
                        ? Colors.grey.shade400
                        : appPrimeryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: selectedMode.isEmpty
                      ? null
                      : () {
                          Get.to(() => OnBoardViews(mode: selectedMode));
                        },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
