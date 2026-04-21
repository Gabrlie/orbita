import 'package:flutter/material.dart';

enum AppThemeSeed {
  indigo('indigo', Color(0xFF3F51B5)),
  blue('blue', Color(0xFF2563EB)),
  violet('violet', Color(0xFF7C3AED)),
  teal('teal', Color(0xFF0F766E)),
  emerald('emerald', Color(0xFF059669)),
  orange('orange', Color(0xFFF97316)),
  rose('rose', Color(0xFFE11D48));

  final String storageKey;
  final Color color;

  const AppThemeSeed(this.storageKey, this.color);

  static AppThemeSeed fromStorageKey(String? key) {
    for (final seed in values) {
      if (seed.storageKey == key) return seed;
    }
    return indigo;
  }
}
