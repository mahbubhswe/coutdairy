import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../themes/theme_controller.dart';

class AccountsCard extends StatelessWidget {
  final String title;
  final double amount;

  AccountsCard({super.key, required this.title, required this.amount});
  final themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: Get.width * 0.3,
      child: Material(
        elevation: 0.1,
        borderRadius: BorderRadius.circular(7),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Column(
            children: [
              Text(
                title,
              ),
              TweenAnimationBuilder<int>(
                tween: IntTween(
                    begin: 0, end: amount.floor()), // Count up to endValue
                duration: const Duration(seconds: 1),
                builder: (context, value, child) {
                  return Text(
                    NumberFormat.currency(
                      locale: 'bn_BD',
                      symbol: '',
                      decimalDigits: 0,
                    ).format(value).trim(), // Format the number as currency
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
