import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/ui/custom_appbar.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Terms & Conditions',
          titleColor: AppColors.textColor
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Terms of Service",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Last Updated: 2025\n\nWelcome to NubesSIM! Please read these Terms carefully as they form a legal agreement between you (the “User”) and ALPHA TELEVOICE LTD (“NubesSIM”). By using our services, you agree to these Terms.",
                style: TextStyle(fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 16),
              _buildHeading("1. General Validity of the Terms"),
              _buildText(
                "1.1 These Terms are a legally binding agreement between you and NubesSIM.\n"
                "1.2 By registering, purchasing, or using our services, you agree to these Terms fully.\n"
                "1.3 If you do not agree, you may not use our services.",
              ),
              _buildHeading("2. Description of Services"),
              _buildSubHeading("2.1 Use of Services"),
              _buildText(
                "NubesSIM offers flexible eSIM plans for international travelers. You can select, purchase, and activate plans through the NubesSIM app or website. Payments are processed securely via Apple Pay or Stripe.",
              ),
              _buildSubHeading("2.2 Registration"),
              _buildText(
                "To register, you must provide:\n- Nickname\n- Email address",
              ),
              _buildSubHeading("2.3 User Responsibilities"),
              _buildText(
                "Users must comply with all laws and avoid:\n- Fraud or illegal activity\n- Interfering with NubesSIM’s network.\nViolation may result in suspension or termination without notice.",
              ),
              _buildHeading("3. Contract & Termination"),
              _buildText(
                "The contract starts when you place an order and ends when your plan expires. NubesSIM may terminate services for any violations or fraudulent activities.",
              ),
              _buildHeading("4. Fees and Payment"),
              _buildSubHeading("4.1 Payment Terms"),
              _buildText(
                "Payments can be made via credit card or Apple Pay in USD. Transactions are securely processed by Stripe or Apple Pay.",
              ),
              _buildSubHeading("4.2 Usage Fees"),
              _buildText(
                "All fees include applicable taxes. Disputes must be submitted within 5 business days.",
              ),
              _buildSubHeading("4.3 eSIM Delivery"),
              _buildText(
                "Your purchased eSIM will appear under 'My eSIM' in your account for immediate activation.",
              ),
              _buildSubHeading("4.4 NubesSIM Credit"),
              _buildText(
                "Credits can be used for purchases, are non-refundable, and cannot be exchanged for cash.",
              ),
              _buildHeading("5. Refund & Cancellation Policy"),
              _buildText(
                "Refunds are only available for technical issues caused by NubesSIM. Requests must be made within 30 days and require cooperation in troubleshooting. Plans are non-transferable and non-refundable once activated.",
              ),
              _buildHeading("6. Privacy Policy"),
              _buildText(
                "We protect your data and use it only for providing services. You may unsubscribe from marketing emails anytime.",
              ),
              _buildHeading("7. Disclaimer"),
              _buildText(
                "We are not responsible for service interruptions due to network issues, force majeure, or device problems.",
              ),
              _buildHeading("8. Fair Usage Policy"),
              _buildText(
                "Misuse or abnormal data consumption may result in restrictions. Reselling or modifying our services is prohibited.",
              ),
              _buildHeading("9. Liability"),
              _buildText(
                "We do not guarantee uninterrupted service and are not liable for losses caused by compatibility issues or errors.",
              ),
              _buildHeading("10. Acceptable Use & Prohibited Activities"),
              _buildText(
                "You must follow all applicable laws and avoid illegal or harmful activities. Violations may lead to account termination and legal action.",
              ),
              _buildHeading("11. Governing Law"),
              _buildText(
                "These Terms follow the laws of Ontario, Canada. Disputes will be resolved via arbitration at ICDR.",
              ),
              _buildHeading("12. Updates"),
              _buildText(
                "We may update these Terms at any time. Continued use of our services means you accept the updated Terms.",
              ),
              _buildHeading("13. Contact Us"),
              _buildText(
                "Email: service@NubesSIM.com\nAddress: 702-1 Concorde Gate, North York, ON M3C 3N6, Canada",
              ),
            ],
          ),
        ),
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
