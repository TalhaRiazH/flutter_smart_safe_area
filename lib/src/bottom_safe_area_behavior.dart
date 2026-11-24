/// How the package applies the bottom system inset to content.
enum BottomSafeAreaBehavior {
  /// Apply a bottom inset only when 3-button system navigation is detected.
  ///
  /// Gesture / home-indicator devices get **no** bottom content inset.
  /// This is the default and matches typical edge-to-edge app design.
  auto,

  /// Always apply the raw bottom system inset (gesture and 3-button).
  always,

  /// Never apply a bottom system inset.
  never,
}
