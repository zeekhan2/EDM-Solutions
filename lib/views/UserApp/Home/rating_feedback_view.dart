import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/storage_service.dart';
import '../../../services/api_service.dart';
import '../../../consts/api_constants.dart';

class RatingFeedbackScreen extends StatefulWidget {
  const RatingFeedbackScreen({super.key});

  @override
  State<RatingFeedbackScreen> createState() => _RatingFeedbackScreenState();
}

class _RatingFeedbackScreenState extends State<RatingFeedbackScreen> {
  double averageRating = 0.0;
  int totalReviews = 0;
  List<RatingBreakdown> ratingBreakdown = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRatingSummary();
  }

  Future<void> _fetchRatingSummary() async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      final response = await ApiService.get(
        endpoint: ApiConstants.ratingSummary,
        token: token,
      );

      if (response.success && response.data != null) {
        /// 🔴 FIX: unwrap inner `data`
        final Map<String, dynamic> data =
            response.data is Map && response.data['data'] != null
                ? response.data['data']
                : response.data;

        averageRating =
            double.tryParse(data['average_rating']?.toString() ?? '0') ?? 0.0;

        totalReviews = data['total_reviews'] ?? 0;

        final breakdownMap =
            Map<String, dynamic>.from(data['rating_breakdown'] ?? {});

        ratingBreakdown = breakdownMap.entries
            .map((e) => RatingBreakdown(
                  stars: int.tryParse(e.key.toString()) ?? 0,
                  count: e.value ?? 0,
                ))
            .toList()
          ..sort((a, b) => b.stars.compareTo(a.stars));
      }
    } catch (e) {
      debugPrint('Rating summary error: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rating Feedback',
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Rating Score',
                    style: TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// Rating Card (UI unchanged)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Row(
                              children: List.generate(
                                5,
                                (_) => Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.star,
                                    color: Colors.amber[400],
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Based on $totalReviews reviews',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Rating Breakdown',
                    style: TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ratingBreakdown.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: RatingBreakdownItem(
                          breakdown: ratingBreakdown[index],
                          totalReviews: totalReviews,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class RatingBreakdown {
  final int stars;
  final int count;

  RatingBreakdown({required this.stars, required this.count});
}

class RatingBreakdownItem extends StatelessWidget {
  final RatingBreakdown breakdown;
  final int totalReviews;

  const RatingBreakdownItem({
    super.key,
    required this.breakdown,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    final value = totalReviews == 0 ? 0.0 : breakdown.count / totalReviews;

    return Row(
      children: [
        Row(
          children: List.generate(
            breakdown.stars,
            (_) => Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(
                Icons.star,
                color: Colors.amber[400],
                size: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[400]!),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${breakdown.count}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
