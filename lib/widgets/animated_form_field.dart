import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class AnimatedFormField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool readOnly;
  final bool isEditing;
  final FormFieldValidator<String> validator;

  const AnimatedFormField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    required this.readOnly,
    required this.isEditing,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: isEditing
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            borderSide: BorderSide(
              color: isEditing ? AppTheme.primaryColor : Colors.grey[300]!,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            borderSide: BorderSide(
              color: isEditing ? AppTheme.primaryColor : Colors.grey[300]!,
              width: isEditing ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            borderSide: const BorderSide(
              color: AppTheme.primaryColor,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
