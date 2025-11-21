import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verzus/services/auth_service.dart';
import 'package:verzus/theme.dart';
import 'package:verzus/widgets/verzus_button.dart';
import 'package:verzus/providers/theme_provider.dart';
import 'package:verzus/widgets/app_loading.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => _showSettingsDialog(context, ref),
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) => _buildProfileContent(context, ref, user),
        loading: () => const Center(child: AppLoading(label: 'Loading your profile...')),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Unable to load your profile. ${error.toString()}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, user) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  VerzusColors.primaryPurple.withValues(alpha: 0.1),
                  VerzusColors.primaryPurpleLight.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: VerzusColors.primaryPurple.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: VerzusColors.primaryPurple.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: VerzusColors.primaryPurple,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      user?.displayName?.isNotEmpty == true 
                        ? user!.displayName[0].toUpperCase()
                        : '?',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: VerzusColors.primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Name and Username
                Text(
                  user?.displayName ?? 'Unknown User',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${user?.username ?? 'unknown'}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // KYC Status
                _buildKycStatusChip(user?.kycStatus),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Stats Section
          _buildStatsSection(context),
          
          const SizedBox(height: 32),
          
          // Menu Items
          _buildMenuItem(
            context: context,
            icon: Icons.person_rounded,
            title: 'Edit Profile',
            subtitle: 'Update your information',
            onTap: () => _showEditProfileDialog(context, ref, user),
          ),
          
          const SizedBox(height: 12),
          
          _buildMenuItem(
            context: context,
            icon: Icons.history_rounded,
            title: 'Game History',
            subtitle: 'View your match and tournament history',
            onTap: () => context.go('/matches'),
          ),
          
          const SizedBox(height: 12),
          
          _buildMenuItem(
            context: context,
            icon: Icons.leaderboard_rounded,
            title: 'Leaderboards',
            subtitle: 'See your rankings',
            onTap: () => context.go('/tournaments'),
          ),
          
          const SizedBox(height: 12),
          
          _buildMenuItem(
            context: context,
            icon: Icons.share_rounded,
            title: 'Refer Friends',
            subtitle: 'Earn rewards for referrals',
            onTap: () => _showReferralDialog(context, user),
          ),
          
          const SizedBox(height: 12),
          
          _buildMenuItem(
            context: context,
            icon: Icons.help_rounded,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () => _showHelpSupportDialog(context),
          ),

          const SizedBox(height: 12),

          _buildMenuItem(
            context: context,
            icon: Icons.description_rounded,
            title: 'Terms & Conditions',
            subtitle: 'Read our latest T&C (Effective 25/09/2025)',
            onTap: () => context.push('/legal/terms'),
          ),

          const SizedBox(height: 12),

          _buildMenuItem(
            context: context,
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data (Effective 25/09/2025)',
            onTap: () => context.push('/legal/privacy'),
          ),
          
          const SizedBox(height: 32),
          
          // Sign Out Button
          SizedBox(
            width: double.infinity,
            child: VerzusButton.outline(
              onPressed: () => _signOut(context, ref),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.logout_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Sign Out'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildKycStatusChip(status) {
    final isVerified = status?.isVerified ?? false;
    final color = isVerified ? VerzusColors.accentGreen : VerzusColors.warningYellow;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified_rounded : Icons.pending_rounded,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            status?.displayName ?? 'Pending Verification',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Stats',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context: context,
                  label: 'Matches',
                  value: '0',
                  color: VerzusColors.accentGreen,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context: context,
                  label: 'Tournaments',
                  value: '0',
                  color: VerzusColors.accentOrange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context: context,
                  label: 'Win Rate',
                  value: '0%',
                  color: VerzusColors.primaryPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: VerzusColors.primaryPurple,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.notifications_rounded),
              title: const Text('Notifications'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Implement notification toggle
                },
                activeColor: VerzusColors.primaryPurple,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode_rounded),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: ref.read(themeModeProvider) == ThemeMode.dark,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                  // Close the bottom sheet immediately after toggling
                  Navigator.of(context).pop();
                },
                activeColor: VerzusColors.primaryPurple,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: VerzusButton.outline(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReferralDialog(BuildContext context, user) {
    final referralCode = user?.uid?.substring(0, 8).toUpperCase() ?? 'UNKNOWN';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refer Friends'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share your referral code and earn 1% of platform commission on their first usage!'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: VerzusColors.primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: VerzusColors.primaryPurple.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      referralCode,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: VerzusColors.primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Copy to clipboard
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Referral code copied!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, user) {
    final nameCtrl = TextEditingController(text: user?.displayName ?? '');
    final usernameCtrl = TextEditingController(text: user?.username ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: usernameCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(authServiceProvider).updateUserProfile(
                  displayName: nameCtrl.text.trim(),
                  username: usernameCtrl.text.trim(),
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Update failed: $e'), backgroundColor: VerzusColors.dangerRed),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showHelpSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text('Contact us at support@verzus.xyz or check the FAQ in the app menu.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _signOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final authService = ref.read(authServiceProvider);
                await authService.signOut();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error signing out: $e'),
                      backgroundColor: VerzusColors.dangerRed,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: VerzusColors.dangerRed),
            ),
          ),
        ],
      ),
    );
  }
}