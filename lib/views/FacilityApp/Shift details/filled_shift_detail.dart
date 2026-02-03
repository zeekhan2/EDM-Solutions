import 'package:edm_solutions/config/stripe_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';

import '../../../models/shift_models.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import 'payment_success.dart';
import 'dart:math' as math;

class FilledShiftDetail extends StatefulWidget {
  const FilledShiftDetail({Key? key}) : super(key: key);

  @override
  State<FilledShiftDetail> createState() => _FilledShiftDetailState();
}

class _FilledShiftDetailState extends State<FilledShiftDetail> {
  // 0 = Awaiting | 1 = Completed | 2 = Paid
  int _tab = 1;

  final Color primary = const Color(0xFF1E3A8A);
  final Color lightBg = const Color(0xFFF6F9FF);
  final Color pillGrey = const Color(0xFFE6E6E6);
  final Color green = const Color(0xFF1E8750);

  bool loading = true;
  bool summaryLoading = false;
  bool isCardValid = false;
  bool isPaying = false;

  late Future<void> _stripeReadyFuture;

  List<Shift> awaiting = [];
  List<Shift> completed = [];
  List<Shift> paid = [];

  final Set<int> selectedIds = {};

  int selectedShiftAmountCents = 0;

  int? recipientId;
  String? paymentId;
  String? stripeErrorMessage;
  final Map<int, int> workerRatings = {};
  final Set<int> ratedWorkers = {};

  @override
  void initState() {
    super.initState();
    _stripeReadyFuture = StripeConfig.ensureReady();
    fetchFilledShiftLists();
  }

