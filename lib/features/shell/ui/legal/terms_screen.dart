import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

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
        title: const Text('Terms & Conditions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📜 Terms & Conditions (T&C)',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Effective Date: 25/09/2025',
              style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, 'Welcome to VerzusXYZ (the “Platform”). By creating an account, accessing, or using VerzusXYZ, you agree to these Terms & Conditions. Please read them carefully.'),
            const SizedBox(height: 16),
            _numberedItem(context, '1. Eligibility', [
              'Users must be 18 years or older (or the legal age of majority in their country).',
              'Users are responsible for complying with local laws regarding skill-based competitions, entry fees, and rewards.',
            ]),
            _numberedItem(context, '2. Account Registration', [
              'You must provide accurate details (username, email, gamer tags, etc.).',
              'You are responsible for maintaining your login credentials securely.',
              'Multiple/fake accounts may be suspended without notice.',
            ]),
            _numberedItem(context, '3. Services Offered', [
              'Matches: 1v1, free-for-all, or team-based competitions.',
              'Tournaments: Auto or user-created, with brackets and scheduled play.',
              'Topics & Polls: Voting-based or knowledge challenges with entry pools.',
              'Wallet: Handles deposits, entry fees, winnings, and withdrawals.',
            ]),
            _numberedItem(context, '4. Entry Fees & Rewards', [
              'Entry fees are set by users (except fixed tiers for auto tournaments: \$5, \$10, \$25, \$50).',
              'Winnings are distributed automatically to the winners’ in-app wallets, minus the platform’s commission (currently 20%).',
              'Auto Tournaments Payout Example:',
              '1st Place: 60% of prize pool.',
              '2nd Place: 25%.',
              '3rd Place: 15%.',
            ]),
            _numberedItem(context, '5. Platform Commission', [
              'Platform charges a 20% commission on all winnings.',
              'Affiliate rewards are paid out from the platform’s share, not from the player’s 20% cut.',
            ]),
            _numberedItem(context, '6. Match & Tournament Lifecycle', [
              'Users must only submit fair and accurate results.',
              'Any attempt to cheat, exploit, or manipulate outcomes leads to immediate ban and forfeiture of funds.',
              'The platform reserves the right to review disputes and declare winners.',
            ]),
            _numberedItem(context, '7. Responsibilities & Limitations', [
              'VerzusXYZ is not responsible for poor internet connectivity, device issues, or third-party game outages.',
              'External games (like Chess.com) are linked via usernames, but gameplay itself remains under their control.',
              'The platform does not guarantee continuous availability of services.',
            ]),
            _numberedItem(context, '8. Withdrawal & Refunds', [
              'Withdrawals are processed to supported payment methods (USDT, Fiat, cards).',
              'Processing times may vary.',
              'Entry fees are non-refundable once a match or tournament starts.',
            ]),
            _numberedItem(context, '9. Prohibited Conduct', [
              'Using bots, hacks, or scripts.',
              'Harassment, offensive behavior, or impersonation.',
              'Money laundering, fraudulent deposits, or chargebacks.',
            ]),
            _numberedItem(context, '10. Termination', [
              'The platform may suspend or terminate accounts for violations.',
              'Users may close their accounts at any time, subject to pending payouts.',
            ]),
            _numberedItem(context, '11. Governing Law', [
              'These Terms are governed by the laws of most Country/Jurisdiction.',
              'Disputes may be resolved via arbitration or in courts of competent jurisdiction.',
            ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge,
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
