import 'package:flutter/material.dart';

import '../../constants/app_theme.dart';

class ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? semanticLabel;
  final bool highlighted;

  const ActionIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.semanticLabel,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: highlighted
                ? AppTheme.accentColor.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
      ),
    );
  }
}
