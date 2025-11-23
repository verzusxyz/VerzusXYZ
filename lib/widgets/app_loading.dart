import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Centralized loading animation using theme-aware Lottie assets.
class AppLoading extends StatelessWidget {
  final double size;
  final String? label;
  const AppLoading({super.key, this.size = 140, this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = isDark
        ? 'assets/lottie_files/verzusXYZ_loading_animation_dark_theme.json'
        : 'assets/lottie_files/verzusXYZ_loading_animation_light_theme.json';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(asset, width: size, height: size),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(
            label!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
