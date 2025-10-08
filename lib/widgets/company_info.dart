import 'package:flutter/material.dart';

class CompanyInfo extends StatelessWidget {
  const CompanyInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Powered by Appsheba'),
        const Text(
          'Your trusted partner',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
