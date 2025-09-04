import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A GetX CustomTransition that uses the Material SharedAxisTransition
/// from the animations package for all route changes.
class SharedAxisCustomTransition extends CustomTransition {
  final SharedAxisTransitionType transitionType;

  SharedAxisCustomTransition({
    this.transitionType = SharedAxisTransitionType.horizontal,
  });

  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: curve ?? Curves.linear,
    );
    final curvedSecondary = CurvedAnimation(
      parent: secondaryAnimation,
      curve: curve ?? Curves.linear,
    );

    return SharedAxisTransition(
      transitionType: transitionType,
      animation: curved,
      secondaryAnimation: curvedSecondary,
      fillColor: Colors.transparent,
      child: child,
    );
  }
}

