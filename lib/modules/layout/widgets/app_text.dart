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
          'Court Diary is easy and secure to use',
          textStyle: colorizeTextStyle,
          colors: _colors(context),
          textAlign: TextAlign.center,
        ),
        ColorizeAnimatedText(
          'Automatic data backup on Google servers',
          textStyle: colorizeTextStyle,
          colors: _colors(context),
          textAlign: TextAlign.center,
        ),
        ColorizeAnimatedText(
          'Use confidently even without internet',
          textStyle: colorizeTextStyle,
          colors: _colors(context),
          textAlign: TextAlign.center,
        ),
        ColorizeAnimatedText(
          'No ads or interruptions',
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
