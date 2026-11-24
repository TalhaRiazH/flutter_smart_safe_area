import 'package:flutter/widgets.dart';

/// The real system [viewPadding] captured before the host rewrites the
/// bottom inset that bottom bars read.
class SmartSafeAreaRawPadding extends InheritedWidget {
  /// Records [padding] for descendants.
  const SmartSafeAreaRawPadding({
    super.key,
    required this.padding,
    required super.child,
  });

  /// Unmodified system view padding for this frame.
  final EdgeInsets padding;

  /// The captured padding, or `null` when no host is above [context].
  static EdgeInsets? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SmartSafeAreaRawPadding>()
        ?.padding;
  }

  @override
  bool updateShouldNotify(SmartSafeAreaRawPadding oldWidget) {
    return padding != oldWidget.padding;
  }
}
