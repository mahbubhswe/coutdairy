import 'package:court_dairy/widgets/company_info.dart';
import 'package:flutter/material.dart';
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
      appBar: AppBar(
        elevation: 0,
        title: const Text('Customer Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Section
            Text(
              'যোগাযোগ',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('ইমেইল: support@appseba.com'),
                  SizedBox(height: 4),
                  Text('ফোন: +8801XXXXXXXXX'),
                  SizedBox(height: 4),
                  Text('হোয়াটসঅ্যাপ: +8801XXXXXXXXX'),
                  SizedBox(height: 4),
                  Text('সেবা সময়: প্রতিদিন সকাল ৯টা - রাত ৯টা'),
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
                  label: const Text('কল করুন'),
                  onPressed: () async {
                    final uri = Uri(scheme: 'tel', path: '+8801XXXXXXXXX');
                    try {
                      await launchUrl(uri);
                    } catch (_) {}
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.chat),
                  label: const Text('WhatsApp'),
                  onPressed: () async {
                    final url = Uri.parse('https://wa.me/8801XXXXXXXXX');
                    try {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } catch (_) {}
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('ইমেইল'),
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
            // How to Use Section
            Text(
              'কিভাবে ব্যবহার করবেন',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _bullet('পার্টি ট্যাব থেকে নতুন পার্টি যোগ করুন।'),
            _bullet('কেস ট্যাব থেকে নতুন কেস যোগ করে পার্টি লিঙ্ক করুন।'),
            _bullet('হিসাব ট্যাবে আয়/ব্যয়ের লেনদেন রেকর্ড রাখুন।'),
            _bullet('কেস ডিটেইলসে শুনানির তারিখ আপডেট করুন।'),
            _bullet('প্রয়োজনে Buy SMS স্ক্রিন থেকে এসএমএস প্যাক নিন।'),
            const SizedBox(height: 24),
            // FAQs Section
            Text(
              'প্রায় জিজ্ঞাসা (FAQ)',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _buildFaq(
              question: 'কিভাবে কেস যোগ করবো?',
              answer:
                  'কেস ট্যাবে যান -> Add Case -> ফর্ম পূরণ করে Submit করুন।',
            ),
            _buildFaq(
              question: 'পার্টি কিভাবে যুক্ত করবো?',
              answer: 'পার্টি ট্যাব -> Add Party -> তথ্য দিয়ে সেভ করুন।',
            ),
            _buildFaq(
              question: 'লেনদেন কিভাবে যোগ করবো?',
              answer: 'হিসাব ট্যাব -> নতুন লেনদেন -> তথ্য দিয়ে সেভ করুন।',
            ),
            _buildFaq(
              question: 'সাপোর্টে কিভাবে যোগাযোগ করবো?',
              answer: 'উপরের কল/WhatsApp/ইমেইল অপশন ব্যবহার করুন।',
            ),
            const SizedBox(height: 24),
            const Center(child: CompanyInfo()),
          ],
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
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(answer),
          ),
        ),
      ],
    );
  }
}
