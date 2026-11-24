/// Smart SafeArea for Flutter.
///
/// Detects whether the device is showing **3-button system navigation** or
/// **gesture / home-indicator** navigation, then insets only the content that
/// needs it. Backgrounds stay edge-to-edge by default.
///
/// ```dart
/// void main() {
///   WidgetsFlutterBinding.ensureInitialized();
///   SmartSafeAreaHost.ensureEdgeToEdge();
///   runApp(const MyApp());
/// }
///
/// class MyApp extends StatelessWidget {
///   const MyApp({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       builder: SmartSafeAreaHost.materialBuilder(),
///       home: SmartSafeAreaScaffold(
///         backgroundColor: Colors.black,
///         body: YourScreen(),
///       ),
///     );
///   }
/// }
/// ```
library;

export 'src/bottom_safe_area_behavior.dart';
export 'src/smart_safe_area.dart';
export 'src/smart_safe_area_color_bars.dart';
export 'src/smart_safe_area_config.dart';
export 'src/smart_safe_area_host.dart';
export 'src/smart_safe_area_insets.dart';
export 'src/smart_safe_area_scaffold.dart';
export 'src/smart_safe_area_scope.dart';
export 'src/smart_safe_area_simulation_scope.dart';
export 'src/smart_safe_area_simulator.dart';
export 'src/smart_system_nav_bar.dart';
export 'src/system_nav.dart';
export 'src/system_nav_mode.dart';
