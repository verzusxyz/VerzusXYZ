// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:verzus/widgets/brand_logo.dart';
// import 'package:url_launcher/url_launcher.dart';

// class LandingPage extends StatefulWidget {
//   const LandingPage({super.key});

//   @override
//   State<LandingPage> createState() => _LandingPageState();
// }

// class _LandingPageState extends State<LandingPage> {
//   final ScrollController _scroll = ScrollController();

//   final Uri _googlePlayUrl = Uri.parse(
//       'https://play.google.com/store/apps/details?id=com.verzusxyz.app');
//   final Uri _appStoreUrl = Uri.parse(
//       'https://apps.apple.com/app/id0000000000');

//   Future<void> _launch(Uri url) async {
//     if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
//       // fallback to in-app if external not available (web)
//       await launchUrl(url, mode: LaunchMode.platformDefault);
//     }
//   }

//   void _scrollToKey(GlobalKey key) {
//     final ctx = key.currentContext;
//     if (ctx == null) return;
//     Scrollable.ensureVisible(
//       ctx,
//       duration: const Duration(milliseconds: 500),
//       curve: Curves.easeInOut,
//       alignment: 0.1,
//     );
//   }

//   final _aboutKey = GlobalKey();
//   final _whyKey = GlobalKey();
//   final _typesKey = GlobalKey();
//   final _howKey = GlobalKey();
//   final _reviewsKey = GlobalKey();

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isWide = MediaQuery.of(context).size.width >= 900;

//     return Scaffold(
//       backgroundColor: theme.colorScheme.surface,
//       appBar: AppBar(
//         title: const BrandTextLogo(height: 20),
//         centerTitle: false,
//         actions: [
//           TextButton(
//             onPressed: () => _scrollToKey(_aboutKey),
//             child: const Text('About'),
//           ),
//           TextButton(
//             onPressed: () => _scrollToKey(_whyKey),
//             child: const Text('Why VerzusXYZ'),
//           ),
//           TextButton(
//             onPressed: () => _scrollToKey(_typesKey),
//             child: const Text('Tournaments'),
//           ),
//           TextButton(
//             onPressed: () => _scrollToKey(_howKey),
//             child: const Text('How it works'),
//           ),
//           TextButton(
//             onPressed: () => _scrollToKey(_reviewsKey),
//             child: const Text('Reviews'),
//           ),
//           const SizedBox(width: 8),
//           TextButton.icon(
//             onPressed: () => context.go('/auth/login'),
//             icon: const Icon(Icons.login),
//             label: const Text('Get Started'),
//           ),
//           const SizedBox(width: 12),
//         ],
//       ),
//       body: Scrollbar(
//         controller: _scroll,
//         child: SingleChildScrollView(
//           controller: _scroll,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               _HeroSection(
//                 onGetStarted: () => context.go('/auth/signup'),
//                 onLearnMore: () => _scrollToKey(_aboutKey),
//                 onAndroidTap: () => _launch(_googlePlayUrl),
//                 onIosTap: () => _launch(_appStoreUrl),
//               ),
//               _Section(
//                 key: _aboutKey,
//                 title: 'About VerzusXYZ',
//                 child: Text(
//                   'VerzusXYZ is the first platform where anyone can create or join tournaments across all their favorite games — even those not featured in official esports circuits. We bring competition, community, and real rewards together in one app.',
//                   style: theme.textTheme.bodyLarge,
//                 ),
//               ),
//               _Section(
//                 key: _whyKey,
//                 title: 'Why VerzusXYZ?',
//                 child: _Bullets(items: const [
//                   'Play Any Game: Compete in popular titles beyond official esports.',
//                   'USDT Rewards: Fast, borderless payouts in USDT (TRON).',
//                   'No Waiting: Instant matchmaking & automated progression.',
//                   'Flexibility: Set prize splits, bracket sizes, and rules.',
//                   'Community Driven: Player voting and creator moderation for disputes.',
//                 ]),
//               ),
//               _Section(
//                 key: _typesKey,
//                 title: 'Tournament Types',
//                 child: _TwoColumns(
//                   isWide: isWide,
//                   left: _Bullets(
//                     headline: 'User-Created Tournaments',
//                     items: const [
//                       'Any bracket size (creator-defined).',
//                       'Prize split: Winner-takes-all, Top 3, or custom.',
//                       'Creator acts as judge for disputes.',
//                     ],
//                   ),
//                   right: _Bullets(
//                     headline: 'Auto-Tournaments',
//                     items: const [
//                       'Auto-created & shuffled from most played games.',
//                       'Fresh events always available to join.',
//                       'Zero waiting for a host.',
//                     ],
//                   ),
//                 ),
//               ),
//               _Section(
//                 key: _howKey,
//                 title: 'How It Works',
//                 child: _NumberedSteps(steps: const [
//                   'Download the app & create account.',
//                   'Deposit USDT via wallet or MoonPay.',
//                   'Join or create tournaments you love.',
//                   'Play & win! Get turn notifications.',
//                   'Withdraw earnings to your USDT wallet.',
//                 ]),
//               ),
//               _Section(
//                 title: 'Notifications & Fair Play',
//                 child: _Bullets(items: const [
//                   'Realtime notifications when matches are ready.',
//                   'Deadlines prevent stalling and ensure pace.',
//                   'No-show forfeits enforce fairness automatically.',
//                 ]),
//               ),
//               _Section(
//                 title: 'Built for a Global Community',
//                 child: Text(
//                   'VerzusXYZ is built for the world. Whether you’re in Africa, Asia, Europe, or the Americas, all you need is your game and your wallet. Supported anywhere USDT (TRON) is available.',
//                   style: theme.textTheme.bodyLarge,
//                 ),
//               ),
//               _Section(
//                 key: _reviewsKey,
//                 title: 'Player Reviews',
//                 child: _ReviewsGrid(
//                   reviews: const [
//                     Review(name: 'Amara K.', country: 'NG', text: 'Finally a place to run FIFA brackets with real stakes. Smooth payouts.'),
//                     Review(name: 'Diego R.', country: 'BR', text: 'Joined an auto-tournament in minutes. No waiting and great UX.'),
//                     Review(name: 'Lena S.', country: 'DE', text: 'The dispute tools are fair. Creator handled a no-show quickly.'),
//                     Review(name: 'Haruto M.', country: 'JP', text: 'USDT rewards are instant. Loving the global competition vibe.'),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
//                 child: Card(
//                   elevation: 0,
//                   color: theme.colorScheme.primaryContainer,
//                   child: Padding(
//                     padding: const EdgeInsets.all(24.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Text('Ready to Compete?', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 12),
//                         Wrap(
//                           alignment: WrapAlignment.center,
//                           spacing: 12,
//                           runSpacing: 12,
//                           children: [
//                             FilledButton(
//                               onPressed: () => context.go('/auth/signup'),
//                               child: const Text('Get Started Now'),
//                             ),
//                             OutlinedButton.icon(
//                               onPressed: () => _launch(Uri.parse('https://www.youtube.com')), // placeholder demo link
//                               icon: const Icon(Icons.play_circle_fill),
//                               label: const Text('Watch Demo'),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               _Footer(onPrivacy: () => context.go('/legal/privacy'), onTerms: () => context.go('/legal/terms')),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _HeroSection extends StatelessWidget {
//   final VoidCallback onGetStarted;
//   final VoidCallback onLearnMore;
//   final VoidCallback onAndroidTap;
//   final VoidCallback onIosTap;

