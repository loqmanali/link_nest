import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../constants/app_theme.dart';

class ShadcnCard extends HookWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool showBorder;
  final bool showShadow;
  final Color? backgroundColor;
  final double? borderRadius;

  const ShadcnCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.showBorder = true,
    this.showShadow = false,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isHovered = useState(false);
    final isPressed = useState(false);

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: GestureDetector(
        onTap: onTap,
        onTapDown: (_) => isPressed.value = true,
        onTapUp: (_) => isPressed.value = false,
        onTapCancel: () => isPressed.value = false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: margin ?? EdgeInsets.zero,
          padding: padding,
          transform: Matrix4.identity()
            ..scale(isPressed.value ? 0.98 : 1.0),
          decoration: BoxDecoration(
            color: backgroundColor ?? AppTheme.cardColor,
            borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusLg),
            border: showBorder 
                ? Border.all(
                    color: isHovered.value 
                        ? AppTheme.borderColor.withOpacity(0.8)
                        : AppTheme.borderColor
                  ) 
                : null,
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        isPressed.value ? 0.05 : (isHovered.value ? 0.15 : 0.1)
                      ),
                      blurRadius: isPressed.value ? 5 : (isHovered.value ? 20 : 10),
                      offset: Offset(0, isPressed.value ? 2 : (isHovered.value ? 8 : 4)),
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

class ShadcnCardHeader extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final EdgeInsets? padding;

  const ShadcnCardHeader({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: AppTheme.spacing3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) title!,
                if (subtitle != null) ...[
                  const SizedBox(height: AppTheme.spacing1),
                  subtitle!,
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppTheme.spacing2),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class ShadcnCardContent extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const ShadcnCardContent({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(vertical: AppTheme.spacing2),
      child: child,
    );
  }
}

class ShadcnCardFooter extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const ShadcnCardFooter({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: AppTheme.spacing3),
      child: child,
    );
  }
}
