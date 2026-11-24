import 'package:flutter/widgets.dart';

/// When [locked] is true, smart insets stay on the ancestor [MediaQuery]
/// instead of the live [FlutterView] (used by [SmartSafeAreaSimulator]).
class SmartSafeAreaSimulationScope extends InheritedWidget {
  /// Creates a simulation lock for descendant inset reads.
  const SmartSafeAreaSimulationScope({
    super.key,
    required this.locked,
    required super.child,
  });

  /// Whether to ignore live engine insets.
  final bool locked;

  /// `true` when a simulator is forcing MediaQuery insets.
  static bool lockedOf(BuildContext context) {
    return maybeOf(context)?.locked ?? false;
  }

  /// The nearest simulation scope, if any.
  static SmartSafeAreaSimulationScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SmartSafeAreaSimulationScope>();
  }

  @override
  bool updateShouldNotify(SmartSafeAreaSimulationScope oldWidget) {
    return locked != oldWidget.locked;
  }
}
