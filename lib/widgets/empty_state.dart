import 'package:flutter/material.dart';

import '../constants/app_theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subMessage;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    required this.subMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppTheme.lightTextColor,
            ),
            const SizedBox(height: AppTheme.defaultPadding),
            Text(
              message,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.smallPadding),
            Text(
              subMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTextColor,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
