import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verzus/utils/responsive.dart';
import 'package:verzus/widgets/brand_logo.dart';
import 'package:verzus/widgets/recording_indicator.dart';

class MainWrapper extends StatefulWidget {
  final Widget child;
  const MainWrapper({super.key, required this.child});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  bool _collapsed = false;

  int _currentIndexFromPath(String? path) {
    if (path == null) return 0;
    if (path.startsWith('/matches')) return 1;
    if (path.startsWith('/tournaments')) return 2;
    if (path.startsWith('/topics')) return 3;
    if (path.startsWith('/wallet')) return 4;
    if (path.startsWith('/profile')) return 5;
    if (path.startsWith('/admin')) return 6;
    return 0; // Default to Games
  }

  void _goTo(int index) {
    switch (index) {
      case 0: context.go('/'); break;
      case 1: context.go('/matches'); break;
      case 2: context.go('/tournaments'); break;
      case 3: context.go('/topics'); break;
      case 4: context.go('/wallet'); break;
      case 5: context.go('/profile'); break;
      case 6: context.go('/admin'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final isDesktop = defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;
    final useSidebar = (kIsWeb || isDesktop) && responsive.widthPercent(1) >= 900;

    if (useSidebar) {
      final currentPath = GoRouterState.of(context).uri.toString();
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
                    border: Border(left: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
                      width: 0.5,
                    )),
                  ),
                  child: widget.child,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(child: widget.child),
      bottomNavigationBar: const VerzusBottomNavBar(),
    );
  }
}

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
    final responsive = Responsive(context);
    final colorScheme = Theme.of(context).colorScheme;
    final width = collapsed ? responsive.widthPercent(0.06) : responsive.widthPercent(0.18);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(right: BorderSide(color: colorScheme.outline.withOpacity(0.15), width: 0.5)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(responsive.diagonalPercent(0.015)),
            child: Row(
              children: [
                if (collapsed)
                  BrandMarkLogo(size: responsive.diagonalPercent(0.03))
                else
                  BrandTextLogo(height: responsive.diagonalPercent(0.025)),
                const Spacer(),
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    collapsed ? Icons.keyboard_double_arrow_right_rounded : Icons.keyboard_double_arrow_left_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: responsive.diagonalPercent(0.025),
                  ),
                  tooltip: collapsed ? 'Expand' : 'Collapse',
                ),
              ],
            ),
          ),
          SizedBox(height: responsive.heightPercent(0.01)),
          _SidebarItem(icon: Icons.gamepad_rounded, label: 'Games', selected: currentIndex == 0, collapsed: collapsed, onTap: () => onItemTap(0)),
          _SidebarItem(icon: Icons.sports_esports_rounded, label: 'Matches', selected: currentIndex == 1, collapsed: collapsed, onTap: () => onItemTap(1)),
          _SidebarItem(icon: Icons.emoji_events_rounded, label: 'Tournaments', selected: currentIndex == 2, collapsed: collapsed, onTap: () => onItemTap(2)),
          _SidebarItem(icon: Icons.poll_rounded, label: 'Topics', selected: currentIndex == 3, collapsed: collapsed, onTap: () => onItemTap(3)),
          _SidebarItem(icon: Icons.account_balance_wallet_rounded, label: 'Wallet', selected: currentIndex == 4, collapsed: collapsed, onTap: () => onItemTap(4)),
          _SidebarItem(icon: Icons.person_rounded, label: 'Profile', selected: currentIndex == 5, collapsed: collapsed, onTap: () => onItemTap(5)),
          _SidebarItem(icon: Icons.admin_panel_settings_rounded, label: 'Admin', selected: currentIndex == 6, collapsed: collapsed, onTap: () => onItemTap(6)),
          const Spacer(),
          if (!collapsed) Padding(
            padding: EdgeInsets.all(responsive.diagonalPercent(0.015)),
            child: const RecordingIndicator(),
          ),
          Padding(
            padding: EdgeInsets.all(responsive.diagonalPercent(0.015)),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(responsive.diagonalPercent(0.015)),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(responsive.diagonalPercent(0.015)),
                border: Border.all(color: colorScheme.primary.withOpacity(0.18)),
              ),
              child: Row(
                mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Icon(Icons.verified_rounded, color: colorScheme.primary, size: responsive.diagonalPercent(0.02)),
                  if (!collapsed) ...[
                    SizedBox(width: responsive.widthPercent(0.01)),
                    Expanded(
                      child: Text('Secure & Live',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary, fontWeight: FontWeight.w700,
                          fontSize: responsive.diagonalPercent(0.014),
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
    final responsive = Responsive(context);
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: responsive.widthPercent(0.01), vertical: responsive.heightPercent(0.005)),
        padding: EdgeInsets.symmetric(
          horizontal: collapsed ? responsive.widthPercent(0.015) : responsive.widthPercent(0.02),
          vertical: responsive.heightPercent(0.015),
        ),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(responsive.diagonalPercent(0.012)),
          border: selected ? Border.all(color: colorScheme.primary.withOpacity(0.2)) : null,
        ),
        child: Row(
          mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(icon, size: responsive.diagonalPercent(0.028), color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant),
            if (!collapsed) ...[
              SizedBox(width: responsive.widthPercent(0.015)),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: responsive.diagonalPercent(0.018),
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

class VerzusBottomNavBar extends StatelessWidget {
  const VerzusBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final currentLocation = GoRouterState.of(context).uri.toString();

    final items = [
      {'icon': Icons.gamepad_rounded, 'label': 'Games', 'path': '/'},
      {'icon': Icons.sports_esports_rounded, 'label': 'Matches', 'path': '/matches'},
      {'icon': Icons.emoji_events_rounded, 'label': 'Tournaments', 'path': '/tournaments'},
      {'icon': Icons.poll_rounded, 'label': 'Topics', 'path': '/topics'},
      {'icon': Icons.account_balance_wallet_rounded, 'label': 'Wallet', 'path': '/wallet'},
    ];

    final theme = Theme.of(context);
    final barColor = theme.colorScheme.surface;
    final borderColor = theme.colorScheme.outline.withOpacity(0.15);

    return Container(
      decoration: BoxDecoration(
        color: barColor,
        border: Border(top: BorderSide(color: borderColor, width: 0.6)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.widthPercent(0.02),
            vertical: responsive.heightPercent(0.01),
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

  const _ResponsiveNavBarItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final onSurface = colorScheme.onSurfaceVariant;
    final showLabel = responsive.widthPercent(1) > 400;

    return GestureDetector(
      onTap: () => context.go(path),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: responsive.widthPercent(0.03),
          vertical: responsive.heightPercent(0.01),
        ),
        decoration: BoxDecoration(
          color: isActive ? primary.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(responsive.diagonalPercent(0.015)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: responsive.diagonalPercent(0.03),
              color: isActive ? primary : onSurface,
            ),
            if (showLabel) ...[
              SizedBox(height: responsive.heightPercent(0.005)),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isActive ? primary : onSurface,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      fontSize: responsive.diagonalPercent(0.014),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
