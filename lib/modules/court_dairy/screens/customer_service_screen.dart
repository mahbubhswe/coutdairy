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
                'যোগাযোগ',
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
                    Text('ইমেইল: support@appseba.com'),
                    SizedBox(height: 4),
                    Text('ফোন: 01607415159'),
                    SizedBox(height: 4),
                    Text('হোয়াটসঅ্যাপ: 01607415159'),
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
                    label: const Text('ইমেইল'),
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
                'অ্যাপের ফিচারসমূহ',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _bullet('মোকদ্দমা তালিকা ও ব্যবস্থাপনা'),
              _bullet('শুনানির তারিখ রিমাইন্ডার'),
              _bullet('ক্লায়েন্ট ও প্রতিপক্ষ তথ্য সংরক্ষণ'),
              _bullet('ক্লায়েন্টকে তারিখের আগের দিন Auto SMS'),
              _bullet('কোর্ট ফি ও খরচ হিসাব'),
              _bullet('ডকুমেন্ট ও প্রমাণ সংযুক্তি'),
              _bullet('দৈনিক অগ্রগতির রিপোর্ট'),
              _bullet('ক্যালেন্ডার সিঙ্ক ও নোটিফিকেশন'),
              _bullet('কেস সার্চ ও ফিল্টার অপশন'),
              _bullet('অফলাইনে তথ্য ব্যবহারের সুবিধা'),
              _bullet('নিরাপদ ক্লাউড ব্যাকআপ'),
              _bullet('বহু-ব্যবহারকারী পারমিশন নিয়ন্ত্রণ'),
              _bullet('টাস্ক ও রিমাইন্ডার ম্যানেজার'),
              _bullet('কেস আপডেট শেয়ারিং'),
              _bullet('ডেটা এক্সপোর্ট ও প্রিন্টিং'),
              _bullet('ক্লায়েন্ট পেমেন্ট ট্র্যাকিং'),
              const SizedBox(height: 24),
              // How to Use Section
              Text(
                'কিভাবে ব্যবহার করবেন',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
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
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
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
