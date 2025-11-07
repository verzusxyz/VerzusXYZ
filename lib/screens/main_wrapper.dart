import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verzus/theme.dart';
import 'package:verzus/widgets/brand_logo.dart';

class MainWrapper extends StatefulWidget {
  final Widget child;

  const MainWrapper({super.key, required this.child});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  bool _collapsed = false;

  int _currentIndexFromPath(String? path) {
    switch (path) {
      case '/':
      case '/games':
        return 0;
      case '/matches':
        return 1;
      case '/tournaments':
        return 2;
      case '/topics':
        return 3;
      case '/wallet':
        return 4;
      case '/profile':
        return 5;
      case '/admin':
        return 6;
      default:
        return 0;
    }
  }

  void _goTo(int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/matches');
        break;
      case 2:
        context.go('/tournaments');
        break;
      case 3:
        context.go('/topics');
        break;
      case 4:
        context.go('/wallet');
        break;
      case 5:
        context.go('/profile');
        break;
      case 6:
        context.go('/admin');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final isDesktop = defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;
    final useSidebar = (kIsWeb || isDesktop) && isWide;

    if (useSidebar) {
      final currentPath = GoRouterState.of(context).fullPath ?? '/';
      final currentIndex = _currentIndexFromPath(currentPath);
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              _Sidebar(
                collapsed: _collapsed,
                currentIndex: currentIndex,
                onToggle: () => setState(() => _collapsed = !_collapsed),
                onItemTap: _goTo,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.15),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: widget.child,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Use bottom nav for mobile and tablet
    return Scaffold(
      body: SafeArea(child: widget.child),
      bottomNavigationBar: const VerzusBottomNavBar(),
    );
  }
}

// ======================= SIDEBAR =======================

class _Sidebar extends StatelessWidget {
  final bool collapsed;
  final int currentIndex;
  final VoidCallback onToggle;
  final ValueChanged<int> onItemTap;

  const _Sidebar({
    required this.collapsed,
    required this.currentIndex,
    required this.onToggle,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = collapsed ? 76.0 : 240.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                if (collapsed)
                  const BrandMarkLogo(size: 24)
                else
                  const BrandTextLogo(height: 22),
                const Spacer(),
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    collapsed
                        ? Icons.keyboard_double_arrow_right_rounded
                        : Icons.keyboard_double_arrow_left_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  tooltip: collapsed ? 'Expand' : 'Collapse',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _SidebarItem(
            icon: Icons.gamepad_rounded,
            label: 'Games',
            selected: currentIndex == 0,
            collapsed: collapsed,
            onTap: () => onItemTap(0),
          ),
          _SidebarItem(
            icon: Icons.sports_esports_rounded,
            label: 'Matches',
            selected: currentIndex == 1,
            collapsed: collapsed,
            onTap: () => onItemTap(1),
          ),
          _SidebarItem(
            icon: Icons.emoji_events_rounded,
            label: 'Tournaments',
            selected: currentIndex == 2,
            collapsed: collapsed,
            onTap: () => onItemTap(2),
          ),
          _SidebarItem(
            icon: Icons.poll_rounded,
            label: 'Topics',
            selected: currentIndex == 3,
            collapsed: collapsed,
            onTap: () => onItemTap(3),
          ),
          _SidebarItem(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Wallet',
            selected: currentIndex == 4,
            collapsed: collapsed,
            onTap: () => onItemTap(4),
          ),
          _SidebarItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            selected: currentIndex == 5,
            collapsed: collapsed,
            onTap: () => onItemTap(5),
          ),
          _SidebarItem(
            icon: Icons.admin_panel_settings_rounded,
            label: 'Admin',
            selected: currentIndex == 6,
            collapsed: collapsed,
            onTap: () => onItemTap(6),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: VerzusColors.primaryPurple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: VerzusColors.primaryPurple.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_rounded,
                      color: VerzusColors.primaryPurple, size: 18),
                  if (!collapsed) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Secure & Live',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: VerzusColors.primaryPurple,
                              fontWeight: FontWeight.w700,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= SIDEBAR ITEM =======================

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: EdgeInsets.symmetric(
          horizontal: collapsed ? 12 : 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? VerzusColors.primaryPurple.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(
                  color: VerzusColors.primaryPurple.withValues(alpha: 0.2))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected
                  ? VerzusColors.primaryPurple
                  : colorScheme.onSurfaceVariant,
            ),
            if (!collapsed) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: selected
                            ? VerzusColors.primaryPurple
                            : colorScheme.onSurfaceVariant,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w600,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ======================= RESPONSIVE BOTTOM NAV =======================

class VerzusBottomNavBar extends StatelessWidget {
  const VerzusBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).fullPath ?? '/';
    final width = MediaQuery.of(context).size.width;

    final isSmall = width < 600;
    final isMedium = width >= 600 && width < 900;
    final isLarge = width >= 900;

    final items = [
      {'icon': Icons.gamepad_rounded, 'label': 'Games', 'path': '/'},
      {'icon': Icons.sports_esports_rounded, 'label': 'Matches', 'path': '/matches'},
      {'icon': Icons.emoji_events_rounded, 'label': 'Tournaments', 'path': '/tournaments'},
      {'icon': Icons.poll_rounded, 'label': 'Topics', 'path': '/topics'},
      {'icon': Icons.account_balance_wallet_rounded, 'label': 'Wallet', 'path': '/wallet'},
    ];

    final barColor = Theme.of(context).colorScheme.surface;
    final borderColor =
        Theme.of(context).colorScheme.outline.withValues(alpha: 0.15);

    return Container(
      margin: isLarge ? const EdgeInsets.all(16) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: isLarge ? barColor.withValues(alpha: 0.9) : barColor,
        border: isLarge
            ? Border.all(color: borderColor)
            : Border(top: BorderSide(color: borderColor, width: 0.6)),
        borderRadius: isLarge ? BorderRadius.circular(20) : BorderRadius.zero,
        boxShadow: isLarge
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
            : [],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isLarge ? 24 : isMedium ? 20 : 12,
            vertical: isLarge ? 12 : 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              final isActive = currentLocation == item['path'];
              return _ResponsiveNavBarItem(
                icon: item['icon'] as IconData,
                label: item['label'] as String,
                path: item['path'] as String,
                isActive: isActive,
                showLabel: !isSmall,
                isLarge: isLarge,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _ResponsiveNavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;
  final bool isActive;
  final bool showLabel;
  final bool isLarge;

  const _ResponsiveNavBarItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.isActive,
    required this.showLabel,
    required this.isLarge,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = VerzusColors.primaryPurple;
    final onSurface = colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: () => context.go(path),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? 16 : 8,
          vertical: isLarge ? 8 : 4,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isLarge ? 28 : 22,
              color: isActive ? primary : onSurface,
            ),
            if (showLabel) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isActive ? primary : onSurface,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      fontSize: isLarge ? 13 : 11,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
