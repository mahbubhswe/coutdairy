// ignore_for_file: must_be_immutable
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  const AppText({super.key});

  List<Color> _colors(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return [cs.primary, cs.secondary, cs.tertiary];
  }

  final TextStyle colorizeTextStyle = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
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
    );
  }
}
