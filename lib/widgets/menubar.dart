// Refactored Menubar implementation with no external packages except flutter_hooks.
// Author: Loqman – May 18, 2025
// -----------------------------------------------------------------------------
// This file provides a drop‑in replacement for the original ShadCN‑based
// Menubar system.  It keeps the public API identical where possible while
// removing every third‑party dependency (except `flutter_hooks`).  All styling
// choices now rely solely on Flutter's native `ThemeData` and Material widgets.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/*─────────────────────────────────────────────────────────────────────────────
│ Public API                                                                  │
╰─────────────────────────────────────────────────────────────────────────────*/

/// Root container that renders a horizontal menubar.
class Menubar extends HookWidget {
  const Menubar({
    Key? key,
    required this.children,
    this.border = true,
    this.popoverOffset,
  }) : super(key: key);

  final List<MenuItem> children;
  final bool border;
  final Offset? popoverOffset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaling = MediaQuery.of(context).textScaler.scale(1.0);

    Widget bar = _MenuGroup(
      direction: Axis.horizontal,
      itemPadding: EdgeInsets.zero,
      popoverOffset:
          (border ? const Offset(-4, 8) : const Offset(0, 4)) * scaling,
      children: children,
    );

    if (!border) return bar;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(6),
        color: theme.colorScheme.surface,
      ),
      padding: EdgeInsets.all(4 * scaling),
      child: bar,
    );
  }
}

/// Shorthand for inserting gaps between menu items.
class MenuGap extends StatelessWidget implements MenuItem {
  const MenuGap(this.size, {Key? key}) : super(key: key);
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size);
  @override
  bool get hasLeading => false;
  @override
  PopoverController? get popoverController => null;
}

/// Divider between menu items.
class MenuDivider extends StatelessWidget implements MenuItem {
  const MenuDivider({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final axis = _MenuScope.of(context).direction;
    final theme = Theme.of(context);
    final scaling = MediaQuery.of(context).textScaler.scale(1.0);

    return Padding(
      padding: (axis == Axis.vertical
              ? const EdgeInsets.symmetric(vertical: 4)
              : const EdgeInsets.symmetric(horizontal: 4)) *
          scaling,
      child: axis == Axis.vertical
          ? Divider(height: 1 * scaling, color: theme.dividerColor)
          : VerticalDivider(width: 1 * scaling, color: theme.dividerColor),
    );
  }

  @override
  bool get hasLeading => false;
  @override
  PopoverController? get popoverController => null;
}

/// Non‑interactive label row.
class MenuLabel extends StatelessWidget implements MenuItem {
  const MenuLabel({Key? key, required this.child, this.leading, this.trailing})
      : super(key: key);
  final Widget child;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final g = _MenuScope.of(context);
    final scaling = MediaQuery.of(context).textScaler.scale(1.0);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (g.hasLeading)
          SizedBox(width: 16 * scaling, child: leading ?? const SizedBox()),
        DefaultTextStyle.merge(
            child: child, style: const TextStyle(fontWeight: FontWeight.w600)),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );

    return Padding(
      padding: g.itemPadding.add(EdgeInsets.symmetric(horizontal: 8 * scaling)),
      child: content,
    );
  }

  @override
  bool get hasLeading => leading != null;
  @override
  PopoverController? get popoverController => null;
}

/// Checkbox menu item.
class MenuCheckbox extends StatelessWidget implements MenuItem {
  const MenuCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.child,
    this.enabled = true,
    this.autoClose = true,
    this.trailing,
  }) : super(key: key);

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget child;
  final bool enabled;
  final bool autoClose;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scaling = MediaQuery.of(context).textScaler.scale(1.0);

    return _MenuButton(
      leading: value
          ? Icon(Iconsax.tick_circle, size: 16 * scaling)
          : SizedBox(width: 16 * scaling),
      trailing: trailing,
      enabled: enabled,
      autoClose: autoClose,
      onPressed: () => onChanged?.call(!value),
      child: child,
    );
  }

  @override
  bool get hasLeading => true;
  @override
  PopoverController? get popoverController => null;
}