  // ==========================================================
  // FETCH SHIFTS
  // ==========================================================
  Future<void> fetchFilledShiftLists() async {
    debugPrint('🟡 fetchFilledShiftLists called');

    loading = true;
    setState(() {});

    String? token;

    for (int i = 0; i < 10; i++) {
      token = await StorageService.getToken();
      debugPrint('🔁 token attempt $i -> $token');
      if (token != null && token.isNotEmpty) break;
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (token == null) {
      debugPrint('❌ token still null, aborting filled shifts');
      loading = false;
      setState(() {});
      return;
    }

    debugPrint('✅ token ready, calling filled shifts API');

    final resp = await ApiService.get(
      endpoint: '/api/filled-shift-details',
      token: token,
    );

    debugPrint('📥 filled shifts response success=${resp.success}');
    if (resp.success == true && resp.data != null) {
      final shifts = resp.data['shifts'] ?? {};

      awaiting.clear();
      completed.clear();
      paid.clear();

      awaiting.addAll(
        (shifts['Awaiting'] ?? [])
            .map<Shift>((e) => Shift.fromJson(e))
            .toList(),
      );

      completed.addAll(
        (shifts['Completed'] ?? [])
            .map<Shift>((e) => Shift.fromJson(e))
            .toList(),
      );

      paid.addAll(
        (shifts['Paid'] ?? []).map<Shift>((e) => Shift.fromJson(e)).toList(),
      );

      for (final s in paid) {
        final int workerId = (s.filledWorkerId ?? s.id)!;
        workerRatings[workerId] = workerRatings[workerId] ?? 0;
      }
    }

    loading = false;
    setState(() {});
  }

  // ==========================================================
  // SUMMARY + PAYMENT CREATE
  // ==========================================================
  Future<void> fetchSummaryOnly(int shiftId) async {
    summaryLoading = true;
    stripeErrorMessage = null;
    selectedShiftAmountCents = 0;
    recipientId = null;
    paymentId = null;

    setState(() {});

    final token = await StorageService.getToken();
    if (token == null) return;

    final summaryResp = await ApiService.get(
      endpoint: '/api/get/complete-shift-summary/$shiftId',
      token: token,
    );

    if (summaryResp.success != true) {
      summaryLoading = false;
      setState(() {});
      return;
    }

    final data = summaryResp.data['data'];

    recipientId = data['recepient_id'];
    debugPrint('BACKEND AMOUNT RAW: ${data['total_amount']}');

    final double apiAmount = (data['total_amount'] as num).toDouble();

    selectedShiftAmountCents = (apiAmount * 100).round();

    debugPrint('BACKEND AMOUNT: $apiAmount');
    debugPrint('AMOUNT IN CENTS: $selectedShiftAmountCents');

    summaryLoading = false;
    setState(() {});
  }

  // ==========================================================
  // CONFIRM PAYMENT (AUTO MOVE)
  // ==========================================================
  Future<void> paySelected() async {
    if (selectedIds.isEmpty || recipientId == null) return;

    if (selectedShiftAmountCents <= 0) {
      setState(() {
        stripeErrorMessage = 'Invalid payment amount.';
      });
      return;
    }

    final int amountForStripe = selectedShiftAmountCents;

    if (amountForStripe < 100) {
      setState(() {
        stripeErrorMessage = 'Minimum payable amount is 1.';
      });
      return;
    }

    setState(() {
      isPaying = true;
      stripeErrorMessage = null;
    });

    final token = await StorageService.getToken();
    if (token == null) {
      setState(() => isPaying = false);
      return;
    }

    final int shiftId = selectedIds.first;

    setState(() {
      stripeErrorMessage = null;
    });

    ///  CREATE PAYMENT INTENT
    final createResp = await ApiService.post(
      endpoint: '/api/payment/create-for-worker',
      token: token,
      body: {
        'recipient_id': recipientId,
        'shift_ids': [shiftId],
        'amount': amountForStripe,
        'recipient_amount': amountForStripe,
      },
    );

    if (createResp.success != true) {
      if (createResp.data?['errors'] != null &&
          createResp.data['errors'] is List) {
        stripeErrorMessage = (createResp.data['errors'] as List).join('\n');
      } else {
        stripeErrorMessage = createResp.message ?? 'Payment creation failed';
      }

      setState(() => isPaying = false);
      return;
    }

    final paymentIntentId = createResp.data?['data']?['payment_intent_id'];

    if (paymentIntentId == null) {
      stripeErrorMessage = 'Payment intent not received from server';
      setState(() => isPaying = false);
      return;
    }

    /// CREATE STRIPE PAYMENT METHOD (from CardField)
    late PaymentMethod paymentMethod;

    try {
      paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
    } on StripeException catch (e) {
      stripeErrorMessage = e.error.message ?? 'Stripe error occurred';
      setState(() => isPaying = false);
      return;
    }

    final paymentMethodId = paymentMethod.id;

    ///  CONFIRM PAYMENT (THIS WAS NOT RUNNING BEFORE)
    final confirmResp = await ApiService.post(
      endpoint: '/api/payment/confirm',
      token: token,
      body: {
        'payment_intent_id': paymentIntentId,
        'payment_method_id': paymentMethodId,
      },
    );

    if (confirmResp.success != true) {
      stripeErrorMessage = confirmResp.message ?? 'Payment confirmation failed';
      setState(() => isPaying = false);
      return;
    }

    final paidShift = completed.firstWhere((s) => s.id == shiftId);
    completed.removeWhere((s) => s.id == shiftId);
    paid.insert(0, paidShift);

    selectedIds.clear();
    selectedShiftAmountCents = 0;

    setState(() {
      _tab = 2;
    });

    Get.snackbar(
      'Payment Successful',
      'Shift payment completed successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    setState(() => isPaying = false);
    Get.to(() => const PaymentSuccessScreen());
  }

  // ==========================================================
  // SUBMIT WORKER RATING
  // ==========================================================
  Future<void> submitRating(int workerId, int rating) async {
    final token = await StorageService.getToken();
    if (token == null) return;

    await ApiService.post(
      endpoint: '/api/submit/reviews',
      token: token,
      body: {
        'worker_id': workerId,
        'rating': rating,
      },
    );

    ratedWorkers.add(workerId); // 🔒 disable after submit
  }

  // ==========================================================
  // UI HELPERS
  // ==========================================================
  Widget pill(String text, int i) {
    final active = _tab == i;
    return GestureDetector(
      onTap: () => setState(() => _tab = i),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? primary : pillGrey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
              color: active ? Colors.white : Colors.black54,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget shiftCard(Shift s, {bool selectable = false}) {
    final selected = selectedIds.contains(s.id);
    final int workerId = (s.filledWorkerId ?? s.id)!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lightBg,
        borderRadius: BorderRadius.circular(16),
        border: selected ? Border.all(color: primary, width: 1.5) : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: s.filledWorkerImage != null
                    ? NetworkImage(s.filledWorkerImage!)
                    : null,
                backgroundColor: Colors.orange,
                child: s.filledWorkerImage == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.title ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      s.filledWorkerName ?? '',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 2),
                    Text(s.dutyTime ?? '',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black45)),
                    const SizedBox(height: 4),
                    Text(
                      _tab == 0
                          ? 'Status : In Progress'
                          : _tab == 2
                              ? 'Payment : Paid'
                              : 'Result : Completed',
                      style: TextStyle(
                          fontSize: 12,
                          color: _tab == 2 ? Colors.green : Colors.blue),
                    ),
                  ],
                ),
              ),
              if (selectable)
                Checkbox(
                  value: selected,
                  onChanged: (_) async {
                    selectedIds.clear();
                    selectedIds.add(s.id!);
                    await fetchSummaryOnly(s.id!);
                  },
                ),
            ],
          ),

          /// Rating (Paid only, disabled after submit)
          if (_tab == 2)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final current = workerRatings[workerId] ?? 0;
                  final locked = ratedWorkers.contains(workerId);

                  return IconButton(
                    icon: Icon(
                      Icons.star,
                      color: i < current ? Colors.amber : Colors.grey,
                    ),
                    onPressed: locked
                        ? null
                        : () {
                            workerRatings[workerId] = i + 1;
                            setState(() {});
                            submitRating(workerId, i + 1);
                          },
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget summaryBox(String value, String label, {bool highlight = false}) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(16),
        border: highlight ? Border.all(color: primary) : null,
      ),
      child: Column(
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _cardDetailsUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payroll Processing',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        FutureBuilder(
          future: _stripeReadyFuture, // ✅ cached future
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 48,
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            return SizedBox(
              child: CardField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onCardChanged: (card) {
                  setState(() {
                    isCardValid = card?.complete ?? false;
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Filled Shift Details',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        pill('Awaiting', 0),
                        const SizedBox(width: 8),
                        pill('Completed', 1),
                        const SizedBox(width: 8),
                        pill('Paid', 2),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _tab == 0
                            ? awaiting.isEmpty
                                ? const Center(
                                    child: Text('No awaiting shifts'))
                                : Column(
                                    children: awaiting
                                        .map((s) => shiftCard(s))
                                        .toList(),
                                  )
                            : _tab == 1
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ...completed.map(
                                        (s) => shiftCard(s, selectable: true),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text('Weekly Summary',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          summaryBox(
                                              selectedIds.length.toString(),
                                              'Shifts'),
                                          const SizedBox(width: 12),
                                          summaryBox(
                                            '\$${(selectedShiftAmountCents / 100).toStringAsFixed(2)}',
                                            'Total',
                                            highlight: true,
                                          ),
                                        ],
                                      ),
                                      if (stripeErrorMessage != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Text(stripeErrorMessage!,
                                              style: const TextStyle(
                                                  color: Colors.red)),
                                        ),
                                      const SizedBox(height: 20),
                                      _cardDetailsUI(),
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: selectedIds.isEmpty ||
                                                  !isCardValid ||
                                                  isPaying
                                              ? null
                                              : paySelected,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: green,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            transitionBuilder: (child,
                                                    animation) =>
                                                FadeTransition(
                                                    opacity: animation,
                                                    child: child),
                                            child: isPaying
                                                ? const Text(
                                                    'Processing…',
                                                    key: ValueKey(1),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16),
                                                  )
                                                : const Text(
                                                    'Confirm & pay',
                                                    key: ValueKey(2),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : paid.isEmpty
                                    ? const Center(
                                        child: Text('No paid shifts'))
                                    : Column(
                                        children: paid
                                            .map((s) => shiftCard(s))
                                            .toList(),
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

class DotsLoader extends StatefulWidget {
  const DotsLoader({Key? key}) : super(key: key);

  @override
  State<DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<DotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final value =
                (math.sin(_controller.value * 2 * math.pi + i) + 1) / 2;
            return Transform.scale(
              scale: 0.6 + value * 0.6,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Colors.white,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
