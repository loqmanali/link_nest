// lib/shadcn_select.dart
// Flutter recreation of shadcn/ui Select with:
// - Trigger-width-matched overlay
// - Auto flip up/down + viewport-clamped height
// - Fade+Scale menu animation
// - Keyboard nav (↑/↓ Enter Esc) + type-ahead
// - Group labels
// - Theming via ShadcnSelectStyle
// - Arrow animation + custom open/closed icons via AnimatedRotation/AnimatedSwitcher
// - Visible RawScrollbar (customizable)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_theme.dart';

/// A single selectable option.
class SelectOption<T> {
  final T value;
  final String label;
  final bool disabled;
  const SelectOption({
    required this.value,
    required this.label,
    this.disabled = false,
  });
}

/// A labeled group of options.
class SelectGroup<T> {
  final String label;
  final List<SelectOption<T>> options;
  const SelectGroup({required this.label, required this.options});
}

/// Style overrides to control look & feel (optional).
class ShadcnSelectStyle {
  final double? triggerRadius;
  final double? menuRadius;
  final EdgeInsetsGeometry? triggerPadding;

  final Color? triggerColor;
  final Color? triggerBorderColor;
  final Color? menuColor;
  final Color? menuBorderColor;
  final Color? hoverColor;
  final Color? selectedIconColor;

  final TextStyle? placeholderStyle;
  final TextStyle? itemStyle;
  final TextStyle? groupLabelStyle;

  // Scrollbar
  final bool? showScrollbar;
  final double? scrollbarThickness;
  final Radius? scrollbarRadius;
  final Color? scrollbarThumbColor;

  // Icon appearance
  final double? iconSize;

  const ShadcnSelectStyle({
    this.triggerRadius,
    this.menuRadius,
    this.triggerPadding,
    this.triggerColor,
    this.triggerBorderColor,
    this.menuColor,
    this.menuBorderColor,
    this.hoverColor,
    this.selectedIconColor,
    this.placeholderStyle,
    this.itemStyle,
    this.groupLabelStyle,
    this.showScrollbar,
    this.scrollbarThickness,
    this.scrollbarRadius,
    this.scrollbarThumbColor,
    this.iconSize,
  });

  /// Default style that matches the app theme
  static const ShadcnSelectStyle defaultAppStyle = ShadcnSelectStyle(
    triggerRadius: AppTheme.radiusMd,
    menuRadius: AppTheme.radiusMd,
    triggerPadding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing3, vertical: AppTheme.spacing3),
    triggerColor: AppTheme.cardColor,
    triggerBorderColor: AppTheme.borderColor,
    menuColor: AppTheme.cardColor,
    menuBorderColor: AppTheme.borderColor,
    hoverColor: AppTheme.mutedColor,
    selectedIconColor: AppTheme.primaryColor,
    showScrollbar: true,
    scrollbarThickness: 4,
    scrollbarRadius: Radius.circular(AppTheme.radiusSm),
    scrollbarThumbColor: AppTheme.mutedForeground,
    iconSize: 20,
  );
}

/// Flutter mimic of shadcn/ui Select.
class ShadcnSelect<T> extends StatefulWidget {
  const ShadcnSelect({
    super.key,
    required this.groups,
    required this.onChanged,
    this.value,
    this.placeholder = 'Select an option',
    this.width = 180,
    this.menuMaxHeight = 280,
    this.itemHeight = 40,
    this.borderRadius = AppTheme.radiusMd,
    this.enabled = true,
    this.style,

    // Icon customization:
    this.openIcon,
    this.closedIcon,
    this.iconAnimDuration = const Duration(milliseconds: 140),
    this.iconAnimCurve = Curves.easeOutCubic,
  });

  final List<SelectGroup<T>> groups;
  final ValueChanged<T> onChanged;
  final T? value;
  final String placeholder;

  /// Trigger button width.
  final double width;

  /// Upper bound for menu height (still clamped to viewport automatically).
  final double menuMaxHeight;

  /// Row height for options.
  final double itemHeight;

  /// Default radius if style not provided.
  final double borderRadius;

  final bool enabled;

  /// Optional style overrides.
  final ShadcnSelectStyle? style;