/// Radio group wrapper used to coordinate selection.
class MenuRadioGroup<T> extends StatelessWidget implements MenuItem {
  const MenuRadioGroup({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.children,
  }) : super(key: key);

  final T? value;
  final ValueChanged<T>? onChanged;
  final List<MenuRadio<T>> children;

  @override
  Widget build(BuildContext context) {
    return _MenuScope(
      hasLeading: children.any((e) => e.hasLeading),
      direction: _MenuScope.of(context).direction,
      itemPadding: _MenuScope.of(context).itemPadding,
      popoverOffset: _MenuScope.of(context).popoverOffset,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  @override
  bool get hasLeading => children.any((c) => c.hasLeading);
  @override
  PopoverController? get popoverController => null;
}

/// Single radio entry inside a [MenuRadioGroup].
class MenuRadio<T> extends StatelessWidget implements MenuItem {
  const MenuRadio({
    Key? key,
    required this.value,
    required this.child,
    this.trailing,
    this.enabled = true,
    this.autoClose = true,
  }) : super(key: key);

  final T value;
  final Widget child;
  final Widget? trailing;
  final bool enabled;
  final bool autoClose;

  @override
  Widget build(BuildContext context) {
    final group = context.findAncestorWidgetOfExactType<MenuRadioGroup<T>>()!;
    final selected = group.value == value;
    final scaling = MediaQuery.of(context).textScaler.scale(1.0);

    return _MenuButton(
      leading: selected
          ? Icon(Iconsax.tick_circle, size: 12 * scaling)
          : SizedBox(width: 16 * scaling),
      enabled: enabled,
      trailing: trailing,
      autoClose: autoClose,
      onPressed: () => group.onChanged?.call(value),
      child: child,
    );
  }

  @override
  bool get hasLeading => true;
  @override
  PopoverController? get popoverController => null;
}

/// Interactive button that can either fire a callback or open a submenu.
class MenuButton extends StatelessWidget implements MenuItem {
  const MenuButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.subMenu,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.autoClose = true,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final List<MenuItem>? subMenu;
  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;
  final bool autoClose;

  @override
  Widget build(BuildContext context) {
    return _MenuButton(
      leading: leading,
      trailing: trailing,
      onPressed: onPressed,
      enabled: enabled,
      autoClose: autoClose,
      subMenu: subMenu,
      child: child,
    );
  }

  @override
  bool get hasLeading => leading != null;
  @override
  PopoverController? get popoverController => null;
}

/// Menu shortcut display
class MenuShortcut extends StatelessWidget {
  final ShortcutActivator activator;
  final Widget? combiner;

  const MenuShortcut({Key? key, required this.activator, this.combiner})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keys = _shortcutActivatorToKeys(activator);
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.hintColor,
    );

    List<Widget> children = [];
    for (int i = 0; i < keys.length; i++) {
      if (i > 0) {
        children.add(combiner ?? Text(' + ', style: textStyle));
      }
      children.add(_buildKeyDisplay(context, keys[i], textStyle));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _buildKeyDisplay(
      BuildContext context, LogicalKeyboardKey key, TextStyle? style) {
    String keyLabel = _getKeyLabel(key);
    return Text(keyLabel, style: style);
  }

  String _getKeyLabel(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.meta) return '⌘';
    if (key == LogicalKeyboardKey.shift) return '⇧';
    if (key == LogicalKeyboardKey.alt) return '⌥';
    if (key == LogicalKeyboardKey.control) return 'Ctrl';
    if (key == LogicalKeyboardKey.arrowUp) return '↑';
    if (key == LogicalKeyboardKey.arrowDown) return '↓';
    if (key == LogicalKeyboardKey.arrowLeft) return '←';
    if (key == LogicalKeyboardKey.arrowRight) return '→';
    return key.keyLabel;
  }

  List<LogicalKeyboardKey> _shortcutActivatorToKeys(
      ShortcutActivator activator) {
    if (activator is SingleActivator) {
      List<LogicalKeyboardKey> result = [];
      if (activator.control) result.add(LogicalKeyboardKey.control);
      if (activator.alt) result.add(LogicalKeyboardKey.alt);
      if (activator.shift) result.add(LogicalKeyboardKey.shift);
      if (activator.meta) result.add(LogicalKeyboardKey.meta);
      result.add(activator.trigger);
      return result;
    }
    return [LogicalKeyboardKey.keyA]; // Fallback
  }
}

/*─────────────────────────────────────────────────────────────────────────────
│ Internal implementation widgets                                             │
╰─────────────────────────────────────────────────────────────────────────────*/

/// Abstract menu element marker.
abstract class MenuItem extends Widget {
  const MenuItem({Key? key}) : super(key: key);
  bool get hasLeading;
  PopoverController? get popoverController;
}

/// Lightweight popover controller.
class PopoverController {
  void show({required BuildContext context, required WidgetBuilder builder}) {
    final entry = OverlayEntry(builder: (context) {
      // استخدام GestureDetector لإغلاق القائمة عند النقر خارجها
      return Stack(
        children: [
          // طبقة شفافة تغطي كامل الشاشة لالتقاط النقرات الخارجية
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: close,
              // جعلها شفافة لتمرير النقرات إلى العناصر تحتها
              child: Container(color: Colors.transparent),
            ),
          ),
          // محتوى القائمة الفعلي
          builder(context),
        ],
      );
    });
    Overlay.of(context, rootOverlay: true).insert(entry);
    _entries.add(entry);
  }

  bool get hasOpenPopover => _entries.isNotEmpty;

  void close() {
    for (final e in _entries) {
      e.remove();
    }
    _entries.clear();
  }

  final List<OverlayEntry> _entries = [];
}

