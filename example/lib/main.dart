import 'package:flutter/material.dart';
import 'package:flutter_smart_safe_area/flutter_smart_safe_area.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Step 1: let the app draw behind the status bar and navigation bar.
  await SmartSafeAreaHost.ensureEdgeToEdge();

  runApp(const SmartSafeAreaExampleApp());
}

class SmartSafeAreaExampleApp extends StatelessWidget {
  const SmartSafeAreaExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),

      // Step 2: turn the package on for the whole app.
      // No settings needed. It runs on `auto`.
      builder: SmartSafeAreaHost.materialBuilder(),

      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _tabBarColor = Color(0xFF12263A);

  static const _tiles = <(String, Color)>[
    ('Coral', Color(0xFFFF6B6B)),
    ('Sunset', Color(0xFFFF8C42)),
    ('Gold', Color(0xFFFFD166)),
    ('Lime', Color(0xFF9BE564)),
    ('Mint', Color(0xFF2EC4B6)),
    ('Sky', Color(0xFF4D96FF)),
    ('Violet', Color(0xFF7B61FF)),
    ('Pink', Color(0xFFFF5DA2)),
    ('Rose', Color(0xFFE85D75)),
    ('Teal', Color(0xFF00A896)),
  ];

  @override
  Widget build(BuildContext context) {
    // Optional. A normal Scaffold already follows auto.
    // This screen uses SmartSafeAreaScaffold only for the colors below.
    return SmartSafeAreaScaffold(
      // Fills the whole screen, even behind the system bars.
      backgroundColor: const Color(0xFF1B4F72),

      // Optional: color the area behind the clock and battery.
      topSafeAreaColor: const Color(0xFFFF8C42),

      // Optional: color the area behind Back / Home / Recents.
      // Matching the tab bar makes them look like one bar.
      bottomSafeAreaColor: _tabBarColor,

      // Moves up on 3-button phones, stays at the bottom on gesture phones.
      bottomNavigationBar: const _TabBar(color: _tabBarColor),

      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _tiles.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final (name, color) = _tiles[index];
          return Container(
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: const SizedBox(
        height: 80,
        child: Row(
          children: [
            _Tab(icon: Icons.home_outlined, label: 'Home'),
            _Tab(icon: Icons.explore_outlined, label: 'Explore'),
            _Tab(icon: Icons.settings_outlined, label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
