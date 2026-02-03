import 'dart:io';
import 'dart:math';
import 'package:edm_solutions/controllers/report_stats_controller.dart';
import '../../../controllers/facility_dashboard_controller.dart';
import 'package:edm_solutions/views/FacilityApp/Report/staff_attendance_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edm_solutions/consts/consts.dart';
import 'package:edm_solutions/Common_Widgets/safe_snackbar_helper.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:edm_solutions/services/storage_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportStatsController reportStatsController =
      Get.find<ReportStatsController>();

  final FacilityDashboardController dashboardController =
      Get.find<FacilityDashboardController>();

  // 0 = Analytics, 1 = Billing
  int _tabIndex = 0;

  // selected export range
  String _selectedRange = 'This Month';
  final List<String> _ranges = [
    'This Month',
    'Last 3 Months',
    'Last 6 Months',
    'Last Year',
    'Custom'
  ];

  @override
  void initState() {
    super.initState();
    reportStatsController.fetchReportStats();
  }

  /// ✅ FIX: resolve relative image path to full URL
  String? _resolveImageUrl(String? image) {
    if (image == null || image.isEmpty) return null;
    if (image.startsWith('http')) return image;
    return 'https://admin.edmsolutions.org/storage/$image';
  }

  double get totalCost => reportStatsController.totalCost.value;
  int get totalShifts => reportStatsController.totalShifts.value;
  double get avgRate => reportStatsController.avgRate.value;
  double get pending => reportStatsController.pendingAmount.value;
  int get totalCostChange => reportStatsController.totalCostChange.value;

  int get totalShiftsChange => reportStatsController.totalShiftsChange.value;

  String get pendingNextDate => reportStatsController.nextPaymentDate.value;

  List<int> get monthly => reportStatsController.monthlyShifts;
  Map<String, int> get byDept => reportStatsController.costByDepartment;
  Map<String, int> get roleCounts => reportStatsController.roleDistribution;

  TextStyle get _titleStyle => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFamily: semibold,
      );

  List<String> get monthlyLabels => reportStatsController.monthlyLabels;

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
            /// ✅ FIXED FACILITY IMAGE
            Obx(() {
              final rawImage = dashboardController.facilityImage.value;
              final imageUrl = _resolveImageUrl(rawImage);

              return CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                backgroundImage:
                    imageUrl != null ? NetworkImage(imageUrl) : null,
                child: imageUrl == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              );
            }),

            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontFamily: regular,
                  ),
                ),
                Obx(() => Text(
                      dashboardController.facility_name.value.isEmpty
                          ? '—'
                          : dashboardController.facility_name.value,
                      style: _titleStyle,
                    )),
              ],
            ),
          ],
        ),
      ),

      // Entire page is now scrollable
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // top filters row (This Month dropdown + Export)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _openRangeMenu,
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.filter_list,
                                color: Color(0xFF1F3C88)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedRange,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontFamily: regular,
                                ),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_outlined)
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => _exportReportAsPdf(_selectedRange),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.file_download_outlined,
                              color: Color(0xFF1F3C88)),
                          SizedBox(width: 8),
                          Text('Export'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // summary cards grid (2x2)
              Obx(() => Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          'Total Cost',
                          '\$${_formatMoney(reportStatsController.totalCost.value)}',
                          '${reportStatsController.totalCostChange.value}%',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          'Total Shifts',
                          '${reportStatsController.totalShifts.value}',
                          reportStatsController.totalShiftsChange.value == 0
                              ? 'No change'
                              : '${reportStatsController.totalShiftsChange.value > 0 ? '+' : ''}${reportStatsController.totalShiftsChange.value}%',
                        ),
                      ),
                    ],
                  )),

              const SizedBox(height: 12),
              Obx(() => Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          'Avg Rate',
                          '\$${reportStatsController.avgRate.value.toStringAsFixed(2)}/shift',
                          '—',
                          small: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          'Pending',
                          '\$${_formatMoney(reportStatsController.pendingAmount.value)}',
                          reportStatsController.nextPaymentDate.value.isEmpty
                              ? 'No due date'
                              : reportStatsController.nextPaymentDate.value,
                          small: true,
                        ),
                      ),
                    ],
                  )),

              const SizedBox(height: 14),

              // big attendance logs CTA
              GestureDetector(
                onTap: () {
                  Get.to(() => const StaffAttendanceDetails());
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04), blurRadius: 6)
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Staff Attendance Logs',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16)),
                              const SizedBox(height: 6),
                              Text('View Details check in out times of Staff',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontFamily: regular)),
                            ]),
                      ),
                      const Icon(Icons.arrow_forward, color: Colors.white)
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Tabs (Analytics / Billing)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    _tabButton('Analytics', 0),
                    _tabButton('Billing', 1),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Tab content (scrollable within the full page)
              if (_tabIndex == 0) ...[
                _analyticsView()
              ] else ...[
                _billingView()
              ],
            ],
          ),
        ),
      ),
    );
  }

  // small helper to format money like 194,000
  String _formatMoney(double v) {
    final n = v.round();
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final pos = s.length - i;
      buf.write(s[i]);
      if (pos > 1 && pos % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }

  // stat card widget
  Widget _statCard(String title, String value, String smallText,
      {bool small = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontFamily: semibold)),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
        const SizedBox(height: 8),
        Text(smallText,
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  // styled tab button
  Widget _tabButton(String label, int index) {
    final bool active = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Text(
            label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: active ? AppColors.primary : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  // ----------------------------
  // Analytics View
  // ----------------------------
  Widget _analyticsView() {
    return Column(
      children: [
        // Monthly shifts filled (line chart placeholder)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Monthly Shifts Filled',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: _LineChartPainter(
                  points: monthly,
                  color: AppColors.primary,
                  months: monthlyLabels,
                ),
                size: const Size(double.infinity, 200),
              ),
            ),
          ]),
        ),

        const SizedBox(height: 12),

        // Cost by department (bar chart placeholder)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Cost by Department',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: CustomPaint(
                painter:
                    _BarChartPainter(data: byDept, color: AppColors.primary),
                size: const Size(double.infinity, 220),
              ),
            ),
          ]),
        ),

        const SizedBox(height: 12),

        // Pie distribution
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Staff Role Distribution',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: Row(
                children: [
                  Expanded(
                    child: CustomPaint(
                      painter: _PieChartPainter(
                        data: roleCounts,
                        colors: List.generate(
                          roleCounts.length,
                          (_) => AppColors.primary,
                        ),
                      ),
                      size: const Size(180, 180),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: _legend(roleCounts),
                    ),
                  )
                ],
              ),
            ),
          ]),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _legend(Map<String, int> d) {
    final total = d.values.fold<int>(0, (a, b) => a + b);
    final entries = d.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries.map((e) {
        final pct = ((e.value / (total == 0 ? 1 : total)) * 100).round();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.primary, // ✅ no role-based logic
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('${e.key}: ${e.value}',
                      style: const TextStyle(fontWeight: FontWeight.w600))),
              Text('$pct%', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ----------------------------
  // Billing View
  // ----------------------------
  Widget _billingView() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Billing Summary',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _keyValRow('Total Paid:', '\$${_formatMoney(totalCost)}'),
              const SizedBox(height: 6),
              _keyValRow('Pending:', '\$${_formatMoney(pending)}'),
              const SizedBox(height: 6),
              _keyValRow('Completed Shifts:', '$totalShifts'),
              const SizedBox(height: 12),
              Text(
                'Invoices are managed by EDM Admin. For billing inquiries, please contact support.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _invoiceCard(Map<String, dynamic> inv) {
    final bool isPaid = inv['status'] == 'Paid';

    // Gradient "Total Amount" as requested (bigger width & pill)
    final totalAmountButton = GestureDetector(
      onTap: () {
        SafeSnackbarHelper.showSafeSnackbar(
            title: 'Total Amount',
            message: '\$${inv['amount'].toStringAsFixed(2)}');
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF2F6BDD),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total Amount',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          Text('\$${(inv['amount'] as double).toStringAsFixed(2)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16)),
        ]),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(inv['id'],
                  style: const TextStyle(fontWeight: FontWeight.w700))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                color:
                    isPaid ? const Color(0xFFDFF6EB) : const Color(0xFFFFF6DB),
                borderRadius: BorderRadius.circular(14)),
            child: Text(inv['status'],
                style: TextStyle(
                    color: isPaid
                        ? const Color(0xFF20A84A)
                        : const Color(0xFFB88700))),
          )
        ]),
        const SizedBox(height: 6),
        Text(inv['period'], style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border)),
          child: Column(children: [
            _keyValRow('Total Shifts:', inv['shifts'].toString()),
            const SizedBox(height: 6),
            _keyValRow('Total Hours:', '${inv['hours']} hrs'),
            const SizedBox(height: 6),
            _keyValRow('Due Date:', inv['due']),
          ]),
        ),
        const SizedBox(height: 12),
        totalAmountButton,
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _downloadInvoice(inv),
                icon: const Icon(Icons.file_download_outlined, size: 18),
                label: const Text('Download Invoice'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _keyValRow(String k, String v) {
    return Row(
      children: [
        Expanded(
            child: Text(k, style: TextStyle(color: AppColors.textSecondary))),
        Text(v, style: const TextStyle(fontWeight: FontWeight.w700))
      ],
    );
  }

  // ----------------------------
  // PDF + Export helpers
  // ----------------------------

  /// Create a basic PDF summary for the chosen range and share/save it.
  Future<void> _exportReportAsPdf(String range) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(18),
          build: (pw.Context ctx) {
            return [
              pw.Header(
                  level: 0,
                  child: pw.Text('EDM Report — $range',
                      style: pw.TextStyle(fontSize: 20))),
              pw.SizedBox(height: 8),
              pw.Text('Summary',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(context: ctx, data: <List<String>>[
                <String>['Metric', 'Value'],
                <String>['Total Cost', '\$${_formatMoney(totalCost)}'],
                <String>['Total Shifts', '$totalShifts'],
                <String>['Avg Rate', '\$${avgRate.toStringAsFixed(2)}/hr'],
                <String>['Pending', '\$${_formatMoney(pending)}'],
              ]),
              pw.SizedBox(height: 12),
              pw.Text('Monthly Points',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Bullet(text: 'Points: ${monthly.join(', ')}'),
              pw.SizedBox(height: 12),
              pw.Text('Cost by Department',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Column(
                  children: byDept.entries
                      .map((e) => pw.Text(
                          '${e.key}: ${_formatMoney(e.value.toDouble())}'))
                      .toList()),
            ];
          },
        ),
      );

      final bytes = await pdf.save();

      // Save to app documents directory
      final dir = await getApplicationDocumentsDirectory();
      final filename =
          'EDM_Report_${range.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);

      // Use printing package to show share/save dialog (cross-platform)
      await Printing.sharePdf(bytes: bytes, filename: filename);

      SafeSnackbarHelper.showSafeSnackbar(
          title: 'Exported',
          message: 'Report saved and ready to share: $filename');
    } catch (e, st) {
      SafeSnackbarHelper.showSafeSnackbar(
          title: 'Export failed', message: e.toString());
      debugPrint('PDF export error: $e\n$st');
    }
  }

  /// Create a PDF invoice for a single invoice entry and share/save it.
  Future<void> _downloadInvoice(Map<String, dynamic> inv) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(24),
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Invoice: ${inv['id']}',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text(inv['period'], style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 12),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300)),
                  child: pw.Column(children: [
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Total Shifts:'),
                          pw.Text('${inv['shifts']}')
                        ]),
                    pw.SizedBox(height: 6),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Total Hours:'),
                          pw.Text('${inv['hours']} hrs')
                        ]),
                    pw.SizedBox(height: 6),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Due Date:'),
                          pw.Text('${inv['due']}')
                        ]),
                  ]),
                ),
                pw.Spacer(),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(
                      vertical: 12, horizontal: 10),
                  color: PdfColors.blue900,
                  child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Amount',
                            style: pw.TextStyle(color: PdfColors.white)),
                        pw.Text('\$${inv['amount'].toStringAsFixed(2)}',
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold))
                      ]),
                ),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();

      final dir = await getApplicationDocumentsDirectory();
      final filename =
          '${inv['id']}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);

      await Printing.sharePdf(bytes: bytes, filename: filename);

      SafeSnackbarHelper.showSafeSnackbar(
          title: 'Downloaded', message: 'Invoice saved: $filename');
    } catch (e, st) {
      SafeSnackbarHelper.showSafeSnackbar(
          title: 'Download failed', message: e.toString());
      debugPrint('Invoice download error: $e\n$st');
    }
  }

  // show a menu for range selection
  void _openRangeMenu() async {
    final res = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (ctx) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _ranges.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, idx) {
              final r = _ranges[idx];
              return ListTile(
                title: Text(r),
                onTap: () => Navigator.of(ctx).pop(r),
              );
            },
          ),
        );
      },
    );

    if (res != null) {
      setState(() => _selectedRange = res);
      reportStatsController.fetchReportStats(range: res);
    }
  }
}

