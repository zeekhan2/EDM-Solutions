import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edm_solutions/consts/consts.dart';
import 'package:edm_solutions/Common_Widgets/safe_snackbar_helper.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackCtrl = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  void _submitFeedback() {
  if (_rating == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select a star rating before submitting."),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  if (_feedbackCtrl.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please type your feedback message."),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Thank you! Your feedback has been submitted successfully."),
      backgroundColor: Colors.green,
    ),
  );

  _feedbackCtrl.clear();
  setState(() => _rating = 0);
}


  Widget _star(int index) {
    return InkWell(
      onTap: () => setState(() => _rating = index),
      child: Icon(
        Icons.star,
        size: 34,
        color: _rating >= index ? AppColors.primary : Colors.grey.shade300,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: Container(
          margin: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Get.back(),
          ),
        ),
        title: Text("Feedback",
            style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: semibold,
                fontSize: 19)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Rate Your Experience",
                style: TextStyle(
                    fontFamily: semibold,
                    fontSize: 16,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),

            // ⭐⭐⭐⭐⭐ Rating Row
            Row(
              children: [
                _star(1),
                _star(2),
                _star(3),
                _star(4),
                _star(5),
              ],
            ),

            const SizedBox(height: 24),

            Text("Your Feedback",
                style: TextStyle(
                    fontFamily: semibold,
                    fontSize: 16,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),

            TextField(
              controller: _feedbackCtrl,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Tell us about your experience...",
                filled: true,
                fillColor: const Color(0xFFF8F9FB),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),

            const SizedBox(height: 26),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Submit Feedback",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: "semibold"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
