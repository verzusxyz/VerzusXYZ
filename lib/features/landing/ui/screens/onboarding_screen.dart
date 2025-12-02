import 'package:flutter/material.dart';
import 'package:verzus/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'headline': 'Play',
      'subtext': 'All games',
      'icon': 'play',
    },
    {
      'headline': 'Fair',
      'subtext': 'Skill only',
      'icon': 'fair',
    },
    {
      'headline': 'Earn',
      'subtext': 'Player pools',
      'icon': 'earn',
    },
    {
      'headline': 'Boost',
      'subtext': 'Auto tournaments',
      'icon': 'boost',
    },
    {
      'headline': 'Topics',
      'subtext': 'Put your money where your mouth is... yes/no or options questions',
      'icon': 'stake',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(
                    headline: _onboardingData[index]['headline']!,
                    subtext: _onboardingData[index]['subtext']!,
                    iconName: _onboardingData[index]['icon']!,
                  );
                },
              ),
            ),
            _buildPageIndicator(),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String headline,
    required String subtext,
    required String iconName,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder for visual.
          Icon(_getIconForName(iconName), size: 100, color: VerzusColors.primaryPurple),
          const SizedBox(height: 32.0),
          Text(headline, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 16.0),
          Text(subtext, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_onboardingData.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: _currentPage == index ? 12 : 8,
          height: _currentPage == index ? 12 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? VerzusColors.primaryPurple : VerzusColors.lightOnSurfaceVariant,
            borderRadius: BorderRadius.circular(12.0),
          ),
        );
      }),
    );
  }

  IconData _getIconForName(String iconName) {
    switch (iconName) {
      case 'play':
        return Icons.gamepad;
      case 'fair':
        return Icons.verified_user;
      case 'earn':
        return Icons.monetization_on;
      case 'boost':
        return Icons.trending_up;
      case 'stake':
        return Icons.account_balance_wallet;
      default:
        return Icons.help_outline;
    }
  }
}
