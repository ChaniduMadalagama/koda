// filepath: /Users/developer/Desktop/flutter/koda/lib/views/home/widgets/horizontal_calendar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';

class HorizontalCalendar extends StatefulWidget {
  const HorizontalCalendar({super.key});

  @override
  State<HorizontalCalendar> createState() => _HorizontalCalendarState();
}

class _HorizontalCalendarState extends State<HorizontalCalendar> {
  DateTime _selectedDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to the selected date once layout is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDate(_selectedDate, animate: false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<DateTime> get _daysInMonth {
    final year = _selectedDate.year;
    final month = _selectedDate.month;
    final totalDays = DateTime(year, month + 1, 0).day;
    return List.generate(totalDays, (index) => DateTime(year, month, index + 1));
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'January';
      case 2: return 'February';
      case 3: return 'March';
      case 4: return 'April';
      case 5: return 'May';
      case 6: return 'June';
      case 7: return 'July';
      case 8: return 'August';
      case 9: return 'September';
      case 10: return 'October';
      case 11: return 'November';
      case 12: return 'December';
      default: return '';
    }
  }

  void _scrollToDate(DateTime date, {bool animate = true}) {
    if (!_scrollController.hasClients) return;

    final index = date.day - 1;
    const double itemWidth = 56.0; // 46 capsule width + 10 margin (5 on each side)
    final targetOffset = index * itemWidth;

    final clampedOffset = targetOffset.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    if (animate) {
      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(clampedOffset);
    }
  }

  void _onMonthSelected(int monthIndex) {
    setState(() {
      final currentYear = _selectedDate.year;
      final targetMonth = monthIndex + 1;
      
      // Safe clamp for day of month (e.g. Feb has 28 days)
      final daysInTargetMonth = DateTime(currentYear, targetMonth + 1, 0).day;
      final targetDay = _selectedDate.day.clamp(1, daysInTargetMonth);
      
      _selectedDate = DateTime(currentYear, targetMonth, targetDay);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDate(_selectedDate, animate: true);
    });
  }

  void _onDayTapped(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _scrollToDate(date, animate: true);

    // Open detail view for past days or today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tappedDate = DateTime(date.year, date.month, date.day);
    if (!tappedDate.isAfter(today)) {
      context.push(AppRouter.journalDetail, extra: date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final days = _daysInMonth;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFF7E5700).withOpacity(0.06),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7E5700).withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: const Color(0xFF7E5700).withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: CustomPaint(
          painter: CalendarVectorPainter(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Row: Title & Month Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Start date and time',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2D2D2D),
                            fontSize: 19,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildMonthDropdown(context),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Week View Row: Horizontally Scrollable List of days in the month
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.06, 0.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: LayoutBuilder(
                    key: ValueKey('${_selectedDate.year}_${_selectedDate.month}'),
                    builder: (context, constraints) {
                      final viewportWidth = constraints.maxWidth;
                      const double itemWidth = 56.0;
                      final sidePadding = (viewportWidth / 2) - (itemWidth / 2);

                      return SizedBox(
                        height: 84,
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: sidePadding),
                          itemCount: days.length,
                          itemBuilder: (context, index) {
                            final dayDate = days[index];
                            final isSelected = DateUtils.isSameDay(_selectedDate, dayDate);
                            
                            return TweenAnimationBuilder<double>(
                              key: ValueKey('stagger_${dayDate.day}_${_selectedDate.month}'),
                              duration: Duration(milliseconds: 350 + (index * 15).clamp(0, 250)),
                              curve: Curves.easeOutCubic,
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, (1 - value) * 16),
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildDayItem(context, dayDate, isSelected),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthDropdown(BuildContext context) {
    return PopupMenuButton<int>(
      initialValue: _selectedDate.month - 1,
      onSelected: _onMonthSelected,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      itemBuilder: (context) => List.generate(12, (index) {
        return PopupMenuItem<int>(
          value: index,
          child: Text(
            _getMonthName(index + 1),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F7F3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF7E5700).withOpacity(0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getMonthName(_selectedDate.month),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayItem(BuildContext context, DateTime date, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    final dayName = _getDayName(date.weekday);
    final dateNumber = date.day.toString();
    final isToday = DateUtils.isSameDay(DateTime.now(), date);

    // Dynamic sunset peach to bronze/gold gradient for the active state
    final activeBgGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFE0A96D),
        colorScheme.primary,
      ],
    );

    final activeTextColor = Colors.white;
    final inactiveDayColor = Colors.grey[500];
    final inactiveDateColor = const Color(0xFF2D2D2D);

    Widget column = SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayName.toUpperCase(),
            style: TextStyle(
              color: isSelected ? activeTextColor : inactiveDayColor,
              fontSize: 9,
              letterSpacing: 1.5,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dateNumber,
            style: TextStyle(
              color: isSelected ? activeTextColor : inactiveDateColor,
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
            ),
          ),
          if (isToday) ...[
            const SizedBox(height: 4),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : const Color(0xFF7E5700),
              ),
            ),
          ],
        ],
      ),
    );

    // Tactile shape-morphing container: squares to capsules
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      tween: Tween<double>(begin: isSelected ? 0.92 : 1.0, end: isSelected ? 1.04 : 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () => _onDayTapped(date),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          alignment: Alignment.center,
          width: 46,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: 46,
            height: 76,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected ? activeBgGradient : null,
              color: isSelected
                  ? null
                  : (isToday ? const Color(0xFFF9F7F3) : const Color(0xFFF0ECE6).withOpacity(0.4)),
              borderRadius: BorderRadius.circular(isSelected ? 22 : 16), // Dynamic shape morphing!
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : (isToday ? const Color(0xFFE0A96D).withOpacity(0.8) : const Color(0xFFE5DFD5)),
                width: isToday ? 1.5 : 1.0,
              ),
              boxShadow: null, // Removed active capsule shadows to keep the sunset pill flat and clean!
            ),
            child: column,
          ),
        ),
      ),
    );
  }
}

class CalendarVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // 1. Top-Right Soft Peach Sphere
    paint.color = const Color(0xFFE0A96D).withOpacity(0.06);
    canvas.drawCircle(Offset(size.width - 20, 20), 80, paint);

    // 2. Bottom-Left Soft Sage/Lavender Blob
    paint.color = const Color(0xFFE29578).withOpacity(0.05);
    canvas.drawCircle(const Offset(40, 110), 60, paint);

    // 3. Top-Right Memphis Line Curve
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF7E5700).withOpacity(0.06)
      ..strokeCap = StrokeCap.round;
      
    final path1 = Path();
    path1.moveTo(size.width - 140, 10);
    path1.quadraticBezierTo(
      size.width - 80, 60,
      size.width - 20, 25,
    );
    canvas.drawPath(path1, strokePaint);

    // 4. Bottom-Left Grid Dots
    final dotPaint = Paint()
      ..color = const Color(0xFF7E5700).withOpacity(0.07)
      ..style = PaintingStyle.fill;
    
    const double dotSpacing = 8.0;
    const Offset startOffset = Offset(20, 130);
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        canvas.drawCircle(
          Offset(startOffset.dx + i * dotSpacing, startOffset.dy + j * dotSpacing),
          1.5,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
