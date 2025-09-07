import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../constants/app_theme.dart';

class ShadcnInput extends HookWidget {
  final String? label;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final int? maxLines;
  final int? minLines;
  final FocusNode? focusNode;

  const ShadcnInput({
    super.key,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.maxLines = 1,
    this.minLines,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final isFocused = useState(false);
    final isHovered = useState(false);
    // Ensure we always have a controller for internal behaviors like clear button
    final internalController = useTextEditingController();
    final effectiveController = controller ?? internalController;
    // Rebuild on text changes to toggle clear button
    useListenable(effectiveController);
    final internalFocusNode = useFocusNode();
    final effectiveFocusNode = focusNode ?? internalFocusNode;

    useEffect(() {
      void listener() {
        isFocused.value = effectiveFocusNode.hasFocus;
      }

      effectiveFocusNode.addListener(listener);
      return () => effectiveFocusNode.removeListener(listener);
    }, [effectiveFocusNode]);

    final hasError = errorText != null && errorText!.isNotEmpty;
    final showClearButton =
        suffixIcon == null && enabled && effectiveController.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.foregroundColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: AppTheme.spacing2),
        ],
        MouseRegion(
          onEnter: (_) => isHovered.value = true,
          onExit: (_) => isHovered.value = false,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: isFocused.value
                  ? [
                      BoxShadow(
                        color: AppTheme.ringColor.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 0),
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: effectiveController,
              focusNode: effectiveFocusNode,
              onChanged: onChanged,
              validator: validator,
              keyboardType: keyboardType,
              obscureText: obscureText,
              enabled: enabled,
              maxLines: maxLines,
              minLines: minLines,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: enabled
                        ? AppTheme.foregroundColor
                        : AppTheme.mutedForeground,
                  ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mutedForeground,
                    ),
                filled: true,
                fillColor: enabled ? AppTheme.cardColor : AppTheme.mutedColor,
                prefixIcon: prefixIcon != null
                    ? Icon(
                        prefixIcon,
                        color: isFocused.value
                            ? AppTheme.ringColor
                            : AppTheme.mutedForeground,
                        size: 18,
                      )
                    : null,
                suffixIcon: suffixIcon != null
                    ? IconButton(
                        icon: Icon(
                          suffixIcon,
                          color: AppTheme.mutedForeground,
                          size: 18,
                        ),
                        onPressed: onSuffixIconPressed,
                        splashRadius: 16,
                      )
                    : showClearButton
                        ? IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppTheme.mutedForeground,
                            ),
                            onPressed: () {
                              effectiveController.clear();
                              // trigger onChanged callback with empty value
                              if (onChanged != null) onChanged!('');
                            },
                            splashRadius: 16,
                            tooltip: 'Clear',
                          )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide(
                    color: isHovered.value
                        ? AppTheme.borderColor.withValues(alpha: 0.8)
                        : AppTheme.borderColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: const BorderSide(
                    color: AppTheme.ringColor,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: const BorderSide(
                    color: AppTheme.destructiveColor,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: const BorderSide(
                    color: AppTheme.destructiveColor,
                    width: 2,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: const BorderSide(color: AppTheme.mutedColor),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing3,
                  vertical: AppTheme.spacing3,
                ),
                errorText: null, // Handle error display separately
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppTheme.spacing1),
          Text(
            errorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.destructiveColor,
                ),
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: AppTheme.spacing1),
          Text(
            helperText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedForeground,
                ),
          ),
        ],
      ],
    );
  }
}
