// filepath: /Users/developer/Desktop/flutter/koda/lib/views/auth/auth_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleGoogleSignIn() {
    // Implement Google Sign-In logic here
    // After success, navigate to setup onboarding
    context.go('/setup-journal');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFDEAC).withOpacity(0.3),
              colorScheme.background,
              const Color(0xFFFCDBDE).withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    const Spacer(),
                    // App Logo & Header
                    _buildHeader(colorScheme, textTheme),
                    const SizedBox(height: 64),
                    // Action Section
                    _buildGoogleButton(colorScheme, textTheme),
                    const SizedBox(height: 32),
                    // Cosmetic dots
                    _buildDecorationDots(colorScheme),
                    const Spacer(),
                    // Footer
                    _buildFooter(textTheme),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuA-4I4ACruTsV-AAzG0zLZPt4Kp4Qsuz1pveb79Z3p-Dgz8yUnv1bjCjUhlOPFAPZT59YmyeiTaTSqhF5jZbBFAP6K07TGaQjW1R4g3YN-QGztD1OX3VzRxEdLePeNOmAIWg0u-VDkUzHD5wr3C8JRsxJLH_ZM5-MrLFLqACi8WZwsOyLZZWQzTH-y-uztRRZiyeAxvZMUpvqQ2Y8Jot5HpeH1lGoSwNykdDuIdUxVW9Vv-wpLAW-S2Md7h2eflWgQpRHbVgRGiPNNT',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Koda',
          style: textTheme.displayLarge?.copyWith(color: colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Text(
          'Welcome to your mindful space.',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton(ColorScheme colorScheme, TextTheme textTheme) {
    return InkWell(
      onTap: _handleGoogleSignIn,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://www.gstatic.com/images/branding/product/1x/gsa_512dp.png',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorationDots(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(colorScheme.primaryContainer.withOpacity(0.4)),
        const SizedBox(width: 8),
        _dot(colorScheme.secondaryContainer.withOpacity(0.4)),
        const SizedBox(width: 8),
        _dot(colorScheme.tertiaryContainer.withOpacity(0.4)),
      ],
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildFooter(TextTheme textTheme) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: textTheme.labelSmall?.copyWith(color: Colors.black45),
        children: const [
          TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
          TextSpan(text: ' and '),
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
          TextSpan(text: '.'),
        ],
      ),
    );
  }
}
