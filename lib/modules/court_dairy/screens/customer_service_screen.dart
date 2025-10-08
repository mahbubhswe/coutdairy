import 'package:court_dairy/widgets/company_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerServiceScreen extends StatelessWidget {
  const CustomerServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(elevation: 0, title: const Text('Customer Service')),
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact Section
              Text(
                'Contact',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: Get.width,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Email: support@appseba.com'),
                    SizedBox(height: 4),
                    Text('Phone: 01607415159'),
                    SizedBox(height: 4),
                    Text('WhatsApp: 01607415159'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.call),
                    label: const Text('Call'),
                    onPressed: () async {
                      final uri = Uri(scheme: 'tel', path: '01607415159');
                      try {
                        await launchUrl(uri);
                      } catch (_) {}
                    },
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.chat),
                    label: const Text('WhatsApp'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () async {
                      final url = Uri.parse('https://wa.me/8801607415159');
                      try {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (_) {}
                    },
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Email'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.tertiary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () async {
                      final mail = Uri(
                        scheme: 'mailto',
                        path: 'support@appseba.com',
                        query: 'subject=Court Diary Support&body=Hello,',
                      );
                      try {
                        await launchUrl(mail);
                      } catch (_) {}
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Features Section
              Text(
                'App features',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _bullet('Case listing and management'),
              _bullet('Hearing date reminders'),
              _bullet('Store client and opponent information'),
              _bullet('Automatic SMS to clients the day before a hearing'),
              _bullet('Track court fees and expenses'),
              _bullet('Attach documents and evidence'),
              _bullet('Daily progress reports'),
              _bullet('Calendar sync and notifications'),
              _bullet('Case search and filter options'),
              _bullet('Offline access to information'),
              _bullet('Secure cloud backup'),
              _bullet('Multi-user permission control'),
              _bullet('Task and reminder manager'),
              _bullet('Case update sharing'),
              _bullet('Data export and printing'),
              _bullet('Client payment tracking'),
              const SizedBox(height: 24),
              // How to Use Section
              Text(
                'How to use',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _bullet('Add new parties from the Parties tab.'),
              _bullet('Add new cases from the Cases tab and link parties.'),
              _bullet('Record income and expense transactions in the Accounts tab.'),
              _bullet('Update hearing dates inside the case details.'),
              _bullet('Purchase SMS packs from the Buy SMS screen when needed.'),
              const SizedBox(height: 24),
              // FAQs Section
              Text(
                'Frequently asked questions (FAQ)',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _buildFaq(
                question: 'How do I add a case?',
                answer:
                    'Go to the Cases tab -> Add Case -> fill out the form and submit.',
              ),
              _buildFaq(
                question: 'How do I add a party?',
                answer: 'Go to the Parties tab -> Add Party -> enter the details and save.',
              ),
              _buildFaq(
                question: 'How do I add a transaction?',
                answer: 'Go to the Accounts tab -> New transaction -> enter the details and save.',
              ),
              _buildFaq(
                question: 'How do I contact support?',
                answer: 'Use the call, WhatsApp, or email options above.',
              ),
              const SizedBox(height: 24),
              const Center(child: CompanyInfo()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildFaq({required String question, required String answer}) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(question),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Align(alignment: Alignment.centerLeft, child: Text(answer)),
        ),
      ],
    );
  }
}
