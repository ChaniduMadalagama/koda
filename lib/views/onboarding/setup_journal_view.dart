// filepath: /Users/developer/Desktop/flutter/koda/lib/views/onboarding/setup_journal_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SetupJournalView extends StatefulWidget {
  const SetupJournalView({super.key});

  @override
  State<SetupJournalView> createState() => _SetupJournalViewState();
}

class _SetupJournalViewState extends State<SetupJournalView>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background Decor
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: colorScheme.primaryFixed.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    _buildStepIndicator(colorScheme, textTheme),
                    const SizedBox(height: 32),
                    _buildHeader(textTheme),
                    const SizedBox(height: 32),
                    _buildInputField(colorScheme, textTheme),
                    const SizedBox(height: 40),
                    _buildSuggestionsHeader(textTheme),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildSuggestionsGrid(colorScheme, textTheme),
                    ),
                    _buildFooterAction(colorScheme, textTheme),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(12),
            child: Image.network(
              'https://lh3.googleusercontent.com/aida/ADBb0ugi_14SoYvyvGMzEYXyKnd91AcfDYeHO3fLJb99DUxSd8vfhc7ouLXjsYZ7x3iYsJDXOTZthfuPFt9x3xAJnNEteHRdsAVBrMlcTOXKn3lD4_nJu2CoTlaiMIrIaEGa19xkLG20O3I5xka4RM9tiVhPXsUFAekEq26BbH7mKVxwhsqONxm_Cq7HGqX5I1kYAww50ED4ODuFTEY0pD4_fjGlvJYe6OcG_2o3VX0RzOeaIcptv_bFsk3kuRyI',
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Step 1 of 2',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Column(
      children: [
        Text(
          'Give your journal a name',
          style: textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'This is the soul of your daily practice. Choose something that feels like home.',
            style: textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _nameController,
        style: textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Type a name...',
          hintStyle: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant.withOpacity(0.4),
          ),
          suffixIcon: Icon(
            Icons.edit,
            color: colorScheme.primary.withOpacity(0.4),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsHeader(TextTheme textTheme) {
    return Text(
      'SUGGESTIONS',
      style: textTheme.labelLarge?.copyWith(
        letterSpacing: 1.5,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
      ),
    );
  }

  Widget _buildSuggestionsGrid(ColorScheme colorScheme, TextTheme textTheme) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SuggestionCard(
                  title: 'My Mindful Partner',
                  icon: Icons.favorite,
                  color: colorScheme.primaryContainer.withOpacity(0.2),
                  iconColor: colorScheme.onPrimaryContainer,
                  onTap: () => _nameController.text = 'My Mindful Partner',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SuggestionCard(
                  title: 'Dear Friend',
                  icon: Icons.auto_awesome,
                  color: colorScheme.tertiaryContainer.withOpacity(0.2),
                  iconColor: colorScheme.onTertiaryContainer,
                  onTap: () => _nameController.text = 'Dear Friend',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SuggestionCard(
            title: 'Daily Reflection Space',
            subtitle: 'A quiet corner for your thoughts.',
            icon: Icons.cloud,
            color: colorScheme.secondaryContainer.withOpacity(0.2),
            iconColor: colorScheme.onSecondaryContainer,
            isWide: true,
            onTap: () => _nameController.text = 'Daily Reflection Space',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SuggestionCard(
                  title: 'Ink & Soul',
                  icon: Icons.edit_note,
                  color: colorScheme.surfaceContainerHigh,
                  iconColor: colorScheme.onSurfaceVariant,
                  onTap: () => _nameController.text = 'Ink & Soul',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SuggestionCard(
                  title: 'Grounded Life',
                  icon: Icons.spa,
                  color: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF2E7D32),
                  onTap: () => _nameController.text = 'Grounded Life',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFooterAction(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 16),
      child: ElevatedButton(
        onPressed: () => context.go('/home'),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          elevation: 4,
          shadowColor: colorScheme.primaryContainer.withOpacity(0.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Next'),
            SizedBox(width: 12),
            Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final bool isWide;
  final VoidCallback onTap;

  const _SuggestionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
    this.subtitle,
    this.isWide = false,
  });

  @override
  State<_SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<_SuggestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(24),
          ),
          child: widget.isWide ? _buildWideContent() : _buildSquareContent(),
        ),
      ),
    );
  }

  Widget _buildSquareContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: widget.iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(widget.icon, color: widget.iconColor),
        ),
        const SizedBox(height: 16),
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: widget.iconColor,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildWideContent() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: widget.iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(widget.icon, color: widget.iconColor, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: widget.iconColor),
              ),
              if (widget.subtitle != null)
                Text(
                  widget.subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: widget.iconColor.withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