  /// Optional custom icons (if not provided, a chevron rotates 180°).
  final Widget? openIcon;
  final Widget? closedIcon;
  final Duration iconAnimDuration;
  final Curve iconAnimCurve;

  /// Ungrouped convenience ctor.
  factory ShadcnSelect.fromOptions({
    Key? key,
    required List<SelectOption<T>> options,
    required ValueChanged<T> onChanged,
    T? value,
    String placeholder = 'Select an option',
    double width = 180,
    double menuMaxHeight = 280,
    double itemHeight = 40,
    double borderRadius = 8,
    bool enabled = true,
    ShadcnSelectStyle? style,
    Widget? openIcon,
    Widget? closedIcon,
    Duration iconAnimDuration = const Duration(milliseconds: 140),
    Curve iconAnimCurve = Curves.easeOutCubic,
  }) {
    return ShadcnSelect(
      key: key,
      groups: [SelectGroup(label: '', options: options)],
      onChanged: onChanged,
      value: value,
      placeholder: placeholder,
      width: width,
      menuMaxHeight: menuMaxHeight,
      itemHeight: itemHeight,
      borderRadius: borderRadius,
      enabled: enabled,
      style: style,
      openIcon: openIcon,
      closedIcon: closedIcon,
      iconAnimDuration: iconAnimDuration,
      iconAnimCurve: iconAnimCurve,
    );
  }

  @override
  State<ShadcnSelect<T>> createState() => _ShadcnSelectState<T>();
}

