// ignore_for_file: must_be_immutable
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../themes/theme_controller.dart';

class AppText extends StatelessWidget {
  const AppText({super.key});

  List<Color> _colors(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return [cs.primary, cs.secondary, cs.tertiary];
  }

  final TextStyle colorizeTextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    final isDark = themeController.isDarkMode;
    final borderColor = Theme.of(context).colorScheme.primary.withOpacity(0.16);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF161B2C), Color(0xFF101320)]
                : [
                    Theme.of(context).colorScheme.primary.withOpacity(0.18),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.12),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.35)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.12),
              blurRadius: 28,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          child: AnimatedTextKit(
            animatedTexts: [
              ColorizeAnimatedText(
                'কোর্ট ডাইরি অ্যাপ ব্যবহার খুব সহজ ও নিরাপদ',
                textStyle: colorizeTextStyle,
                colors: _colors(context),
                textAlign: TextAlign.center,
              ),
              ColorizeAnimatedText(
                'অটমেটিক ডাটা বেকাপ থাকে Google সার্ভারে',
                textStyle: colorizeTextStyle,
                colors: _colors(context),
                textAlign: TextAlign.center,
              ),
              ColorizeAnimatedText(
                'ইন্টারনেট ছাড়াও ব্যবহার করুন নিশ্চিন্তে',
                textStyle: colorizeTextStyle,
                colors: _colors(context),
                textAlign: TextAlign.center,
              ),
              ColorizeAnimatedText(
                'কোন ধরণের এড বা বিজ্ঞাপন দেখার ঝামেলা নেই',
                textStyle: colorizeTextStyle,
                colors: _colors(context),
                textAlign: TextAlign.center,
              ),
            ],
            pause: const Duration(milliseconds: 800),
            isRepeatingAnimation: true,
            repeatForever: true,
            stopPauseOnTap: true,
          ),
        ),
      ),
    );
  }
}
