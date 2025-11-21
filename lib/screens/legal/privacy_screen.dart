import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
          tooltip: 'Back',
        ),
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔒 Privacy Policy',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Effective Date: 25/09/2025',
              style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Text(
              'This Privacy Policy describes how VerzusXYZ ("we", "our", "us") collects, uses, and protects your personal information.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            _numberedItem(context, '1. Information We Collect', [
              'Account Data: Username, email, and password.',
              'Gameplay Data: Game selections, match/tournament participation, results.',
              'Wallet Data: Transaction records, deposits, withdrawals, rewards.',
              'Device Data: Device type, OS, IP address, and usage logs.',
              'Verification Data: ID uploads, face checks, or screenshots (where required).',
            ]),
            _numberedItem(context, '2. How We Use Information', [
              'To provide services: matches, tournaments, polls, and wallet features.',
              'To process payments, entry fees, and distribute winnings.',
              'To verify user identity and prevent fraud.',
              'To send notifications about invites, results, and promotions.',
              'To improve platform features and security.',
            ]),
            _numberedItem(context, '3. Sharing of Information', [
              'We do not sell or rent your personal data. We may share data only:',
              'With service providers (payment processors, cloud hosting).',
              'With legal authorities if required by law.',
              'With other users, but only limited info (e.g., usernames, match results).',
            ]),
            _numberedItem(context, '4. Data Retention', [
              'Account data is kept as long as the account is active.',
              'Transaction records may be retained for compliance (up to 7 years).',
              'Users can request deletion of their accounts and related data.',
            ]),
            _numberedItem(context, '5. Security Measures', [
              'We use encryption, secure APIs, and regular audits.',
              'Users must safeguard their own login credentials.',
              'No system is 100% secure; we do not guarantee absolute protection.',
            ]),
            _numberedItem(context, '6. Cookies & Tracking', [
              'We use cookies for authentication and analytics.',
              'Users can disable cookies in their browsers, but some features may break.',
            ]),
            _numberedItem(context, '7. Children’s Privacy', [
              'The platform is not intended for children under 18.',
              'Accounts found to be underage will be terminated immediately.',
            ]),
            _numberedItem(context, '8. International Use', [
              'Data may be stored or processed outside your country.',
              'By using the platform, you consent to cross-border data transfers.',
            ]),
            _numberedItem(context, '9. Changes to Policy', [
              'We may update this Privacy Policy at any time.',
              'Users will be notified of major changes via email or in-app alert.',
            ]),
            _numberedItem(context, '10. Contact Us', [
              'For any questions or concerns, contact:',
              'Email: support@verzus.xyz',
              'Website: https://verzus.xyz',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _numberedItem(BuildContext context, String title, List<String> bullets) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...bullets.map((b) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 8, right: 10),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        b,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
