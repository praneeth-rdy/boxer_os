import 'package:flutter/material.dart';

/// Every duration and curve the app animates with.
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration flash = Duration(milliseconds: 320);

  /// Delay between neighbouring items in a staggered entrance.
  static const Duration stagger = Duration(milliseconds: 40);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve change = Curves.easeInOut;

  /// Whether the system asks for as little motion as possible.
  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// [duration], or nothing at all when the system asks for reduced motion.
  static Duration of(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;
}
