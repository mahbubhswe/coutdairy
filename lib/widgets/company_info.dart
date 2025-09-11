import 'package:flutter/material.dart';

class CompanyInfo extends StatelessWidget {
  const CompanyInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'অ্যাপসেবা দ্বারা পরিচালিত',
        ),
        Text(
          'আপনার বিশ্বস্ত বন্ধু',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
