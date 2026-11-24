/// The kind of system navigation occupying the bottom of the screen.
enum SystemNavMode {
  /// No bottom system inset (desktop, web, or some emulators).
  none,

  /// Gesture navigation or iPhone home indicator.
  ///
  /// The inset is typically small (~16–34 logical pixels). By default, content
  /// is **not** lifted so the app stays flush with the screen edge.
  gesture,

  /// Android 3-button navigation (Back / Home / Recents).
  ///
  /// The inset is typically large (~48+ logical pixels). By default, content is
  /// lifted so it does not sit under the buttons.
  threeButton,
}
