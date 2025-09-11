import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text('আপ সেবা দ্বারা পরিচালিত - আপনার বিশ্বস্ত বন্ধু।'),
        Text(
          'সফটওয়্যার কোম্পানি',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
