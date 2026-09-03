import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../game/widgets/block_widget.dart';

/// Tutorial/How-to-Play screen with animated examples.
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.buttonBg.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.gridBorder, width: 1),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'HOW TO PLAY',
                      style: AppTextStyles.title.copyWith(
                        fontSize: 22,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),

              // Page view
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                  },
                  children: [
                    _TutorialPage(
                      icon: Icons.touch_app_rounded,
                      title: 'Pick & Drag',
                      description:
                          'Choose a block from the bottom tray and drag it onto the board.',
                      child: _buildDragExample(),
                    ),
                    _TutorialPage(
                      icon: Icons.grid_on_rounded,
                      title: 'Place Blocks',
                      description:
                          'Place blocks on the 9×9 grid. Blocks snap into valid positions.',
                      child: _buildGridExample(),
                    ),
                    _TutorialPage(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Clear Lines',
                      description:
                          'Complete full rows or columns to clear them and earn points!',
                      child: _buildClearExample(),
                    ),
                    _TutorialPage(
                      icon: Icons.local_fire_department_rounded,
                      title: 'Build Combos',
                      description:
                          'Clear lines on consecutive moves to build combos for bigger scores!',
                      child: _buildComboExample(),
                    ),
                    _TutorialPage(
                      icon: Icons.emoji_events_rounded,
                      title: 'Beat Your Best',
                      description:
                          'Keep playing until no pieces can fit. Try to beat your high score!',
                      child: _buildScoreExample(),
                    ),
                  ],
                ),
              ),

              // Page indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentPage == index
                            ? const Color(0xFF6C5CE7)
                            : AppColors.gridBorder,
                      ),
                    );
                  }),
                ),
              ),

              // Skip button
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFF8E80EF)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.buttonGlow.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      _currentPage == 4 ? 'GOT IT!' : 'SKIP',
                      style: AppTextStyles.button.copyWith(fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragExample() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _miniBlock(AppColors.blockColors[0], 24),
        const SizedBox(width: 12),
        const Icon(Icons.arrow_forward_rounded,
            color: AppColors.textSecondary, size: 28),
        const SizedBox(width: 12),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.cellEmpty,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.gridBorder),
          ),
          child: Center(
            child: _miniBlock(AppColors.blockColors[0], 20, opacity: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildGridExample() {
    return SizedBox(
      width: 120,
      height: 120,
      child: GridView.count(
        crossAxisCount: 4,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(16, (i) {
          if (i == 5 || i == 6 || i == 9 || i == 10) {
            return _miniBlock(AppColors.blockColors[4], 24);
          }
          return Container(
            decoration: BoxDecoration(
              color: AppColors.cellEmpty,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildClearExample() {
    return SizedBox(
      width: 160,
      height: 30,
      child: Row(
        children: List.generate(6, (i) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: _miniBlock(
                AppColors.blockColors[i % AppColors.blockColors.length],
                24,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildComboExample() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.textAccent.withValues(alpha: 0.2),
            AppColors.buttonGlow.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'COMBO x3! 🔥',
        style: AppTextStyles.combo.copyWith(fontSize: 22),
      ),
    );
  }

  Widget _buildScoreExample() {
    return Column(
      children: [
        Text('🏆', style: TextStyle(fontSize: 40)),
        Text(
          '12,450',
          style: AppTextStyles.score.copyWith(
            fontSize: 32,
            color: AppColors.textAccent,
          ),
        ),
      ],
    );
  }

  Widget _miniBlock(BlockColorSet colorSet, double size, {double opacity = 1}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorSet.light, colorSet.main, colorSet.dark],
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: colorSet.shadow.withValues(alpha: 0.3),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget child;

  const _TutorialPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF6C5CE7), size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTextStyles.title.copyWith(fontSize: 28, letterSpacing: 2),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }
}
