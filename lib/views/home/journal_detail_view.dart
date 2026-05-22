// filepath: /Users/developer/Desktop/flutter/koda/lib/views/home/journal_detail_view.dart
import 'package:flutter/material.dart';
import '../shared/app_background.dart';
import 'widgets/journal_detail_widgets.dart';

class JournalDetailView extends StatelessWidget {
  final DateTime? selectedDate;

  const JournalDetailView({super.key, this.selectedDate});

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

  @override
  Widget build(BuildContext context) {
    // Title & date strings matching user-provided layout
    const String title = "Morning Reflection";
    final String dateString = selectedDate != null
        ? "${_getMonthName(selectedDate!.month)} ${selectedDate!.day}, ${selectedDate!.year}"
        : "March 22, 2025";
    const List<String> tags = ["Personal", "Calm", "Motivation"];
    
    // Featured hero image matching mock URL
    const String imageUrl = "https://lh3.googleusercontent.com/aida-public/AB6AXuDml_eMDg66VGqxtXe9_yY1DkgiX5pbC6d9b4ZzH9J3Ic16udC9c38S5MMxuXHh2QH4bliwif_WZ_JKa_X816rfETXCmEAgRfrgupoQ-PuPvcRpE5AboZFNjNi51lVGi-SKl9HSJhCuZZCeq-LRW00kMnYu_URXI0WF2F7IXuwAezHMcpreoOzY3jIemV7X7tgpuzb6_vCV_j72xertjGdeibLEqaWlJhtwgYoh3emK72hRdKiCOBNvGqbLaueFczZgZuZ93mQqwxbX";
    
    // Reflection body text paragraphs with inline voice and image tags
    const List<String> paragraphs = [
      "I woke up to the soft light filtering through my window, [voice:1] and for the first time in a while, I didn't rush to check my phone. Instead, I took a deep breath and stretched, feeling my body wake up slowly.",
      "The morning air was crisp and refreshing, [image:1] inviting a sense of deep stillness before the hustle of the day."
    ];
    
    // Key bullets representing the morning moments
    const List<String> bulletPoints = [
      "The warmth of my morning tea",
      "A quiet moment to myself before the day starts",
      "The kindness of a stranger who held the door open for me yesterday"
    ];

    // Inline voice memos data map for the view page
    final Map<int, Map<String, dynamic>> voiceMemos = {
      1: {
        'id': 1,
        'duration': '0:12',
        'seconds': 12,
        'isPlaying': false,
        'elapsed': 0,
      }
    };

    // Inline images data map for the view page
    final Map<int, Map<String, dynamic>> mockImages = {
      1: {
        'id': 1,
        'path': 'assets/images/evening.jpg',
        'label': 'Sunset Reflection',
      }
    };

    return Scaffold(
      body: AppBackground(
        backgroundImagePath: 'assets/images/journal_background.png',
        child: Stack(
          children: [
            // Scrollable Content
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    top: 16.0,
                    bottom: 120.0, // Space for the bottom floating bar
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      JournalDetailHeader(
                        title: title,
                        dateString: dateString,
                        tags: tags,
                      ),
                      const SizedBox(height: 24),
                      const JournalDetailHeroImage(imageUrl: imageUrl),
                      const SizedBox(height: 24),
                      const JournalDetailAudioPlayer(totalSeconds: 32),
                      const SizedBox(height: 28),
                      JournalDetailContentBody(
                        paragraphs: paragraphs,
                        bulletPoints: bulletPoints,
                        voiceMemos: voiceMemos,
                        images: mockImages,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom Action Bar Deck
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: JournalFloatingActionBar(
                onEditPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit action triggered'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onSharePressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share action triggered'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onDeletePressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Reflection?'),
                      content: const Text(
                          'Are you sure you want to delete this morning reflection entry? This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close dialog
                            Navigator.pop(context); // Navigate back
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
