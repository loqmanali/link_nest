import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class OpenButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onPressed;

  const OpenButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppTheme.primaryColor : Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      child: InkWell
        (
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            border: isPrimary
                ? null
                : Border.all(color: AppTheme.primaryColor, width: 1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : AppTheme.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : AppTheme.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
