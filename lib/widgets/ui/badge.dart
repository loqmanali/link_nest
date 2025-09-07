import 'package:flutter/material.dart';

import '../../constants/app_theme.dart';

enum BadgeVariant { default_, secondary, destructive, outline }

class ShadcnBadge extends StatelessWidget {
  final String text;
  final BadgeVariant variant;
  final IconData? icon;
  final Color? customColor;
  final VoidCallback? onTap;

  const ShadcnBadge({
    super.key,
    required this.text,
    this.variant = BadgeVariant.default_,
    this.icon,
    this.customColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing2,
          vertical: AppTheme.spacing1,
        ),
        decoration: BoxDecoration(
          color: colors.backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: variant == BadgeVariant.outline
              ? Border.all(color: colors.borderColor)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 12,
                color: colors.foregroundColor,
              ),
              const SizedBox(width: AppTheme.spacing1),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: colors.foregroundColor,
                letterSpacing: 0.025,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _BadgeColors _getColors() {
    if (customColor != null) {
      return _BadgeColors(
        backgroundColor: customColor!.withValues(alpha: 0.1),
        foregroundColor: customColor!,
        borderColor: customColor!.withValues(alpha: 0.2),
      );
    }

    switch (variant) {
      case BadgeVariant.default_:
        return const _BadgeColors(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: AppTheme.primaryForeground,
          borderColor: AppTheme.primaryColor,
        );
      case BadgeVariant.secondary:
        return const _BadgeColors(
          backgroundColor: AppTheme.secondaryColor,
          foregroundColor: AppTheme.secondaryForeground,
          borderColor: AppTheme.secondaryColor,
        );
      case BadgeVariant.destructive:
        return const _BadgeColors(
          backgroundColor: AppTheme.destructiveColor,
          foregroundColor: AppTheme.destructiveForeground,
          borderColor: AppTheme.destructiveColor,
        );
      case BadgeVariant.outline:
        return const _BadgeColors(
          backgroundColor: Colors.transparent,
          foregroundColor: AppTheme.foregroundColor,
          borderColor: AppTheme.borderColor,
        );
    }
  }
}

class _BadgeColors {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  const _BadgeColors({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });
}
