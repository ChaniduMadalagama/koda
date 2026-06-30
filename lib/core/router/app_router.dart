// filepath: /Users/developer/Desktop/flutter/koda/lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../views/splash/splash_view.dart';
import '../../views/auth/auth_view.dart';
import '../../views/onboarding/setup_journal_view.dart';
import '../../views/home/home_view.dart';
import '../../views/journal/new_entry_view.dart';
import '../../views/shared/main_shell.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String auth = '/auth';
  static const String setupJournal = '/setup-journal';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String journey = '/journey';
  static const String profile = '/profile';
  static const String newEntry = '/new-entry';
  static const String journal = '/journal';

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: auth,
        builder: (context, state) => const AuthView(),
      ),
      GoRoute(
        path: setupJournal,
        builder: (context, state) => const SetupJournalView(),
      ),
      // New entry is OUTSIDE the shell so it gets a full-screen modal experience
      GoRoute(
        path: newEntry,
        builder: (context, state) => const NewEntryView(),
      ),
      GoRoute(
        path: journal,
        builder: (context, state) => const NewEntryView(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: home,
            builder: (context, state) => const HomeView(title: 'Koda Home'),
          ),
          GoRoute(
            path: explore,
            builder: (context, state) => const Scaffold(body: Center(child: Text('Explore'))),
          ),
          GoRoute(
            path: journey,
            builder: (context, state) => const Scaffold(body: Center(child: Text('Journey'))),
          ),
          GoRoute(
            path: profile,
            builder: (context, state) => const Scaffold(body: Center(child: Text('Profile'))),
          ),
        ],
      ),
    ],
  );
}
