// filepath: /Users/developer/Desktop/flutter/koda/lib/views/splash/splash_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: 0,
      end: -10,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      context.go('/auth');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background Decorative Elements
          Positioned(
            top: -100,
            left: -100,
            child: _BlurredCircle(
              color: colorScheme.primaryContainer.withOpacity(0.4),
              size: 300,
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: _BlurredCircle(
              color: colorScheme.secondaryContainer.withOpacity(0.3),
              size: 400,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            right: 50,
            child: _BlurredCircle(
              color: colorScheme.tertiaryContainer.withOpacity(0.2),
              size: 200,
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuA-4I4ACruTsV-AAzG0zLZPt4Kp4Qsuz1pveb79Z3p-Dgz8yUnv1bjCjUhlOPFAPZT59YmyeiTaTSqhF5jZbBFAP6K07TGaQjW1R4g3YN-QGztD1OX3VzRxEdLePeNOmAIWg0u-VDkUzHD5wr3C8JRsxJLH_ZM5-MrLFLqACi8WZwsOyLZZWQzTH-y-uztRRZiyeAxvZMUpvqQ2Y8Jot5HpeH1lGoSwNykdDuIdUxVW9Vv-wpLAW-S2Md7h2eflWgQpRHbVgRGiPNNT',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Koda',
                  style: textTheme.displayLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your quiet space for introspection.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 48),
                // Minimalist Progress Indicator
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.33,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Accent
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.self_improvement,
                  color: colorScheme.primary.withOpacity(0.4),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'INNER CALM',
                  style: textTheme.labelSmall?.copyWith(
                    letterSpacing: 2.0,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurredCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _BlurredCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
