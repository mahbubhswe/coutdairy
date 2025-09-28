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
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: themeController.isDarkMode
              ? Colors.black
              : const Color.fromARGB(255, 241, 238, 238),
          borderRadius: BorderRadius.circular(8),

          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
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
                isRepeatingAnimation: true,
                repeatForever: true,
                stopPauseOnTap: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
