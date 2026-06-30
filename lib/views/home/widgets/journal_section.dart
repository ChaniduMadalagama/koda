// filepath: /Users/developer/Desktop/flutter/koda/lib/views/home/widgets/journal_section.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';

class _JournalCardData {
  final String name;
  final String tag;
  final String title;
  final String subtitle;
  final String image;
  final IconData icon;
  final Color collapsedBgColor;
  final Color collapsedTextColor;

  const _JournalCardData({
    required this.name,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.icon,
    required this.collapsedBgColor,
    required this.collapsedTextColor,
  });
}

class JournalSection extends StatefulWidget {
  const JournalSection({super.key});

  @override
  State<JournalSection> createState() => _JournalSectionState();
}

class _JournalSectionState extends State<JournalSection> {
  int _selectedIndex = 0;

  final List<_JournalCardData> _cards = const [
    _JournalCardData(
      name: 'Morning',
      tag: 'Daily Morning',
      title: "Let's start your day",
      subtitle: 'Begin with mindful morning reflections.',
      image: 'assets/images/morning.jpg',
      icon: Icons.wb_sunny_rounded,
      collapsedBgColor: Color(0xFFFFD46A),
      collapsedTextColor: Color(0xFF6D4B00),
    ),
    _JournalCardData(
      name: 'Evening',
      tag: 'Daily Evening',
      title: 'Reflect on your day',
      subtitle: 'Process your thoughts and unwind this evening.',
      image: 'assets/images/evening.jpg',
      icon: Icons.wb_twilight_rounded,
      collapsedBgColor: Color(0xFFF9D8DB),
      collapsedTextColor: Color(0xFF755C5F),
    ),
    _JournalCardData(
      name: 'Night',
      tag: 'Daily Night',
      title: 'Rest and restore',
      subtitle: 'Prepare your mind for a deep, peaceful sleep.',
      image: 'assets/images/night.jpg',
      icon: Icons.nights_stay_rounded,
      collapsedBgColor: Color(0xFFC8C0E5),
      collapsedTextColor: Color(0xFF534D6C),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'My Journal',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'See all',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity == null) return;
            if (details.primaryVelocity! < -200) {
              // Swipe left: go to next card
              if (_selectedIndex < _cards.length - 1) {
                setState(() {
                  _selectedIndex++;
                });
              }
            } else if (details.primaryVelocity! > 200) {
              // Swipe right: go to previous card
              if (_selectedIndex > 0) {
                setState(() {
                  _selectedIndex--;
                });
              }
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double collapsedWidth = 56.0;
              const double spacing = 12.0;
              final double totalWidth = constraints.maxWidth;
              final double activeWidth =
                  totalWidth - (collapsedWidth * 2) - (spacing * 2);

              return SizedBox(
                height: 280,
                child: Row(
                  children: List.generate(_cards.length, (index) {
                    final isSelected = _selectedIndex == index;
                    final card = _cards[index];

                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == _cards.length - 1 ? 0 : spacing,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          if (!isSelected) {
                            setState(() {
                              _selectedIndex = index;
                            });
                          } else {
                            context.push(AppRouter.journal);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOutCubic,
                          width: isSelected ? activeWidth : collapsedWidth,
                          height: 280,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.transparent
                                : card.collapsedBgColor,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              child: isSelected
                                  ? _buildExpandedCard(context, card, index)
                                  : _buildCollapsedCard(context, card, index),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedCard(
    BuildContext context,
    _JournalCardData card,
    int index,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      key: ValueKey('expanded_$index'),
      fit: StackFit.expand,
      children: [
        Image.asset(card.image, fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.75),
              ],
            ),
          ),
        ),
        Positioned(
          top: 24,
          left: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              card.tag.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                card.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                card.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedCard(
    BuildContext context,
    _JournalCardData card,
    int index,
  ) {
    return Container(
      key: ValueKey('collapsed_$index'),
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(card.icon, color: card.collapsedTextColor, size: 24),
          const SizedBox(height: 16),
          RotatedBox(
            quarterTurns: 3,
            child: Text(
              card.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: card.collapsedTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