/// Overlay widget that hosts a submenu.
class _SubMenuOverlay extends StatelessWidget {
  const _SubMenuOverlay({
    Key? key,
    required this.children,
    required this.controller,
    required this.parentOffset,
  }) : super(key: key);

  final List<MenuItem> children;
  final PopoverController controller;
  final Offset parentOffset;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;
    final double scaling = mediaQuery.textScaler.scale(1.0);

    // حساب الأبعاد المقدرة للقائمة
    final double estimatedWidth = 200 * scaling;
    final double estimatedHeight = 150 * scaling;

    // تعديل الموضع لتجنب تجاوز حدود الشاشة
    double left = parentOffset.dx;
    double top = parentOffset.dy;

    // تأكد من أن القائمة لا تتجاوز الحافة اليمنى للشاشة
    if (left + estimatedWidth > screenWidth) {
      left = screenWidth - estimatedWidth - 8 * scaling;
    }

    // تأكد من أن القائمة لا تتجاوز الحافة السفلية للشاشة
    if (top + estimatedHeight > screenHeight) {
      top = screenHeight - estimatedHeight - 8 * scaling;
    }

    // تأكد من أن القائمة لا تخرج عن الحافة العلوية أو اليسرى للشاشة
    left = left.clamp(8 * scaling, double.infinity);
    top = top.clamp(8 * scaling, double.infinity);

