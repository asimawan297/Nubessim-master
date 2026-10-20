import 'package:flutter/material.dart';

extension TextExtension on BuildContext {
  TextStyle? get h1 => Theme.of(this).textTheme.headlineLarge;
  TextStyle? get h2 => Theme.of(this).textTheme.headlineMedium;
  TextStyle? get h3 => Theme.of(this).textTheme.headlineSmall;

  TextStyle? get t1 => Theme.of(this).textTheme.titleLarge;
  TextStyle? get t2 => Theme.of(this).textTheme.titleMedium;
  TextStyle? get t3 => Theme.of(this).textTheme.titleSmall;

  TextStyle? get b1 => Theme.of(this).textTheme.bodyLarge;
  TextStyle? get b2 => Theme.of(this).textTheme.bodyMedium;
  TextStyle? get b3 => Theme.of(this).textTheme.bodySmall;

  TextStyle? get label1 => Theme.of(this).textTheme.labelLarge;
  TextStyle? get label2 => Theme.of(this).textTheme.labelMedium;
  TextStyle? get label3 => Theme.of(this).textTheme.labelSmall;
}
