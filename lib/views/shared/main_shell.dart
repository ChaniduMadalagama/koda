// filepath: /Users/developer/Desktop/flutter/koda/lib/views/shared/main_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import 'app_background.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final location = GoRouterState.of(context).uri.toString();

    int calculateSelectedIndex(String location) {
      if (location.startsWith('/home')) return 0;
      if (location.startsWith('/explore')) return 1;
      if (location.startsWith('/journey')) return 2;
      if (location.startsWith('/profile')) return 3;
      return 0;
    }

    void onItemTapped(int index, BuildContext context) {
      switch (index) {
        case 0:
          context.go('/home');
          break;
        case 1:
          context.go('/explore');
          break;
        case 2:
          context.go('/journey');
          break;
        case 3:
          context.go('/profile');
          break;
      }
    }

    return Scaffold(
      body: AppBackground(
        child: child,
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BottomNavigationBar(
            currentIndex: calculateSelectedIndex(location),
            onTap: (index) => onItemTapped(index, context),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: colorScheme.onSurface,
            unselectedItemColor: Colors.grey[400],
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                label: 'Explore',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.assignment_outlined),
                label: 'Journey',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          onPressed: () {
            context.push(AppRouter.addJournal);
          },
          shape: const CircleBorder(),
          backgroundColor: const Color(0xFFFFB733),
          elevation: 4,
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
    );
  }
}
