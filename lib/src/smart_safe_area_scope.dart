import 'package:flutter/widgets.dart';

import 'smart_safe_area_config.dart';

/// Provides a [SmartSafeAreaConfig] to descendant widgets.
///
/// Prefer wrapping the app with [SmartSafeAreaHost], which also enables
/// edge-to-edge and adapts Flutter's own [SafeArea]. Use this widget if you
/// only need to override config for a subtree.
class SmartSafeAreaScope extends InheritedWidget {
  /// Creates a scope that exposes [config] to descendants.
  const SmartSafeAreaScope({
    super.key,
    required this.config,
    required super.child,
  });

  /// Configuration inherited by [SmartSafeArea] and related widgets.
  final SmartSafeAreaConfig config;

  /// The nearest config, or [SmartSafeAreaConfig.defaults] if none is found.
  static SmartSafeAreaConfig of(BuildContext context) {
    return maybeOf(context) ?? SmartSafeAreaConfig.defaults;
  }

  /// The nearest config, or `null` if no [SmartSafeAreaScope] is found.
  static SmartSafeAreaConfig? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SmartSafeAreaScope>()
        ?.config;
  }

  @override
  bool updateShouldNotify(SmartSafeAreaScope oldWidget) {
    return config != oldWidget.config;
  }
}