    // إضافة استماع لمفتاح Escape لإغلاق القائمة
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          controller.close();
        }
      },
      child: Stack(
        children: [
          Positioned(
            left: left,
            top: top,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(6 * scaling),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 150 * scaling,
                  maxWidth: 300 * scaling,
                  // تحديد ارتفاع أقصى لتجنب تجاوز حدود الشاشة
                  maxHeight: screenHeight * 0.8,
                ),
                child: _MenuGroup(
                  direction: Axis.vertical,
                  itemPadding: EdgeInsets.symmetric(
                      horizontal: 8 * scaling, vertical: 4 * scaling),
                  popoverOffset: Offset(8 * scaling, -4 * scaling),
                  onDismiss: controller.close,
                  children: children,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A collection of menu items that behave as a single focus region.
class _MenuGroup extends StatelessWidget {
  const _MenuGroup({
    Key? key,
    required this.children,
    required this.direction,
    required this.itemPadding,
    required this.popoverOffset,
    this.onDismiss,
  }) : super(key: key);

  final List<MenuItem> children;
  final Axis direction;
  final EdgeInsets itemPadding;
  final Offset? popoverOffset;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final hasLeading = children.any((c) => c.hasLeading);

    // إضافة اختصارات لوحة المفاتيح للتنقل في القائمة
    final Map<LogicalKeySet, Intent> shortcuts = {};

    // إضافة اختصار Escape لإغلاق القائمة
    shortcuts[LogicalKeySet(LogicalKeyboardKey.escape)] =
        const _CloseMenuIntent();

    // اختصارات التنقل بناءً على اتجاه القائمة
    if (direction == Axis.vertical) {
      shortcuts[LogicalKeySet(LogicalKeyboardKey.arrowUp)] =
          const _PreviousItemIntent();
      shortcuts[LogicalKeySet(LogicalKeyboardKey.arrowDown)] =
          const _NextItemIntent();
      shortcuts[LogicalKeySet(LogicalKeyboardKey.arrowLeft)] =
          const _CloseSubMenuIntent();
      shortcuts[LogicalKeySet(LogicalKeyboardKey.arrowRight)] =
          const _OpenSubMenuIntent();
    } else {
      shortcuts[LogicalKeySet(LogicalKeyboardKey.arrowLeft)] =
          const _PreviousItemIntent();
      shortcuts[LogicalKeySet(LogicalKeyboardKey.arrowRight)] =
          const _NextItemIntent();
      shortcuts[LogicalKeySet(LogicalKeyboardKey.arrowUp)] =
          const _CloseSubMenuIntent();
      shortcuts[LogicalKeySet(LogicalKeyboardKey.arrowDown)] =
          const _OpenSubMenuIntent();
    }

    // إضافة معالجات الإجراءات للاختصارات
    final Map<Type, Action<Intent>> actions = {
      _CloseMenuIntent: CallbackAction<_CloseMenuIntent>(
        onInvoke: (_) => onDismiss?.call(),
      ),
      _PreviousItemIntent: CallbackAction<_PreviousItemIntent>(
        onInvoke: (_) {
          // التنقل إلى العنصر السابق (سيتم تنفيذه بواسطة FocusTraversalGroup)
          return null;
        },
      ),
      _NextItemIntent: CallbackAction<_NextItemIntent>(
        onInvoke: (_) {
          // التنقل إلى العنصر التالي (سيتم تنفيذه بواسطة FocusTraversalGroup)
          return null;
        },
      ),
      _CloseSubMenuIntent: CallbackAction<_CloseSubMenuIntent>(
        onInvoke: (_) {
          // إغلاق القائمة الفرعية الحالية
          return null;
        },
      ),
      _OpenSubMenuIntent: CallbackAction<_OpenSubMenuIntent>(
        onInvoke: (_) {
          // فتح القائمة الفرعية للعنصر المحدد حاليًا
          return null;
        },
      ),
    };

    // Use IntrinsicWidth for vertical menus and wrap horizontal menus in a Container with width
    final content = direction == Axis.vertical
        ? IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          )
        : IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          );

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: actions,
        child: _MenuScope(
          hasLeading: hasLeading,
          direction: direction,
          itemPadding: itemPadding,
          popoverOffset: popoverOffset,
          onDismiss: onDismiss,
          child: FocusTraversalGroup(
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Holds shared layout data for descendant menu items.
class _MenuScope extends InheritedWidget {
  const _MenuScope({
    Key? key,
    required super.child,
    required this.direction,
    required this.itemPadding,
    required this.hasLeading,
    this.popoverOffset,
    this.onDismiss,
  }) : super(key: key);

  final Axis direction;
  final EdgeInsets itemPadding;
  final bool hasLeading;
  final Offset? popoverOffset;
  final VoidCallback? onDismiss;

  // إغلاق جميع القوائم المفتوحة
  void closeAll() {
    onDismiss?.call();
  }

  static _MenuScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_MenuScope>()!;
  }

  @override
  bool updateShouldNotify(covariant _MenuScope oldWidget) =>
      direction != oldWidget.direction ||
      itemPadding != oldWidget.itemPadding ||
      hasLeading != oldWidget.hasLeading ||
      onDismiss != oldWidget.onDismiss;
}

/// Button that participates in focus & submenu management.
class _MenuButton extends HookWidget {
  const _MenuButton({
    required this.child,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.autoClose = true,
    this.onPressed,
    this.subMenu,
  });

  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;
  final bool autoClose;
  final VoidCallback? onPressed;
  final List<MenuItem>? subMenu;

  @override
  Widget build(BuildContext context) {
    final focusNode = useFocusNode();
    final g = _MenuScope.of(context);
    final scaling = MediaQuery.textScalerOf(context).scale(1.0);
    final hasSub = subMenu != null && subMenu!.isNotEmpty;
    final controller = useMemoized(() => PopoverController());
    final buttonKey = useMemoized(() => GlobalKey(), []);

    void closeOthers() {
      // إغلاق جميع القوائم المفتوحة
      g.closeAll();
    }

    void openSubMenu() {
      // تأخير قليل للسماح للتخطيط بالاكتمال
      Future.microtask(() {
        final RenderBox? box =
            buttonKey.currentContext?.findRenderObject() as RenderBox?;
        if (box == null) return;

        // حساب الموضع المطلق للزر
        final Offset position = box.localToGlobal(Offset.zero);

        // تحديد موضع القائمة الفرعية بناءً على اتجاه القائمة الأصلية
        Offset menuOffset;
        if (g.direction == Axis.horizontal) {
          // إذا كانت القائمة الأصلية أفقية، افتح القائمة الفرعية لأسفل
          menuOffset = Offset(position.dx, position.dy + box.size.height);
        } else {
          // إذا كانت القائمة الأصلية عمودية، افتح القائمة الفرعية على اليمين
          menuOffset = Offset(position.dx + box.size.width, position.dy);
        }

        controller.show(
          context: context,
          builder: (ctx) => _SubMenuOverlay(
            parentOffset: menuOffset,
            controller: controller,
            children: subMenu!,
          ),
        );
      });
    }

    return MouseRegion(
      onEnter: (_) {
        if (hasSub && !controller.hasOpenPopover && enabled) openSubMenu();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled
            ? () {
                if (onPressed != null) onPressed!.call();
                if (hasSub) {
                  if (!controller.hasOpenPopover) openSubMenu();
                } else if (autoClose) {
                  closeOthers();
                }
              }
            : null,
        child: Focus(
          focusNode: focusNode,
          child: Container(
            key: buttonKey,
            padding: g.itemPadding
                .add(EdgeInsets.symmetric(horizontal: 8 * scaling)),
            color: controller.hasOpenPopover
                ? Theme.of(context).hoverColor
                : Colors.transparent,
            constraints: BoxConstraints(minHeight: 32 * scaling),
            child: Opacity(
              opacity: enabled ? 1.0 : 0.5,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (g.hasLeading)
                    SizedBox(
                        width: 16 * scaling,
                        child: leading ?? const SizedBox()),
                  DefaultTextStyle.merge(child: child),
                  if (trailing != null) ...[
                    SizedBox(width: 8 * scaling),
                    trailing!,
                  ] else if (hasSub) ...[
                    SizedBox(width: 8 * scaling),
                    Icon(Iconsax.arrow_right_3, size: 16 * scaling),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// نوايا لاختصارات لوحة المفاتيح
class _CloseMenuIntent extends Intent {
  const _CloseMenuIntent();
}

class _PreviousItemIntent extends Intent {
  const _PreviousItemIntent();
}

class _NextItemIntent extends Intent {
  const _NextItemIntent();
}

class _CloseSubMenuIntent extends Intent {
  const _CloseSubMenuIntent();
}

class _OpenSubMenuIntent extends Intent {
  const _OpenSubMenuIntent();
}
