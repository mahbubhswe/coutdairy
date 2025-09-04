// ignore_for_file: must_be_immutable
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  AppText({super.key});
  List<Color> _colors(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return [cs.primary, cs.secondary, cs.tertiary];
  }
  TextStyle colorizeTextStyle =
      const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: AnimatedTextKit(
        animatedTexts: [
          ColorizeAnimatedText(
            'কোর্ট ডাইরি অ্যাপ ব্যবহার খুব সহজ ও নিরাপদ',
            textStyle: colorizeTextStyle,
            colors: _colors(context),
          ),
          ColorizeAnimatedText(
            'আপনার সকল হিসাব-নিকাশ সবসময় নিরাপদ',
            textStyle: colorizeTextStyle,
            colors: _colors(context),
          ),
          ColorizeAnimatedText(
            'সহজ এবং নির্ভুল হিসাব রাখতে ব্যবহার করুন',
            textStyle: colorizeTextStyle,
            colors: _colors(context),
          ),
          ColorizeAnimatedText(
            'অটমেটিক ডাটা বেকাপ থাকে Google সার্ভারে',
            textStyle: colorizeTextStyle,
            colors: _colors(context),
          ),
          ColorizeAnimatedText(
            'ইন্টারনেট ছাড়াও ব্যবহার করুন নিশ্চিন্তে',
            textStyle: colorizeTextStyle,
            colors: _colors(context),
          ),
          ColorizeAnimatedText(
            'কোন ধরণের এড বা বিজ্ঞাপন দেখার ঝামেলা নেই',
            textStyle: colorizeTextStyle,
            colors: _colors(context),
          ),
        ],
        isRepeatingAnimation: true,
        repeatForever: true,
        stopPauseOnTap: true,
      ),
    );
  }
}
