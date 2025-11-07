import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class VerzusShimmers {
  static Widget listTile({double height = 64}) {
    return _ShimmerWrapper(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 12, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 10, width: 140, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 72, height: 36, color: Colors.white),
          ],
        ),
      ),
    );
  }

  static Widget card({double height = 120}) {
    return _ShimmerWrapper(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static Widget gridTile() {
    return _ShimmerWrapper(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 24, height: 24, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 12, color: Colors.white)),
              ],
            ),
            const Spacer(),
            Container(height: 10, width: 80, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _ShimmerWrapper extends StatelessWidget {
  final Widget child;
  const _ShimmerWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Shimmer.fromColors(
      baseColor: base.withValues(alpha: 0.6),
      highlightColor: base.withValues(alpha: 0.3),
      child: child,
    );
  }
}
