import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const Color brandBlue = Color(0xFF1E3A8A);

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
        centerTitle: true,
        title: const Text(
          'About',
          style: TextStyle(
            color: brandBlue,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ================= LOGO =================
            Container(
  width: 96,
  height: 96,
  decoration: BoxDecoration(
    color: brandBlue,
    borderRadius: BorderRadius.circular(18),
  ),
  alignment: Alignment.center,
  child: Image.asset(
    'assets/images/Logo.png',
    width: 64,
    height: 64,
    fit: BoxFit.contain,
  ),
),

            const SizedBox(height: 16),

            const Text(
              'EDM Solutions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Version 2.1.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 32),

            // ================= MISSION =================
            _sectionTitle('Our Mission'),
            const SizedBox(height: 12),
            Text(
              'EDM Solutions empowers workers and businesses across multiple industries. '
              'We simplify workforce and shift management by connecting professionals '
              'with organizations through a secure and easy-to-use digital platform.',
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 32),

            // ================= STATS =================
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.groups,
                    value: '50K+',
                    label: 'Active\nWorkers',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.apartment,
                    value: '1,000+',
                    label: 'Businesses &\nOrganizations',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ================= WHAT WE OFFER =================
            _sectionTitle('What We Offer'),
            const SizedBox(height: 16),
            _buildFeatureItem(
              icon: Icons.schedule,
              title: 'Flexible Work Opportunities',
              subtitle: 'Choose shifts that fit your lifestyle',
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              icon: Icons.business_center,
              title: 'Efficient Workforce Management',
              subtitle: 'Post jobs, approve workers, track performance',
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              icon: Icons.insights,
              title: 'Real-Time Insights',
              subtitle: 'Monitor attendance and shift activity',
            ),

            const SizedBox(height: 32),

            // ================= COMPANY INFO =================
            _sectionTitle('Company Information'),
            const SizedBox(height: 16),
            _buildInfoRow(label: 'Company Name', value: 'EDM Solutions'),
            const SizedBox(height: 12),
            _buildInfoRow(label: 'Founded', value: '2018'),
            const SizedBox(height: 12),
            _buildInfoRow(label: 'Headquarters', value: 'New York, NY'),

            const SizedBox(height: 32),

            // ================= SOCIAL =================
            _sectionTitle('Connect With Us'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(Icons.language, brandBlue),
                const SizedBox(width: 16),
                _buildSocialButton(Icons.business, const Color(0xFF0A66C2)),
                const SizedBox(width: 16),
                _buildSocialButton(Icons.public, const Color(0xFF1877F2)),
              ],
            ),

            const SizedBox(height: 24),

            // ================= COPYRIGHT =================
            Text(
              '© 2024 EDM Solutions.\nAll rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.6,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: brandBlue,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: brandBlue, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: brandBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening link...')),
        );
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
