import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text('Powered by App Seba - Your Trusted Friend.'),
        Text(
          'Software Company',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
