// filepath: /Users/developer/Desktop/flutter/koda/lib/views/home/widgets/quick_journal_section.dart
import 'package:flutter/material.dart';

class QuickJournalSection extends StatelessWidget {
  const QuickJournalSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Quick Journal',
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
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _QuickCard(
                title: 'Pause & reflect 🌱',
                subtitle: 'What are you grateful for today?',
                tag: 'Personal',
                bgColor: const Color(0xFFF9DED7),
                tagColor: const Color(0xFFEE8473),
              ),
              const SizedBox(width: 16),
              _QuickCard(
                title: 'Set Intentions 😶',
                subtitle: 'How do you want to feel?',
                tag: 'Family',
                bgColor: const Color(0xFFE2DFFD),
                tagColor: const Color(0xFF8B84D7),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String title, subtitle, tag;
  final Color bgColor, tagColor;

  const _QuickCard({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.bgColor,
    required this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: tagColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
