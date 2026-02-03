import 'package:flutter/material.dart';


class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<FAQItem> faqItems = [
    FAQItem(
      question: 'How do I clock in for my shift?',
      answer:
          'To clock in for your shift, open the app and navigate to the Time Sheet section. Tap the "Clock In" button at the start of your shift. Make sure your location services are enabled for accurate tracking.',
      isExpanded: false,
    ),
    FAQItem(
      question: 'When will I receive my payment?',
      answer:
          'Payments are processed weekly on Fridays. The amount depends on your hours worked and any applicable deductions. You can view your payment details in the Payment section.',
      isExpanded: false,
    ),
    FAQItem(
      question: 'How do I update my credentials?',
      answer:
          'You can update your credentials in the Credentials & Compliance section. Upload new documents or re-upload existing ones. Your supervisor will review and approve the updates.',
      isExpanded: false,
    ),
    FAQItem(
      question: 'What if I forget my password?',
      answer:
          'On the login page, click "Forgot Password?" and enter your email address. You will receive a password reset link via email. Follow the link to create a new password.',
      isExpanded: false,
    ),
    FAQItem(
      question: 'How do I contact my supervisor?',
      answer:
          'You can contact your supervisor through the messaging feature in the app. Tap on their profile and select "Send Message" to start a conversation.',
      isExpanded: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: false,
        title: const Text(
          'Help & Support',
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
              // Contact Us Section
              const Text(
                'Contact Us',
                style: TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Email Support
              _buildContactItem(
                icon: Icons.email_outlined,
                title: 'Email Support',
                subtitle: 'support@example.com',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening email client...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Help Center
              _buildContactItem(
                icon: Icons.help_outline,
                title: 'Help Center',
                subtitle: 'Browse articles and guides',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening Help Center...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Frequently Asked Questions Section
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // FAQ Items
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: faqItems.length,
                itemBuilder: (context, index) {
                  return FAQItemWidget(
                    faqItem: faqItems[index],
                    onTap: () {
                      setState(() {
                        faqItems[index].isExpanded =
                            !faqItems[index].isExpanded;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
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
              child: Icon(
                icon,
                color: const Color(0xFF1E3A8A),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  bool isExpanded;

  FAQItem({
    required this.question,
    required this.answer,
    required this.isExpanded,
  });
}

class FAQItemWidget extends StatelessWidget {
  final FAQItem faqItem;
  final VoidCallback onTap;

  const FAQItemWidget({
    super.key,
    required this.faqItem,
    required this.onTap,
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
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        faqItem.question,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      faqItem.isExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                  ],
                ),
                if (faqItem.isExpanded) ...[
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    faqItem.answer,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
