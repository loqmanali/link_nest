import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../constants/app_theme.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class FilterPill extends HookWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final bool hasChevron;
  final VoidCallback? onTap;

  const FilterPill({
    super.key,
    required this.label,
    required this.isActive,
    required this.activeColor,
    this.hasChevron = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      lowerBound: 0.0,
      upperBound: 1.0,
      duration: const Duration(milliseconds: 120),
    );
    final scale = useMemoized(
        () => Tween<double>(begin: 1.0, end: 0.98).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeOut,
              reverseCurve: Curves.easeIn,
            )),
        [controller]);

    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          color: isActive ? activeColor : AppTheme.foregroundColor,
        );

    final pill = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? activeColor.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isActive ? activeColor.withValues(alpha: 0.3) : AppTheme.borderColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: textStyle),
          if (hasChevron) ...[
            const SizedBox(width: 6),
            Icon(
              Iconsax.arrow_down_2,
              size: 18,
              color: isActive ? activeColor : AppTheme.mutedForeground,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return pill;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => controller.forward(),
      onTapCancel: () => controller.reverse(),
      onTapUp: (_) => controller.reverse(),
      onTap: onTap,
      child: ScaleTransition(scale: scale, child: pill),
    );
  }
}
