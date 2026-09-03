import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// Renders a single block cell with depth effect.
class BlockWidget extends StatelessWidget {
  final BlockColorSet colorSet;
  final double size;
  final bool clearing;
  final double opacity;

  const BlockWidget({
    super.key,
    required this.colorSet,
    required this.size,
    this.clearing = false,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.cellBorderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorSet.light, colorSet.main, colorSet.dark],
            stops: const [0.0, 0.4, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: colorSet.shadow.withValues(alpha: 0.5),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: colorSet.main.withValues(alpha: 0.3),
              offset: const Offset(0, 0),
              blurRadius: clearing ? 12 : 0,
              spreadRadius: clearing ? 2 : 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Inner highlight
            Positioned(
              top: 1,
              left: 1,
              right: size * 0.4,
              bottom: size * 0.4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.cellBorderRadius - 1),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty cell on the grid.
class EmptyCellWidget extends StatelessWidget {
  final double size;

  const EmptyCellWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.cellEmpty,
        borderRadius: BorderRadius.circular(AppConstants.cellBorderRadius),
        border: Border.all(
          color: AppColors.cellBorder,
          width: 0.5,
        ),
      ),
    );
  }
}

/// Preview highlight cell (shown when dragging).
class PreviewCellWidget extends StatelessWidget {
  final double size;
  final bool valid;

  const PreviewCellWidget({
    super.key,
    required this.size,
    required this.valid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: valid ? AppColors.validPlacement : AppColors.invalidPlacement,
        borderRadius: BorderRadius.circular(AppConstants.cellBorderRadius),
        border: Border.all(
          color: valid
              ? const Color(0xFF48DBAB).withValues(alpha: 0.5)
              : const Color(0xFFFF6B6B).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
    );
  }
}
