import 'package:flutter/material.dart';
import 'package:verzus/theme.dart';

class VerzusButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final VerzusButtonType type;
  final VerzusButtonSize size;
  final double? width;

  const VerzusButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.type = VerzusButtonType.primary,
    this.size = VerzusButtonSize.large,
    this.width,
  });

  const VerzusButton.secondary({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.size = VerzusButtonSize.large,
    this.width,
  }) : type = VerzusButtonType.secondary;

  const VerzusButton.outline({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.size = VerzusButtonSize.large,
    this.width,
  }) : type = VerzusButtonType.outline;

  const VerzusButton.text({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.size = VerzusButtonSize.medium,
    this.width,
  }) : type = VerzusButtonType.text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDisabled = onPressed == null || isLoading;
    
    final buttonStyle = _getButtonStyle(colorScheme, isDisabled);
    final textStyle = _getTextStyle(context);
    final padding = _getPadding();
    
    Widget buttonChild = child;
    
    if (isLoading) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getLoadingColor(colorScheme),
              ),
            ),
          ),
          const SizedBox(width: 12),
          child,
        ],
      );
    }

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: buttonStyle,
        child: Padding(
          padding: padding,
          child: DefaultTextStyle(
            style: textStyle,
            child: buttonChild,
          ),
        ),
      ),
    );
  }

  ButtonStyle _getButtonStyle(ColorScheme colorScheme, bool isDisabled) {
    final borderRadius = BorderRadius.circular(12);
    
    switch (type) {
      case VerzusButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: isDisabled 
            ? colorScheme.surfaceContainerHighest
            : VerzusColors.primaryPurple,
          foregroundColor: isDisabled 
            ? colorScheme.onSurfaceVariant
            : Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          overlayColor: Colors.white.withValues(alpha: 0.1),
        );
      
      case VerzusButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: isDisabled 
            ? colorScheme.surfaceContainerHighest
            : VerzusColors.accentGreen,
          foregroundColor: isDisabled 
            ? colorScheme.onSurfaceVariant
            : Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          overlayColor: Colors.white.withValues(alpha: 0.1),
        );
      
      case VerzusButtonType.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: isDisabled 
            ? colorScheme.onSurfaceVariant
            : VerzusColors.primaryPurple,
          elevation: 0,
          shadowColor: Colors.transparent,
          side: BorderSide(
            color: isDisabled 
              ? colorScheme.outline
              : VerzusColors.primaryPurple,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          overlayColor: VerzusColors.primaryPurple.withValues(alpha: 0.05),
        );
      
      case VerzusButtonType.text:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: isDisabled 
            ? colorScheme.onSurfaceVariant
            : VerzusColors.primaryPurple,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          overlayColor: VerzusColors.primaryPurple.withValues(alpha: 0.05),
        );
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
    ) ?? const TextStyle();

    switch (size) {
      case VerzusButtonSize.small:
        return baseStyle.copyWith(fontSize: 14);
      case VerzusButtonSize.medium:
        return baseStyle.copyWith(fontSize: 16);
      case VerzusButtonSize.large:
        return baseStyle.copyWith(fontSize: 16);
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case VerzusButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case VerzusButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case VerzusButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  Color _getLoadingColor(ColorScheme colorScheme) {
    switch (type) {
      case VerzusButtonType.primary:
      case VerzusButtonType.secondary:
        return Colors.white;
      case VerzusButtonType.outline:
      case VerzusButtonType.text:
        return VerzusColors.primaryPurple;
    }
  }
}

enum VerzusButtonType {
  primary,
  secondary,
  outline,
  text,
}

enum VerzusButtonSize {
  small,
  medium,
  large,
}