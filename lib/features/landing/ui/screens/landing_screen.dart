import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:verzus/widgets/brand_logo.dart';
import 'package:verzus/features/landing/ui/screens/onboarding_screen.dart';
// ignore: unused_import
import 'package:verzus/theme.dart'; // your provided theme file

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingScreen> {
  final PageController _pageController = PageController();

  // Keep keys so nav can reference sections if needed later
  final _heroKey = GlobalKey();
  final _featuresKey = GlobalKey();
  final _howItWorksKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _faqKey = GlobalKey();
  final _joinKey = GlobalKey();
  final _ctaKey = GlobalKey();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _scrollToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  // Utility: responsive scale for font sizes / paddings
  double _scaleForWidth(double width, double base) {
    if (width < 420) return base * 0.82;
    if (width < 600) return base * 0.9;
    if (width > 1400) return base * 1.12;
    return base;
  }

  @override
  Widget build(BuildContext context) {
    // Responsive check
    if (!kIsWeb || MediaQuery.of(context).size.width < 768) {
      return const OnboardingScreen();
    }

    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    // navItems typed as List<Map<String, dynamic>> so casting works safely
    final List<Map<String, dynamic>> navItems = [
      {'label': 'Home', 'index': 0},
      {'label': 'Features', 'index': 1},
      {'label': 'How It Works', 'index': 2},
      {'label': 'About', 'index': 3},
      {'label': 'FAQs', 'index': 4},
      {'label': 'Join', 'index': 5},
      // contact intentionally removed per your request
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0.3,
        title: const BrandTextLogo(height: 36),
        actions: kIsWeb && width > 800
            ? [
                for (final i in navItems)
                  TextButton(
                    onPressed: () => _scrollToPage(i['index'] as int),
                    child: Text(
                      i['label'] as String, // fixed: cast Object -> String
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        fontSize: _scaleForWidth(width, 15),
                      ),
                    ),
                  ),
                const SizedBox(width: 12)
              ]
            : null,
      ),
      drawer: width > 800
          ? null
          : Drawer(
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  children: [
                    const Center(child: BrandTextLogo(height: 48)),
                    const Divider(),
                    for (final i in navItems)
                      ListTile(
                        title: Text(i['label'] as String),
                        onTap: () {
                          Navigator.pop(context);
                          _scrollToPage(i['index'] as int);
                        },
                      ),
                  ],
                ),
              ),
            ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          children: [
            _section(
                _heroKey,
                _HeroSection(
                  onPlayStoreTap: () => _launchURL(
                      'https://play.google.com/store/apps/details?id=com.verzusxyz.app'),
                  onAppStoreTap: () => _launchURL(
                      'https://apps.apple.com/app/verzusxyz/id0000000000'),
                  onGetStarted: () => context.go('/auth/login'),
                )),
            _section(_featuresKey, const _FeaturesSection()),
            _section(_howItWorksKey, const _HowItWorksSection()),
            _section(_aboutKey, const _AboutSection()),
            _section(_faqKey, const _FAQSection()),
            _section(
                _joinKey,
                _JoinSection(
                  onJoinNow: () => context.go('/auth/login'),
                )),
            _section(
                _ctaKey,
                _CTASection(
                  onGetStarted: () => context.go('/auth/login'),
                )),
          ],
        ),
      ),
      bottomNavigationBar: _FooterSection(),
    );
  }

  // Outline-card wrapper identical to your previous card look (rounded + outline)
  Widget _section(Key? key, Widget child) {
    return LayoutBuilder(
      key: key,
      builder: (context, constraints) {
        final maxWidth = 1200.0;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color:
                        // ignore: deprecated_member_use
                        Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------- HERO SECTION ---------------- //

class _HeroSection extends StatelessWidget {
  final VoidCallback onPlayStoreTap;
  final VoidCallback onAppStoreTap;
  final VoidCallback onGetStarted;

  const _HeroSection({
    required this.onPlayStoreTap,
    required this.onAppStoreTap,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 600;

    double fs(double base) {
      if (width < 420) return base * 0.82;
      if (width < 600) return base * 0.9;
      if (width > 1400) return base * 1.12;
      return base;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // main headline in a FittedBox to avoid overflow
        FittedBox(
          child: Text(
            'Compete. Dominate. Earn.',
            textAlign: TextAlign.center,
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: fs(40),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Join tournaments across your favorite games. Compete globally, earn real rewards, and level up your legacy on VerzusXYZ.',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: fs(isSmall ? 16 : 18),
            height: 1.4,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            GestureDetector(
              onTap: onPlayStoreTap,
              child: SvgPicture.asset(
                'assets/badges/google_play_store_badge.svg',
                height: isSmall ? 56 : 72,
              ),
            ),
            GestureDetector(
              onTap: onAppStoreTap,
              child: SvgPicture.asset(
                'assets/badges/apple_app_store_badge.svg',
                height: isSmall ? 56 : 72,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: onGetStarted,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'Get Started',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fs(17),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------- FEATURES SECTION (outlined cards preserved) ---------------- //

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  final List<Map<String, String>> features = const [
    {
      'title': 'Play All Your Favorite Games',
      'desc':
          'Compete in tournaments across the games you already love — no extra setup required.',
      'asset': 'assets/3d_hands/hand_play.svg'
    },
    {
      'title': 'Earn Real Rewards',
      'desc':
          'Every match gives you the chance to win verified prizes — instantly redeemable.',
      'asset': 'assets/3d_hands/hand_coin.svg'
    },
    {
      'title': 'Auto Tournaments',
      'desc':
          'Smart tournaments form automatically from trending games and player stats.',
      'asset': 'assets/3d_hands/hand_trophy.svg'
    },
    {
      'title': 'Live Leaderboards',
      'desc':
          'Track your ranks, wins, and stats in real time as you climb globally.',
      'asset': 'assets/3d_hands/hand_leaderboard.svg'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 600;

    return Column(
      children: [
        Text(
          'Why VerzusXYZ?',
          textAlign: TextAlign.center,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isSmall ? 24 : 30,
          ),
        ),
        const SizedBox(height: 30),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 30,
          children: features
              .map((f) => ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isSmall ? width * 0.9 : 260,
                      minWidth: 200,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          // ignore: deprecated_member_use
                          color: theme.colorScheme.outline.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 16),
                      child: Column(
                        children: [
                          SvgPicture.asset(f['asset']!, height: 74),
                          const SizedBox(height: 12),
                          Text(
                            f['title']!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            f['desc']!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

// ---------------- HOW IT WORKS (outlined small cards) ---------------- //

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 700;

    final steps = [
      {'title': 'Create Account', 'desc': 'Sign up and set your gamer tag.'},
      {'title': 'Join a Tournament', 'desc': 'Pick daily or auto tournaments.'},
      {'title': 'Play & Compete', 'desc': 'Face players and climb ranks.'},
      {'title': 'Claim Rewards', 'desc': 'Winners get instant payouts.'},
    ];

    return Column(
      children: [
        Text(
          'How It Works',
          textAlign: TextAlign.center,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isSmall ? 24 : 30,
          ),
        ),
        const SizedBox(height: 30),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 20,
          children: steps
              .map(
                (s) => ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: isSmall ? width * 0.9 : 260),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        // ignore: deprecated_member_use
                        color: theme.colorScheme.outline.withOpacity(0.12),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          s['title']!,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s['desc']!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ---------------- ABOUT ---------------- //

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 600;

    return Column(
      children: [
        Text(
          'About VerzusXYZ',
          textAlign: TextAlign.center,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isSmall ? 24 : 30,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'VerzusXYZ is a global competitive gaming hub that turns your passion into progress — fair tournaments, real rewards, and a community that grows with you.',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: isSmall ? 15 : 17,
            height: 1.5,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ---------------- FAQ (collapsible ExpansionTiles) ---------------- //

class _FAQSection extends StatelessWidget {
  const _FAQSection();

  final List<Map<String, String>> faqs = const [
    {
      'q': 'Is VerzusXYZ free to use?',
      'a':
          'Yes — signing up and joining many tournaments is free. Some premium events may have entry conditions.'
    },
    {
      'q': 'How do I earn rewards?',
      'a':
          'Win tournaments, complete challenges, or place on leaderboards. Rewards are verified and credited to your Verzus wallet.'
    },
    {
      'q': 'What games can I play?',
      'a':
          'We support popular mobile and console titles — and we add new titles based on player demand.'
    },
    {
      'q': 'How do payouts work?',
      'a':
          'Confirmed winners get payouts to the Verzus wallet. Withdrawals use supported local payment rails.'
    },
    {
      'q': 'Can I host tournaments?',
      'a':
          'Yes — verified creators and partners can host tournaments with custom rules and prizes.'
    },
    {
      'q': 'Is cheating prevented?',
      'a':
          'We use anti-cheat logic, reporting, and manual verification where required to keep play fair.'
    },
    {
      'q': 'How can I get help?',
      'a':
          'Use the in-app support chat or contact support@verzus.xyz for assistance.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Frequently Asked Questions',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isSmall ? 24 : 30,
          ),
        ),
        const SizedBox(height: 20),
        Column(
          children: faqs
              .map((f) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              // ignore: deprecated_member_use
                              .withOpacity(0.08)),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      childrenPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      title: Text(
                        f['q']!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      children: [
                        Text(
                          f['a']!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

// ---------------- JOIN ---------------- //

class _JoinSection extends StatelessWidget {
  final VoidCallback onJoinNow;
  const _JoinSection({required this.onJoinNow});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 600;

    return Column(
      children: [
        Text(
          'Ready to Join the Arena?',
          textAlign: TextAlign.center,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isSmall ? 24 : 30,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Sign up now and compete — earn real rewards and climb the leaderboards.',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: isSmall ? 14 : 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onJoinNow,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Join VerzusXYZ',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}

// ---------------- CTA ---------------- //

class _CTASection extends StatelessWidget {
  final VoidCallback onGetStarted;
  const _CTASection({required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 600;

    return Column(
      children: [
        Text(
          'Level Up Your Competition',
          textAlign: TextAlign.center,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isSmall ? 24 : 30,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Join thousands of gamers already competing and winning every day!',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: isSmall ? 14 : 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onGetStarted,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Get Started Now',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}

// ---------------- FOOTER (includes Privacy + Terms) ---------------- //

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainerHighest, // fallback
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BrandTextLogo(height: 28),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            children: [
              TextButton(
                onPressed: () => GoRouter.of(context).push('/legal/privacy'),
                child: Text(
                  'Privacy Policy',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.primary),
                ),
              ),
              TextButton(
                onPressed: () => GoRouter.of(context).push('/legal/terms'),
                child: Text(
                  'Terms & Conditions',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '© 2025 VerzusXYZ. All rights reserved.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
