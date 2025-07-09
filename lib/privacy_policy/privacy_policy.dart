import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LegalPagesController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final RxInt selectedIndex = 0.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class LegalPagesScreen extends StatelessWidget {
  const LegalPagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LegalPagesController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Legal Information',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildTabButton(0, 'Privacy Policy', controller),
                _buildTabButton(1, 'User Terms', controller),
                _buildTabButton(2, 'Merchant Terms', controller),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              switch (controller.selectedIndex.value) {
                case 0:
                  return _buildPrivacyPolicy(controller);
                case 1:
                  return _buildUserTerms(controller);
                case 2:
                  return _buildMerchantTerms(controller);
                default:
                  return _buildPrivacyPolicy(controller);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
      int index, String title, LegalPagesController controller) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedIndex.value == index;
        return InkWell(
          onTap: () => controller.changeTab(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? Colors.black : Colors.grey.shade300,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPrivacyPolicy(LegalPagesController controller) {
    return Scrollbar(
      controller: controller.scrollController,
      child: SingleChildScrollView(
        controller: controller.scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lanza Vouchers – Privacy Policy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().toLocal().toString().split(' ')[0]}',
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This policy explains how we collect, use, and protect your personal data in compliance with the EU General Data Protection Regulation (GDPR).',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Who We Are',
              'Lanza Vouchers is operated by [Your Legal Entity Name]. You can contact us at: [Insert Email].',
            ),
            _buildSection(
              '2. What Data We Collect',
              'We may collect:',
              bulletPoints: [
                'Name, email, and contact details',
                'Purchase and voucher redemption history',
                'Location data (optional if user gives permission)',
                'Communication with our support team',
              ],
            ),
            _buildSection(
              '3. Why We Use Your Data',
              '',
              bulletPoints: [
                'To process your voucher purchases',
                'To send you confirmation emails or updates',
                'To improve our services',
                'To comply with legal obligations',
              ],
            ),
            _buildSection(
              '4. Legal Basis for Processing',
              '',
              bulletPoints: [
                'Contractual necessity (processing purchases)',
                'Consent (for marketing communications)',
                'Legal obligation (e.g., tax records)',
              ],
            ),
            _buildSection(
              '5. Sharing Your Data',
              'We may share your data with:',
              bulletPoints: [
                'Merchants (to fulfil your voucher)',
                'Payment processors (e.g. Stripe)',
                'Legal authorities, if required',
              ],
              additionalText: 'We do not sell your data.',
            ),
            _buildSection(
              '6. Data Retention',
              'We retain data only as long as necessary for the purpose it was collected and as required by law.',
            ),
            _buildSection(
              '7. Your Rights',
              'Under GDPR, you have the right to:',
              bulletPoints: [
                'Access your data',
                'Correct inaccurate data',
                'Request deletion (where applicable)',
                'Withdraw consent at any time',
                'Lodge a complaint with a Data Protection Authority',
              ],
            ),
            _buildSection(
              '8. Cookies',
              'We use cookies to enhance functionality and analyse site usage. See our separate Cookie Policy for details.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTerms(LegalPagesController controller) {
    return Scrollbar(
      controller: controller.scrollController,
      child: SingleChildScrollView(
        controller: controller.scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lanza Vouchers – Terms and Conditions for Users',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().toLocal().toString().split(' ')[0]}',
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome to Lanza Vouchers! These terms govern your use of our website/app when purchasing or redeeming vouchers for third-party services and experiences.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Overview',
              'Lanza Vouchers is a promotional platform that allows users to purchase vouchers redeemable with third-party businesses (the "Merchants"). We act as an intermediary only.',
            ),
            _buildSection(
              '2. Your Use of Lanza Vouchers',
              '',
              bulletPoints: [
                'You must be over 18 to make a purchase.',
                'Vouchers are non-transferable unless otherwise stated.',
                'By purchasing a voucher, you agree to abide by the terms set by the Merchant.',
              ],
            ),
            _buildSection(
              '3. Voucher Redemption',
              '',
              bulletPoints: [
                'Each voucher is redeemable only with the specific Merchant and for the product/service described.',
                'Redemption is subject to availability and the Merchant\'s opening hours and conditions.',
                'Expiry dates are clearly stated and must be respected.',
              ],
            ),
            _buildSection(
              '4. Cancellations & Refunds',
              '',
              bulletPoints: [
                'You have a legal right to cancel your purchase within 14 days (unless redeemed).',
                'Refunds are processed within 14 days of cancellation notice.',
                'No refunds are offered after the voucher is redeemed or expired unless the Merchant fails to provide the service.',
              ],
            ),
            _buildSection(
              '5. Liability',
              '',
              bulletPoints: [
                'Lanza Vouchers is not responsible for the quality, safety, or fulfilment of any Merchant product or service.',
                'Any issues should be raised directly with the Merchant. We may assist in disputes but do not guarantee outcomes.',
              ],
            ),
            _buildSection(
              '6. Changes',
              'We may update these terms. Continued use of the app after updates implies your acceptance.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantTerms(LegalPagesController controller) {
    return Scrollbar(
      controller: controller.scrollController,
      child: SingleChildScrollView(
        controller: controller.scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lanza Vouchers – Merchant Terms and Conditions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().toLocal().toString().split(' ')[0]}',
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'These terms govern the relationship between you (the Merchant) and Lanza Vouchers when promoting and selling your vouchers through our platform.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Services Provided',
              '',
              bulletPoints: [
                'Lanza Vouchers promotes and sells digital vouchers to consumers on your behalf.',
                'We collect payment from customers and remit your share based on agreed commission.',
              ],
            ),
            _buildSection(
              '2. Merchant Responsibilities',
              'You agree to:',
              bulletPoints: [
                'Honour all valid vouchers sold through Lanza Vouchers',
                'Clearly specify redemption terms (valid days, booking requirements, restrictions)',
                'Provide the service/product described in a professional and lawful manner',
                'Inform us promptly of any changes to availability or business operations',
              ],
            ),
            _buildSection(
              '3. Payment Terms',
              '',
              bulletPoints: [
                'Payouts are made [monthly/bi-weekly] by bank transfer, minus our commission (as agreed in writing).',
                'You are responsible for declaring any taxes on the income you receive.',
              ],
            ),
            _buildSection(
              '4. Cancellations and Customer Rights',
              '',
              bulletPoints: [
                'Customers have a 14-day right of cancellation unless a voucher is redeemed.',
                'You agree to honour valid refund requests as per applicable consumer law.',
              ],
            ),
            _buildSection(
              '5. Liability and Disputes',
              '',
              bulletPoints: [
                'You are solely responsible for the services/products you provide.',
                'In case of customer complaints, you agree to cooperate with us to resolve them.',
              ],
            ),
            _buildSection(
              '6. Intellectual Property',
              'You grant us permission to use your logo, images, and description for promotion within our platform.',
            ),
            _buildSection(
              '7. Termination',
              'Either party can end this agreement with 14 days\' written notice.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String description,
      {List<String>? bulletPoints, String? additionalText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        if (description.isNotEmpty)
          Text(
            description,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        if (bulletPoints != null) ...[
          const SizedBox(height: 8),
          ...bulletPoints.map((point) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(fontSize: 16, color: Colors.black)),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              )),
        ],
        if (additionalText != null) ...[
          const SizedBox(height: 8),
          Text(
            additionalText,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
