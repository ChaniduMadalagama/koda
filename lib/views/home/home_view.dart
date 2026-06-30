// filepath: /Users/developer/Desktop/flutter/koda/lib/views/home/home_view.dart
import 'package:flutter/material.dart';
import 'widgets/horizontal_calendar.dart';
import 'widgets/journal_section.dart';
import 'widgets/quick_journal_section.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F1ED),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(24.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(textTheme),
                  const SizedBox(height: 32),
                  const HorizontalCalendar(),
                  const SizedBox(height: 40),
                  const JournalSection(),
                  const SizedBox(height: 40),
                  const QuickJournalSection(),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Hi, Jose Maria',
          style: textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        const CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBZH2ISvTAjf9pGyUvtgAoPjoSC5t0mHKIV_W8j8lEsHxmQzcE2nyw-uvRnsqU6UDojKLViLRXc_cX9P1_625zW06ibK5GLtPad9__G-7FKJK3GAwP2iUXL3oP9SU8Y0vQgMU9VnOK1NNQdX3aez7aIk1pDkTsWBlmW6ps2WCjXLRO6cOwd5612FEG_9fjvmqPq7_dO6gIGArMdm-CS1ZTuOe8KTl8JRjzfr9KsJ-_HmCYV3DqUtQn5Aj0Zf4WPBNKPP8ziLJB7s-GR',
          ),
        ),
      ],
    );
  }
}