class _ShadcnSelectState<T> extends State<ShadcnSelect<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _link = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();

  OverlayEntry? _overlay;

  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  bool _isOpen = false;
  int _highlightIndex = -1;

  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode(debugLabel: 'ShadcnSelectTrigger');

  // Type-ahead buffer.
  String _typeAhead = '';
  Timer? _typeAheadTimer;

  // Layout/measure.
  Size _triggerSize = Size.zero;
  Rect? _triggerGlobalRect;
  double _computedMaxHeight = 0;
  bool _openUpwards = false;

  // Flattened entries to navigate groups + items uniformly.
  late List<_Entry<T>> _entries;

  @override
  void initState() {
    super.initState();
    _entries = _buildEntries(widget.groups);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 100),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _scale = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _highlightIndex = _indexOfValue(widget.value);
  }

  @override
  void didUpdateWidget(covariant ShadcnSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _highlightIndex = _indexOfValue(widget.value);
    }
    if (!identical(oldWidget.groups, widget.groups)) {
      _entries = _buildEntries(widget.groups);
      _highlightIndex = _indexOfValue(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _typeAheadTimer?.cancel();
    _focusNode.dispose();
    _removeOverlayIfAny();
    super.dispose();
  }

  List<_Entry<T>> _buildEntries(List<SelectGroup<T>> groups) {
    final out = <_Entry<T>>[];
    for (final g in groups) {
      if (g.label.trim().isNotEmpty) out.add(_HeaderEntry<T>(g.label));
      for (final o in g.options) out.add(_OptionEntry<T>(o));
    }
    return out;
  }

  int _indexOfValue(T? value) {
    if (value == null) return _firstEnabledIndex();
    for (int i = 0; i < _entries.length; i++) {
      final e = _entries[i];
      if (e is _OptionEntry<T> &&
          !e.option.disabled &&
          e.option.value == value) {
        return i;
      }
    }
    return _firstEnabledIndex();
  }

  int _firstEnabledIndex() {
    for (int i = 0; i < _entries.length; i++) {
      final e = _entries[i];
      if (e is _OptionEntry<T> && !e.option.disabled) return i;
    }
    return -1;
  }

  void _toggleOpen() {
    if (!widget.enabled) return;
    _isOpen ? _close() : _open();
  }

  void _measureTriggerAndViewport() {
    // Size of trigger.
    final ctx = _triggerKey.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox?;
      if (box != null) _triggerSize = box.size;
    }

    // Global rect and viewport safe space.
    final overlayBox = Overlay.of(context, rootOverlay: true)
        .context
        .findRenderObject() as RenderBox;
    final triggerBox =
        _triggerKey.currentContext!.findRenderObject() as RenderBox;

    final topLeft = triggerBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    _triggerGlobalRect = topLeft & _triggerSize;

    final mq = MediaQuery.of(context);
    final topSafe = mq.padding.top + 8;
    final botSafe = mq.size.height - mq.padding.bottom - 8;

    final spaceBelow = botSafe - _triggerGlobalRect!.bottom;
    final spaceAbove = _triggerGlobalRect!.top - topSafe;

    _openUpwards = spaceBelow < 200 && spaceAbove > spaceBelow;
    _computedMaxHeight = (_openUpwards ? spaceAbove : spaceBelow)
        .clamp(160.0, widget.menuMaxHeight);
  }

  void _open() {
    if (_isOpen) return;
    _measureTriggerAndViewport();
    _overlay = _createOverlayEntry();
    Overlay.of(context, rootOverlay: true).insert(_overlay!);
    // IMPORTANT: rebuild so icon switches immediately
    setState(() => _isOpen = true);
    _controller.forward(from: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToHighlight());
  }

  Future<void> _close() async {
    if (!_isOpen) return;
    await _controller.reverse();
    _removeOverlayIfAny();
    // IMPORTANT: rebuild so icon switches back immediately
    setState(() => _isOpen = false);
  }

  void _removeOverlayIfAny() {
    _overlay?.remove();
    _overlay = null;
  }

  void _onSelect(_OptionEntry<T> entry) {
    widget.onChanged(entry.option.value);
    _typeAhead = '';
    _close();
  }

  void _moveHighlight(int delta) {
    if (_entries.isEmpty) return;
    int i = _highlightIndex;
    for (int step = 0; step < _entries.length; step++) {
      i = (i + delta) % _entries.length;
      if (i < 0) i = _entries.length - 1;
      final e = _entries[i];
      if (e is _OptionEntry<T> && !e.option.disabled) {
        setState(() => _highlightIndex = i);
        _scrollToHighlight();
        return;
      }
    }
  }

  void _scrollToHighlight() {
    if (_highlightIndex < 0) return;
    final itemTop = _highlightIndex * widget.itemHeight;
    final itemBottom = itemTop + widget.itemHeight;
    final viewTop = _scrollController.position.pixels;
    final viewBottom = viewTop + _scrollController.position.viewportDimension;

    if (itemTop < viewTop) {
      _scrollController.animateTo(
        itemTop,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
      );
    } else if (itemBottom > viewBottom) {
      _scrollController.animateTo(
        itemBottom - _scrollController.position.viewportDimension,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;

    if (!_isOpen) {
      if (key == LogicalKeyboardKey.space ||
          key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.arrowDown) {
        _open();
      }
      return;
    }

    if (key == LogicalKeyboardKey.escape) {
      _close();
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _moveHighlight(1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _moveHighlight(-1);
    } else if (key == LogicalKeyboardKey.enter) {
      final e = (_highlightIndex >= 0 && _highlightIndex < _entries.length)
          ? _entries[_highlightIndex]
          : null;
      if (e is _OptionEntry<T> && !e.option.disabled) _onSelect(e);
    } else {
      final character = event.character;
      if (character != null && character.trim().isNotEmpty) {
        _typeAhead += character.toLowerCase();
        _typeAheadTimer?.cancel();
        _typeAheadTimer = Timer(const Duration(milliseconds: 700), () {
          _typeAhead = '';
        });

        int start = _highlightIndex + 1;
        for (int k = 0; k < _entries.length; k++) {
          final index = (start + k) % _entries.length;
          final e = _entries[index];
          if (e is _OptionEntry<T> &&
              !e.option.disabled &&
              e.option.label.toLowerCase().startsWith(_typeAhead)) {
            setState(() => _highlightIndex = index);
            _scrollToHighlight();
            break;
          }
        }
      }
    }
  }

  OverlayEntry _createOverlayEntry() {
    final theme = Theme.of(context);
    final effectiveStyle = widget.style ?? ShadcnSelectStyle.defaultAppStyle;
    final surface = effectiveStyle.menuColor ?? theme.colorScheme.surface;
    final border = (effectiveStyle.menuBorderColor ?? theme.dividerColor)
        .withValues(alpha: 0.6);

    final follower = CompositedTransformFollower(
      link: _link,
      showWhenUnlinked: false,
      targetAnchor: _openUpwards ? Alignment.topLeft : Alignment.bottomLeft,
      followerAnchor: _openUpwards ? Alignment.bottomLeft : Alignment.topLeft,
      offset: _openUpwards ? const Offset(0, -6) : const Offset(0, 6),
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            alignment:
                _openUpwards ? Alignment.bottomCenter : Alignment.topCenter,
            child: SizedBox(
              width: _triggerSize.width, // exact width match
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: _computedMaxHeight, // clamp to viewport
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(
                        effectiveStyle.menuRadius ?? widget.borderRadius),
                    border: Border.all(color: border),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 24,
                        spreadRadius: 0,
                        offset: Offset(0, 8),
                        color: Color(0x1F000000),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        effectiveStyle.menuRadius ?? widget.borderRadius),
                    child: _buildMenuList(theme),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return OverlayEntry(builder: (_) {
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
            ),
          ),
          follower,
        ],
      );
    });
  }

  Widget _buildMenuList(ThemeData theme) {
    final text = theme.textTheme;
    final effectiveStyle = widget.style ?? ShadcnSelectStyle.defaultAppStyle;

    final groupLabelStyle = effectiveStyle.groupLabelStyle ??
        text.labelSmall?.copyWith(
          color: AppTheme.mutedForeground,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        );

    final itemStyleDefault = effectiveStyle.itemStyle ??
        text.bodyMedium?.copyWith(
          color: AppTheme.foregroundColor,
        );

    Widget list = ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final e = _entries[index];

        if (e is _HeaderEntry<T>) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(e.label, style: groupLabelStyle),
          );
        }

        if (e is _OptionEntry<T>) {
          final isHighlighted = index == _highlightIndex;
          final isSelected =
              widget.value != null && e.option.value == widget.value;
          final disabled = e.option.disabled;

          final hoverBg = effectiveStyle.hoverColor ??
              theme.colorScheme.primary.withValues(alpha: 0.08);
          final checkColor =
              effectiveStyle.selectedIconColor ?? theme.colorScheme.primary;

          return MouseRegion(
            onEnter: (_) {
              if (!disabled) setState(() => _highlightIndex = index);
            },
            child: InkWell(
              onTap: disabled ? null : () => _onSelect(e),
              child: Container(
                height: widget.itemHeight,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: isHighlighted ? hoverBg : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.option.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: (itemStyleDefault ?? const TextStyle()).copyWith(
                          color: disabled
                              ? theme.disabledColor
                              : (itemStyleDefault?.color ??
                                  text.bodyMedium?.color),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check, size: 18, color: checkColor),
                  ],
                ),
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );

    // Add visible scrollbar (customizable).
    if (effectiveStyle.showScrollbar ?? true) {
      list = RawScrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        thickness: effectiveStyle.scrollbarThickness ?? 4,
        radius: effectiveStyle.scrollbarRadius ?? const Radius.circular(999),
        thumbColor: effectiveStyle.scrollbarThumbColor ??
            Colors.black.withValues(alpha: 0.25),
        child: list,
      );
    }

    return list;
  }

  String? _currentLabel() {
    if (widget.value == null) return null;
    for (final e in _entries) {
      if (e is _OptionEntry<T> && e.option.value == widget.value) {
        return e.option.label;
      }
    }
    return null;
  }

  Widget _buildIcon(ThemeData theme) {
    final effectiveStyle = widget.style ?? ShadcnSelectStyle.defaultAppStyle;
    final size = effectiveStyle.iconSize ?? 20.0;
    final color = AppTheme.foregroundColor.withValues(alpha: 0.8);

    // If user provided explicit icons, swap them with AnimatedSwitcher.
    if (widget.openIcon != null || widget.closedIcon != null) {
      final open = widget.openIcon ??
          Icon(Icons.keyboard_arrow_up, size: size, color: color);
      final closed = widget.closedIcon ??
          Icon(Icons.keyboard_arrow_down, size: size, color: color);

      return AnimatedSwitcher(
        duration: widget.iconAnimDuration,
        switchInCurve: widget.iconAnimCurve,
        switchOutCurve: widget.iconAnimCurve,
        transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim, child: ScaleTransition(scale: anim, child: child)),
        child: _isOpen
            ? KeyedSubtree(key: const ValueKey('openIcon'), child: open)
            : KeyedSubtree(key: const ValueKey('closedIcon'), child: closed),
      );
    }

    // Default: single chevron rotating 180°.
    return AnimatedRotation(
      turns: _isOpen ? 0.5 : 0.0, // 180 degrees
      duration: widget.iconAnimDuration,
      curve: widget.iconAnimCurve,
      child: Icon(Icons.keyboard_arrow_down, size: size, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveStyle = widget.style ?? ShadcnSelectStyle.defaultAppStyle;
    final surface = effectiveStyle.triggerColor ?? theme.colorScheme.surface;
    final border = (effectiveStyle.triggerBorderColor ?? theme.dividerColor)
        .withValues(alpha: 0.6);
    final text = theme.textTheme;

    final placeholderStyle = effectiveStyle.placeholderStyle ??
        text.bodyMedium?.copyWith(
          color: AppTheme.mutedForeground,
        );

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (_, e) {
        _handleKey(e);
        return KeyEventResult.handled;
      },
      child: CompositedTransformTarget(
        link: _link,
        child: GestureDetector(
          onTap: _toggleOpen,
          child: ConstrainedBox(
            constraints:
                BoxConstraints.tightFor(width: widget.width, height: 40),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: widget.enabled
                    ? surface
                    : theme.disabledColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(
                    effectiveStyle.triggerRadius ?? widget.borderRadius),
                border: Border.all(color: border),
              ),
              child: Padding(
                key: _triggerKey,
                padding: effectiveStyle.triggerPadding ??
                    const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _currentLabel() ?? widget.placeholder,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _currentLabel() != null
                            ? text.bodyMedium
                            : placeholderStyle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildIcon(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---- internal flattened entries ----
abstract class _Entry<T> {}

class _HeaderEntry<T> extends _Entry<T> {
  final String label;
  _HeaderEntry(this.label);
}

class _OptionEntry<T> extends _Entry<T> {
  final SelectOption<T> option;
  _OptionEntry(this.option);
}

// ----------------------
// DEMO USAGE WIDGET
// ----------------------
class SelectDemoFlutter extends StatefulWidget {
  const SelectDemoFlutter({super.key});
  @override
  State<SelectDemoFlutter> createState() => _SelectDemoFlutterState();
}

class _SelectDemoFlutterState extends State<SelectDemoFlutter> {
  String? _fruit = 'blueberry';

  @override
  Widget build(BuildContext context) {
    final fruits = [
      const SelectGroup<String>(
        label: 'Fruits',
        options: [
          SelectOption(value: 'apple', label: 'Apple'),
          SelectOption(value: 'banana', label: 'Banana'),
          SelectOption(value: 'blueberry', label: 'Blueberry'),
          SelectOption(value: 'grapes', label: 'Grapes'),
          SelectOption(value: 'pineapple', label: 'Pineapple'),
        ],
      ),
    ];

    return ShadcnSelect<String>(
      groups: fruits,
      value: _fruit,
      placeholder: 'Select a fruit',
      onChanged: (v) => setState(() => _fruit = v),
      width: 140,
      menuMaxHeight: 160,
      // Custom icons (optional):
      openIcon: const Icon(Icons.keyboard_arrow_up),
      closedIcon: const Icon(Icons.keyboard_arrow_down),
      // Style:
      style: const ShadcnSelectStyle(
        triggerRadius: 12,
        menuRadius: 12,
        triggerBorderColor: Color(0xFFDDDEE3),
        hoverColor: Color(0x14000000),
        selectedIconColor: Color(0xFF2F7AF8),
        triggerPadding: EdgeInsets.symmetric(horizontal: 14),
        // Scrollbar look:
        showScrollbar: true,
        scrollbarThickness: 4,
        scrollbarThumbColor: Color(0x55000000),
        scrollbarRadius: Radius.circular(999),
        iconSize: 22,
      ),
    );
  }
}
