// import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verzus/services/auth_service.dart';
import 'package:verzus/screens/auth/login_screen.dart';
import 'package:verzus/screens/auth/signup_screen.dart';
import 'package:verzus/screens/matches/matches_screen.dart';
import 'package:verzus/screens/tournaments/tournaments_screen.dart';
import 'package:verzus/screens/topics/topics_screen.dart';
import 'package:verzus/screens/wallet/wallet_screen.dart';
import 'package:verzus/screens/profile/profile_screen.dart';
import 'package:verzus/screens/games/games_screen.dart';
import 'package:verzus/screens/games/submit_game_screen.dart';
import 'package:verzus/screens/admin/admin_dashboard.dart';
import 'package:verzus/screens/main_wrapper.dart';
import 'package:verzus/screens/legal/terms_screen.dart';
import 'package:verzus/screens/legal/privacy_screen.dart';
import 'package:verzus/screens/landing/landing_page.dart';

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
        builder: (context, state) => const LandingPage(),
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
          GoRoute(
            path: '/',
            builder: (context, state) => const GamesScreen(),
          ),
          GoRoute(
            path: '/matches',
            builder: (context, state) => const MatchesScreen(),
          ),
          GoRoute(
            path: '/tournaments',
            builder: (context, state) => const TournamentsScreen(),
          ),
          GoRoute(
            path: '/topics',
            builder: (context, state) => const TopicsScreen(),
          ),
          GoRoute(
            path: '/wallet',
            builder: (context, state) => const WalletScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/games',
            builder: (context, state) => const GamesScreen(),
          ),
          GoRoute(
            path: '/games/submit',
            builder: (context, state) => const SubmitGameScreen(),
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
        ],
      ),
    ],
  );
});
