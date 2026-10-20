import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/ui/custom_appbar.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Privacy Policy',
          titleColor: AppColors.textColor,
        ),
        body: const PrivacyPolicyContent(),
      ),
    );
  }
}

class PrivacyPolicyContent extends StatelessWidget {
  const PrivacyPolicyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Privacy Policy",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Last Updated: 2025\n\nWe at NubesSIM value your privacy and are committed to protecting your personal information. This policy explains what data we collect, how we use it, and the choices you have. By using our services, you agree to this Privacy Policy.",
            style: TextStyle(fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 16),
          _buildHeading("1. What Information Do We Collect?"),
          _buildSubHeading("1.1 Personally Identifiable Information"),
          _buildText(
            "We collect personal details like your name, email, and phone number when you register, create an account, or contact us. This helps us provide and improve our services.",
          ),
          _buildSubHeading("1.2 Sensitive Information"),
          _buildText(
            "Please do not share sensitive data like social security numbers or health information. If you do, you consent to us processing it as outlined here.",
          ),
          _buildSubHeading("1.3 Non-Personal Information"),
          _buildText(
            "We also collect non-personal data such as IP address, device type, location, and browsing activity to improve user experience and optimize our services.",
          ),
          _buildHeading("2. How Do We Use Your Information?"),
          _buildText(
            "We use your data to:\n"
            "- Deliver and improve our services\n"
            "- Manage your account and process payments\n"
            "- Send important updates and security alerts\n"
            "- Provide customer support\n"
            "- Send marketing emails (with your consent)",
          ),
          _buildHeading("3. Disclosure of Information"),
          _buildText(
            "We do not sell your personal data. We may share it only when:\n"
            "- Required by law\n"
            "- Needed to provide services\n"
            "- To protect our rights and prevent fraud\n"
            "- In case of a merger or acquisition (with confidentiality)",
          ),
          _buildHeading("4. Children's Privacy"),
          _buildText(
            "Our services are for users 18+. We do not knowingly collect data from children under 13. If we find such data, we delete it immediately.",
          ),
          _buildHeading("5. International Data Use"),
          _buildText(
            "Your data may be processed in countries with different privacy laws. We ensure third-party partners follow strict confidentiality agreements.",
          ),
          _buildHeading("6. Updating Your Information"),
          _buildText(
            "You can contact us at service@NubesSIM.com to update, correct, or delete your information.",
          ),
          _buildHeading("7. Security"),
          _buildText(
            "We use SSL encryption and industry-standard measures to protect your data. However, no system is 100% secure. Please keep your account password safe.",
          ),
          _buildHeading("8. Changes to This Policy"),
          _buildText(
            "We may update this policy at any time. Changes will be posted on our website or app. Continued use of our services means you accept the updated policy.",
          ),
          const SizedBox(height: 16),
          const Text(
            "For questions, contact us: service@NubesSIM.com",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildHeading(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSubHeading(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, height: 1.6),
    );
  }
}
