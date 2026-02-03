import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaxForm {
  final String title;
  final String subtitle;
  final String fileName;

  TaxForm({
    required this.title,
    required this.subtitle,
    required this.fileName,
  });
}

class TaxDetailsView extends StatefulWidget {
  const TaxDetailsView({super.key});

  @override
  State<TaxDetailsView> createState() => _TaxDetailsViewState();
}

class _TaxDetailsViewState extends State<TaxDetailsView> {
  /// DATA WILL COME FROM API / CONTROLLER
  final List<TaxForm> taxForms = [];

  /// SUMMARY VALUES SHOULD COME FROM BACKEND
  final String grossEarnings = '--';
  final String taxWithheld = '--';
  final String deductions = '--';
  final String netEarnings = '--';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        centerTitle: false,
        title: const Text(
          'Tax Details',
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Earnings Summary',
                style: TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      label: 'Gross Earnings',
                      value: grossEarnings,
                    ),
                    const SizedBox(height: 14),
                    Divider(color: Colors.grey[300]),
                    const SizedBox(height: 14),
                    _buildSummaryRow(
                      label: 'Tax Withheld',
                      value: taxWithheld,
                    ),
                    const SizedBox(height: 14),
                    Divider(color: Colors.grey[300]),
                    const SizedBox(height: 14),
                    _buildSummaryRow(
                      label: 'Deductions',
                      value: deductions,
                    ),
                    const SizedBox(height: 14),
                    Divider(color: Colors.grey[300]),
                    const SizedBox(height: 14),
                    _buildSummaryRow(
                      label: 'Net Earnings',
                      value: netEarnings,
                      isHighlight: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Tax Forms',
                style: TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              taxForms.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No tax documents available',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: taxForms.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TaxFormItem(
                            taxForm: taxForms[index],
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? Colors.black : Colors.grey[700],
            fontSize: isHighlight ? 16 : 13,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class TaxFormItem extends StatelessWidget {
  final TaxForm taxForm;

  const TaxFormItem({
    super.key,
    required this.taxForm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.description,
              color: Color(0xFF1E3A8A),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  taxForm.title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  taxForm.subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              // TODO: connect download API
            },
            icon: const Icon(
              Icons.cloud_download,
              color: Color(0xFF1E3A8A),
              size: 24,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
