import 'package:flutter/material.dart';
import 'package:flutter_smart_safe_area/flutter_smart_safe_area.dart';

const _navBarColor = Color(0xFF12263A);
const _topSafeColor = Color(0xFFFF8C42);
const _topOpacity = 0.45;
const _bottomOpacity = 0.72;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SmartSafeAreaHost.ensureEdgeToEdge();
  runApp(const TestSafeAreaApp());
}

double _navBarHeight(BuildContext context) {
  return (MediaQuery.sizeOf(context).height * 0.09).clamp(72.0, 104.0);
}

class TestSafeAreaApp extends StatelessWidget {
  const TestSafeAreaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF6EA8FF),
      ),
      builder: SmartSafeAreaHost.materialBuilder(
        config: const SmartSafeAreaConfig(
          extendBackground: true,
          bottomBehavior: BottomSafeAreaBehavior.auto,
          topSafeAreaColor: _topSafeColor,
          topSafeAreaOpacity: _topOpacity,
          bottomSafeAreaColor: _navBarColor,
          bottomSafeAreaOpacity: _bottomOpacity,
        ),
      ),
      home: const _HomeScreen(),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

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
    ('Indigo', Color(0xFF3D5A80)),
    ('Peach', Color(0xFFFFA69E)),
    ('Amber', Color(0xFFFFC300)),
    ('Aqua', Color(0xFF48CAE4)),
    ('Plum', Color(0xFF9B5DE5)),
    ('Leaf', Color(0xFF43AA8B)),
  ];

  @override
  Widget build(BuildContext context) {
    final mediaPadding = MediaQuery.paddingOf(context);

    return SmartSafeAreaScaffold(
      extendBackground: true,
      bottomBehavior: BottomSafeAreaBehavior.auto,
      backgroundColor: const Color(0xFF1B4F72),
      topSafeAreaColor: _topSafeColor,
      topSafeAreaOpacity: _topOpacity,
      showTopSafeArea: true,
      bottomSafeAreaColor: _navBarColor,
      bottomSafeAreaOpacity: _bottomOpacity,
      showBottomSafeArea: true,
      bottomNavigationBar: const _DemoTabBar(),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          16,
          mediaPadding.top + 8,
          16,
          mediaPadding.bottom + _navBarHeight(context) + 16,
        ),
        itemCount: _tiles.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final tile = _tiles[index];
          return Container(
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tile.$2,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              tile.$1,
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

class _DemoTabBar extends StatelessWidget {
  const _DemoTabBar();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final barHeight = _navBarHeight(context);
    final iconSize = (size.shortestSide * 0.07).clamp(28.0, 36.0);
    final fontSize = (iconSize * 0.42).clamp(12.0, 16.0);

    return ColoredBox(
      color: _navBarColor.withValues(alpha: _bottomOpacity),
      child: SizedBox(
        height: barHeight,
        child: Row(
          children: [
            _TabIcon(
              icon: Icons.home_outlined,
              label: 'Home',
              iconSize: iconSize,
              fontSize: fontSize,
            ),
            _TabIcon(
              icon: Icons.explore_outlined,
              label: 'Explore',
              iconSize: iconSize,
              fontSize: fontSize,
            ),
            _TabIcon(
              icon: Icons.settings_outlined,
              label: 'Settings',
              iconSize: iconSize,
              fontSize: fontSize,
            ),
          ],
        ),
      ),
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({
    required this.icon,
    required this.label,
    required this.iconSize,
    required this.fontSize,
  });

  final IconData icon;
  final String label;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
