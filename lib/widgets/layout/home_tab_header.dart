import 'package:flutter/material.dart';

import '../../config/theme.dart';

/// Visual tokens shared by the four signed-in tabs.
abstract final class HomeTabColors {
  static const canvas = Color(0xFFFCF8F2);
  static const neutral = Color(0xFFF5EEE4);
  static const border = Color(0xFFE9DED2);
  static const sage = Color(0xFF4E653D);
  static const sageTint = Color(0xFFE7EDD9);
  static const coral = Color(0xFFC96753);
  static const peachTint = Color(0xFFFBECE5);
  static const wheatTint = Color(0xFFFBF4DF);
  static const amber = Color(0xFF976319);
}

enum HomeTabArtwork { overview, transactions, profile }

class HomeTabHeader extends StatelessWidget {
  const HomeTabHeader({
    super.key,
    required this.title,
    required this.icon,
    this.artwork,
  });

  final String title;
  final IconData icon;
  final HomeTabArtwork? artwork;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTypography.pageTitle)),
          const SizedBox(width: 8),
          if (artwork case final art?)
            ExcludeSemantics(child: _HeaderArtwork(artwork: art))
          else
            ExcludeSemantics(
              child: SizedBox(
                width: 66,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: HomeTabColors.neutral,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Icon(icon, size: 35, color: HomeTabColors.sage),
                    const Positioned(
                      right: 1,
                      top: 1,
                      child: Icon(Icons.eco_outlined,
                          size: 19, color: HomeTabColors.sage),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderArtwork extends StatelessWidget {
  const _HeaderArtwork({required this.artwork});

  final HomeTabArtwork artwork;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width < 350 ? 96.0 : 128.0;
    final alignment = Alignment(artwork.index - 1.0, 0);
    return SizedBox(
      width: width,
      height: 82,
      child: ClipRect(
        child: OverflowBox(
          alignment: alignment,
          minWidth: width * 3,
          maxWidth: width * 3,
          minHeight: width,
          maxHeight: width,
          child: Image.asset(
            'assets/images/home_tab_art.png',
            fit: BoxFit.fill,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }
}
