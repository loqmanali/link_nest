import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../constants/app_theme.dart';

enum ButtonVariant { primary, secondary, outline, ghost, destructive }

enum ButtonSize { sm, md, lg }

class ShadcnButton extends HookWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const ShadcnButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isHovered = useState(false);
    final isPressed = useState(false);
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 150),
    );

    final scaleAnimation = useAnimation(
      Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
      ),
    );

    useEffect(() {
      if (isPressed.value) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
      return null;
    }, [isPressed.value]);

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: GestureDetector(
        onTapDown: (_) => isPressed.value = true,
        onTapUp: (_) => isPressed.value = false,
        onTapCancel: () => isPressed.value = false,
        child: Transform.scale(
          scale: scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: isFullWidth ? double.infinity : null,
            padding: _getPadding(),
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: variant == ButtonVariant.outline
                  ? Border.all(
                      color: AppTheme.borderColor,
                      width: isHovered.value ? 1.5 : 1.0,
                    )
                  : null,
              boxShadow: variant == ButtonVariant.primary && !isLoading
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(isPressed.value
                            ? 0.2
                            : (isHovered.value ? 0.4 : 0.3)),
                        blurRadius:
                            isPressed.value ? 4 : (isHovered.value ? 12 : 8),
                        offset: Offset(
                            0, isPressed.value ? 1 : (isHovered.value ? 4 : 2)),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : onPressed,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                splashColor: _getForegroundColor().withOpacity(0.1),
                highlightColor: _getForegroundColor().withOpacity(0.05),
                child: Container(
                  alignment: Alignment.center,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isLoading
                        ? SizedBox(
                            key: const ValueKey('loading'),
                            width: _getIconSize(),
                            height: _getIconSize(),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getForegroundColor(),
                              ),
                            ),
                          )
                        : Row(
                            key: const ValueKey('content'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isLoading) ...[
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _getForegroundColor(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ] else if (icon != null) ...[
                                Icon(
                                  icon,
                                  size: _getIconSize(),
                                  color: _getForegroundColor(),
                                ),
                                const SizedBox(width: AppTheme.spacing2),
                              ],
                              Text(
                                text,
                                style: TextStyle(
                                  fontSize: _getTextStyle().fontSize,
                                  fontWeight: FontWeight.w500,
                                  color: _getForegroundColor(),
                                  letterSpacing: 0.025,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return AppTheme.accentColor;
      case ButtonVariant.secondary:
        return AppTheme.secondaryColor;
      case ButtonVariant.outline:
        return Colors.transparent;
      case ButtonVariant.ghost:
        return Colors.transparent;
      case ButtonVariant.destructive:
        return AppTheme.destructiveColor;
    }
  }

  Color _getForegroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return AppTheme.accentForeground;
      case ButtonVariant.secondary:
        return AppTheme.secondaryForeground;
      case ButtonVariant.outline:
        return AppTheme.foregroundColor;
      case ButtonVariant.ghost:
        return AppTheme.foregroundColor;
      case ButtonVariant.destructive:
        return AppTheme.destructiveForeground;
    }
  }

  TextStyle _getTextStyle() {
    final fontSize =
        size == ButtonSize.sm ? 12.0 : (size == ButtonSize.lg ? 16.0 : 14.0);
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.025,
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case ButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.sm:
        return 14;
      case ButtonSize.md:
        return 16;
      case ButtonSize.lg:
        return 18;
    }
  }
}
