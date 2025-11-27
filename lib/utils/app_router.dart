import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verzus/features/auth/ui/screens/login_screen.dart';
import 'package:verzus/features/auth/ui/screens/signup_screen.dart';
import 'package:verzus/features/games/ui/screens/games_screen.dart';
import 'package:verzus/features/games/ui/screens/submit_game_screen.dart';
import 'package:verzus/features/matches/ui/screens/matches_screen.dart';
import 'package:verzus/features/notifications/ui/screens/notifications_screen.dart';
import 'package:verzus/features/admin/ui/screens/admin_dashboard_screen.dart';
import 'package:verzus/features/landing/ui/screens/landing_screen.dart';
import 'package:verzus/features/legal/ui/screens/privacy_screen.dart';
import 'package:verzus/features/legal/ui/screens/terms_screen.dart';
import 'package:verzus/features/shell/ui/main_wrapper.dart';
import 'package:verzus/features/profile/ui/screens/profile_screen.dart';
import 'package:verzus/features/topics/ui/screens/topics_screen.dart';
import 'package:verzus/features/tournaments/ui/screens/tournaments_screen.dart';
import 'package:verzus/features/wallet/ui/screens/affiliate_screen.dart';
import 'package:verzus/features/wallet/ui/screens/loyalty_screen.dart';
import 'package:verzus/features/wallet/ui/screens/wallet_screen.dart';
import 'package:verzus/services/auth_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: kIsWeb ? '/landing' : '/',
    redirect: (context, state) {
      return authState.when(
        data: (user) {
          final isLoggedIn = user != null;
          final isOnAuthPage = state.fullPath?.startsWith('/auth') ?? false;
          final path = state.fullPath ?? state.uri.toString();
          final isOnPublicLanding = path == '/landing';
          final isOnPublicLegal = path.startsWith('/legal');

          if (!isLoggedIn) {
            if (kIsWeb) {
              // Allow unauthenticated users to view landing and legal on web
              if (!isOnAuthPage && !isOnPublicLanding && !isOnPublicLegal) {
                return '/landing';
              }
            } else {
              if (!isOnAuthPage) return '/auth/login';
            }
          } else {
            // Logged-in users shouldn't remain on auth or landing
            if (isOnAuthPage || isOnPublicLanding) return '/';
          }
          return null;
        },
        loading: () => null,
        error: (_, __) => '/auth/login',
      );
    },
    routes: [
      // Public landing (web)
      GoRoute(
        path: '/landing',
        builder: (context, state) => const LandingScreen(),
      ),
      // Standalone legal pages (no nav shell)
      GoRoute(
        path: '/legal/terms',
        builder: (context, state) => const TermsAndConditionsScreen(),
      ),
      GoRoute(
        path: '/legal/privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      // Auth routes
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      // Main app with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainWrapper(child: child);
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const GamesScreen()),
          GoRoute(path: '/matches', builder: (context, state) => const MatchesScreen()),
          GoRoute(path: '/tournaments', builder: (context, state) => const TournamentsScreen()),
          GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
          GoRoute(path: '/topics', builder: (context, state) => const TopicsScreen()),
          GoRoute(path: '/wallet', builder: (context, state) => const WalletScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
          GoRoute(path: '/games', builder: (context, state) => const GamesScreen()),
          GoRoute(path: '/games/submit', builder: (context, state) => const SubmitGameScreen()),
          GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
          GoRoute(path: '/wallet/affiliate', builder: (context, state) => const AffiliateScreen()),
          GoRoute(path: '/wallet/loyalty', builder: (context, state) => const LoyaltyScreen()),
        ],
      ),
    ],
  );
});