//   const _HeroSection({
//     required this.onGetStarted,
//     required this.onLearnMore,
//     required this.onAndroidTap,
//     required this.onIosTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isWide = MediaQuery.of(context).size.width >= 900;

//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             theme.colorScheme.primary.withValues(alpha: 0.08),
//             theme.colorScheme.secondary.withValues(alpha: 0.08),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       padding: EdgeInsets.symmetric(
//         horizontal: isWide ? 48 : 16,
//         vertical: isWide ? 48 : 24,
//       ),
//       child: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 1200),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Play. Compete. Win — Anywhere, Anytime.',
//                         style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
//                     const SizedBox(height: 12),
//                     Text(
//                       'Join tournaments in your favorite games, win prizes in USDT (TRON), and be part of the next wave of global esports.',
//                       style: theme.textTheme.titleMedium,
//                     ),
//                     const SizedBox(height: 20),
//                     Wrap(
//                       spacing: 12,
//                       runSpacing: 12,
//                       children: [
//                         FilledButton(
//                           onPressed: onGetStarted,
//                           child: const Text('Get Started'),
//                         ),
//                         OutlinedButton(
//                           onPressed: onLearnMore,
//                           child: const Text('Learn More'),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Wrap(
//                       spacing: 12,
//                       children: [
//                         _StoreButton(
//                           label: 'Get it on Google Play',
//                           icon: Icons.android,
//                           onTap: onAndroidTap,
//                         ),
//                         _StoreButton(
//                           label: 'Download on the App Store',
//                           icon: Icons.apple,
//                           onTap: onIosTap,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               if (isWide) const SizedBox(width: 24),
//               if (isWide)
//                 Expanded(
//                   child: AspectRatio(
//                     aspectRatio: 16 / 10,
//                     child: Card(
//                       elevation: 0,
//                       clipBehavior: Clip.antiAlias,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                       child: Stack(
//                         fit: StackFit.expand,
//                         children: [
//                           Image.network(
//                             'https://images.unsplash.com/photo-1600861194942-f883de0dfe96?q=80&w=1200&auto=format&fit=crop',
//                             fit: BoxFit.cover,
//                           ),
//                           Container(color: Colors.black.withValues(alpha: 0.25)),
//                           Align(
//                             alignment: Alignment.bottomLeft,
//                             child: Padding(
//                               padding: const EdgeInsets.all(16.0),
//                               child: Text(
//                                 'Live stats, auto-tournaments, and seamless match flow',
//                                 style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _Section extends StatelessWidget {
//   final String title;
//   final Widget child;
//   const _Section({super.key, required this.title, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//       child: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 1000),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
//               const SizedBox(height: 12),
//               child,
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _Bullets extends StatelessWidget {
//   final String? headline;
//   final List<String> items;
//   const _Bullets({this.headline, required this.items});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (headline != null) ...[
//           Text(headline!, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
//           const SizedBox(height: 8),
//         ],
//         ...items.map((e) => Padding(
//               padding: const EdgeInsets.symmetric(vertical: 6.0),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Icon(Icons.check_circle, color: Colors.green),
//                   const SizedBox(width: 8),
//                   Expanded(child: Text(e, style: theme.textTheme.bodyLarge)),
//                 ],
//               ),
//             )),
//       ],
//     );
//   }
// }

// class _TwoColumns extends StatelessWidget {
//   final bool isWide;
//   final Widget left;
//   final Widget right;
//   const _TwoColumns({required this.isWide, required this.left, required this.right});

//   @override
//   Widget build(BuildContext context) {
//     if (!isWide) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [left, const SizedBox(height: 16), right],
//       );
//     }
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(child: left),
//         const SizedBox(width: 24),
//         Expanded(child: right),
//       ],
//     );
//   }
// }

// class _NumberedSteps extends StatelessWidget {
//   final List<String> steps;
//   const _NumberedSteps({required this.steps});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Column(
//       children: [
//         for (int i = 0; i < steps.length; i++)
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 6.0),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CircleAvatar(
//                   backgroundColor: theme.colorScheme.primary,
//                   child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(child: Text(steps[i], style: theme.textTheme.bodyLarge)),
//               ],
//             ),
//           ),
//       ],
//     );
//   }
// }

// class Review {
//   final String name;
//   final String country;
//   final String text;
//   const Review({required this.name, required this.country, required this.text});
// }

// class _ReviewsGrid extends StatelessWidget {
//   final List<Review> reviews;
//   const _ReviewsGrid({required this.reviews});

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     int crossAxisCount = 1;
//     if (width >= 1200) crossAxisCount = 3;
//     else if (width >= 800) crossAxisCount = 2;

//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: crossAxisCount,
//         mainAxisExtent: 140,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//       ),
//       itemCount: reviews.length,
//       itemBuilder: (context, index) {
//         final r = reviews[index];
//         return Card(
//           elevation: 0,
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.person, color: Colors.blueGrey),
//                     const SizedBox(width: 8),
//                     Text(r.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
//                     const Spacer(),
//                     const Icon(Icons.star, color: Colors.amber),
//                     const Icon(Icons.star, color: Colors.amber),
//                     const Icon(Icons.star, color: Colors.amber),
//                     const Icon(Icons.star, color: Colors.amber),
//                     const Icon(Icons.star_half, color: Colors.amber),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Expanded(child: Text('"${r.text}"')),
//                 const SizedBox(height: 8),
//                 Text(r.country, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey[600])),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class _Footer extends StatelessWidget {
//   final VoidCallback onPrivacy;
//   final VoidCallback onTerms;
//   const _Footer({required this.onPrivacy, required this.onTerms});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Container(
//       color: theme.colorScheme.surfaceVariant,
//       padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
//       child: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 1000),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Wrap(
//                 runSpacing: 8,
//                 spacing: 16,
//                 children: [
//                   TextButton(onPressed: () {}, child: const Text('Home')),
//                   TextButton(onPressed: () {}, child: const Text('FAQ')),
//                   TextButton(onPressed: () {}, child: const Text('Contact')),
//                   TextButton(onPressed: onPrivacy, child: const Text('Privacy Policy')),
//                   TextButton(onPressed: onTerms, child: const Text('Terms & Conditions')),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Text('© ${DateTime.now().year} VerzusXYZ. All rights reserved.', style: theme.textTheme.bodySmall),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _StoreButton extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final VoidCallback onTap;
//   const _StoreButton({required this.label, required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return OutlinedButton.icon(
//       onPressed: onTap,
//       icon: Icon(icon, color: Colors.blue),
//       label: Text(label),
//     );
//   }
// }

// lib/pages/landing_page.dart
// lib/pages/landing_page_bespoke.dart
// lib/pages/landing_page.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:verzus/widgets/brand_logo.dart';
// ignore: unused_import
import 'package:verzus/theme.dart'; // your provided theme file

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
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
