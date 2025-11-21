import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Displays the VerzusXYZ text logo that adapts to current theme brightness.
class BrandTextLogo extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry? padding;
  const BrandTextLogo({super.key, this.height = 22, this.padding});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = isDark
        ? 'assets/icons/verzusXYZ_dark_theme_text_logo.svg'
        : 'assets/icons/verzusXYZ_light_theme_text_logo.svg';
    final widget = SvgPicture.asset(
      asset,
      height: height,
      fit: BoxFit.contain,
    );
    if (padding != null) {
      return Padding(padding: padding!, child: widget);
    }
    return widget;
  }
}

/// Displays the VerzusXYZ brand mark (icon) that adapts to current theme.
class BrandMarkLogo extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? padding;
  const BrandMarkLogo({super.key, this.size = 24, this.padding});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = isDark
        ? 'assets/icons/verzusXYZ_dark_theme_logo.svg'
        : 'assets/icons/verzusXYZ_light_theme_logo.svg';
    final widget = SvgPicture.asset(
      asset,
      height: size,
      width: size,
      fit: BoxFit.contain,
    );
    if (padding != null) {
      return Padding(padding: padding!, child: widget);
    }
    return widget;
  }
}
