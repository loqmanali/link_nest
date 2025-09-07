import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ActiveFilterChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onClear;

  const ActiveFilterChip({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing3,
        vertical: AppTheme.spacing2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppTheme.spacing2),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: color, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: AppTheme.spacing2),
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: Icon(Iconsax.close_circle, size: 14, color: color),
          ),
        ],
      ),
    );
  }
}
