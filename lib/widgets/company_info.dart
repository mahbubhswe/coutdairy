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
          'Powered by AppSeba',
        ),
        Text(
          'Your Trusted Friend',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
