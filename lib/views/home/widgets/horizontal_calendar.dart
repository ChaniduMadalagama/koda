// filepath: /Users/developer/Desktop/flutter/koda/lib/views/home/widgets/horizontal_calendar.dart
import 'package:flutter/material.dart';

class HorizontalCalendar extends StatefulWidget {
  const HorizontalCalendar({super.key});

  @override
  State<HorizontalCalendar> createState() => _HorizontalCalendarState();
}

class _HorizontalCalendarState extends State<HorizontalCalendar> {
  int _selectedIndex = 3; // Default: Thursday (today)

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _dates = [7, 8, 9, 10, 11, 12, 13];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month / navigation header
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'June 2025',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
              Row(
                children: [
                  _NavButton(
                    icon: Icons.chevron_left,
                    onTap: () {},
                  ),
                  const SizedBox(width: 4),
                  _NavButton(
                    icon: Icons.chevron_right,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        // Day columns — no card, sits directly on the background
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final isSelected = index == _selectedIndex;
            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              behavior: HitTestBehavior.opaque,
              child: _DayCell(
                dayLabel: _days[index],
                date: _dates[index],
                isSelected: isSelected,
                selectedBg: colorScheme.primaryContainer,
                selectedFg: colorScheme.onPrimaryContainer,
              ),
            );
          }),
        ),
      ],
    );
  }
}

// -------------------------------------------------------
// Private sub-widgets
// -------------------------------------------------------

class _DayCell extends StatelessWidget {
  final String dayLabel;
  final int date;
  final bool isSelected;
  final Color selectedBg;
  final Color selectedFg;

  const _DayCell({
    required this.dayLabel,
    required this.date,
    required this.isSelected,
    required this.selectedBg,
    required this.selectedFg,
  });

  @override
  Widget build(BuildContext context) {
    final unselectedLabel = Colors.grey.shade400;
    final unselectedDate = const Color(0xFF2D2D2D);

    return SizedBox(
      width: 40,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dayLabel,
            style: TextStyle(
              color: isSelected ? selectedBg : unselectedLabel,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: 40,
            // Explicit height avoids the overflow
            height: 52,
            decoration: BoxDecoration(
              color: isSelected ? selectedBg : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$date',
                  style: TextStyle(
                    color: isSelected ? selectedFg : unselectedDate,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedOpacity(
                  opacity: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: selectedFg,
                      shape: BoxShape.circle,
                    ),
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

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF2D2D2D)),
      ),
    );
  }
}