/// ------------------------
/// Small painters for charts (improved to match screenshots)
/// ------------------------

class _LineChartPainter extends CustomPainter {
  final List<int> points;
  final Color color;
  final List<String> months;
  _LineChartPainter(
      {required this.points, required this.color, required this.months});

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = Colors.grey.withOpacity(0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final paintLine = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    final paintDot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final paintDotBorder = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // draw horizontal grid lines (5) and y-axis labels
    final int gridCount = 4;
    final stepY = size.height / (gridCount + 1);
    final maxP =
        points.isEmpty ? 1 : points.reduce((a, b) => a > b ? a : b).toDouble();
    final minP =
        points.isEmpty ? 0 : points.reduce((a, b) => a < b ? a : b).toDouble();

    // Compute nice tick values similar to screenshot (0,85,170,255,340)
    // We'll create 5 ticks including 0 and max.
    final ticks = <double>[];
    final tickCount = 5;
    for (int i = 0; i < tickCount; i++) {
      ticks.add(minP + (maxP - minP) * i / (tickCount - 1));
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < tickCount; i++) {
      final y = size.height - (i * (size.height / (tickCount - 1)));
      // horizontal grid
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);

      // y label
      final label = ticks[i].round().toString();
      textPainter.text = TextSpan(
          text: label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12));
      textPainter.layout();
      textPainter.paint(canvas, Offset(-40, y - textPainter.height / 2));
    }

    if (points.isEmpty) return;

    final range = (maxP - minP) == 0 ? 1 : (maxP - minP);
    final gap = size.width / (points.length - 1);

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = i * gap;
      final normalized = (points[i] - minP) / range;
      final y = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      // dots: white center + colored border
      canvas.drawCircle(Offset(x, y), 5, paintDot);
      canvas.drawCircle(Offset(x, y), 5, paintDotBorder);
    }
    canvas.drawPath(path, paintLine);

    // X axis labels (months) under the chart
    for (int i = 0; i < months.length && i < points.length; i++) {
      final x = i * gap;
      textPainter.text = TextSpan(
          text: months[i],
          style: TextStyle(color: Colors.grey.shade700, fontSize: 12));
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(x - textPainter.width / 2, size.height + 8));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BarChartPainter extends CustomPainter {
  final Map<String, int> data;
  final Color color;
  _BarChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = Colors.grey.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final paintBar = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final stepY = size.height / 5;
    // horizontal grid lines
    for (int i = 0; i <= 5; i++) {
      final y = i * stepY;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    if (data.isEmpty) return;

    final maxVal = data.values.reduce((a, b) => a > b ? a : b).toDouble();
    final barWidth = size.width / (data.length * 1.8);
    double x = barWidth / 2;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // find a reasonable left axis label step value
    final tickCount = 4;
    for (int i = 0; i <= tickCount; i++) {
      final y = size.height - (i * (size.height / tickCount));
      final val = (maxVal * i / tickCount).round();
      // draw left value label
      textPainter.text = TextSpan(
          text: val.toString(),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 11));
      textPainter.layout();
      textPainter.paint(canvas, Offset(-42, y - textPainter.height / 2));
    }

    final entries = data.entries.toList();
    for (int idx = 0; idx < entries.length; idx++) {
      final k = entries[idx].key;
      final v = entries[idx].value;
      final h = (v / maxVal) * size.height;
      final rect = Rect.fromLTWH(x, size.height - h, barWidth, h);
      canvas.drawRect(rect, paintBar);

      // label under bar
      textPainter.text = TextSpan(
          text: k, style: TextStyle(color: Colors.grey.shade800, fontSize: 12));
      textPainter.layout();
      final labelX = x + barWidth / 2 - textPainter.width / 2;
      textPainter.paint(canvas, Offset(labelX, size.height + 6));

      x += barWidth * 1.8;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PieChartPainter extends CustomPainter {
  final Map<String, int> data;
  final List<Color> colors;
  _PieChartPainter({required this.data, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final total = data.values.fold<int>(0, (a, b) => a + b);

    // ✅ FIX: prevent division by zero
    if (total == 0) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..style = PaintingStyle.fill;

    double start = -90 * 3.1415926535 / 180;
    int i = 0;

    data.forEach((_, v) {
      if (v <= 0) return;

      final sweep = (v / total) * 2 * 3.1415926535;
      paint.color = colors[i % colors.length];
      canvas.drawArc(rect, start, sweep, true, paint);
      start += sweep;
      i++;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
