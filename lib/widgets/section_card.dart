import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final List<Widget>? actions;
  final bool isLoading;
  final VoidCallback? onTap;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.actions,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.subtleShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: AppTheme.mutedForeground,
                    ),
                    const SizedBox(width: AppTheme.spacing3),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.foregroundColor,
                      ),
                    ),
                    const Spacer(),
                    if (isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor,
                          ),
                        ),
                      )
                    else if (actions != null) ...actions!,
                  ],
                ),
                const SizedBox(height: AppTheme.spacing3),
                // Content
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
