// filepath: /Users/developer/Desktop/flutter/koda/lib/views/home/widgets/journal_detail_widgets.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 1. Journal Detail Header Widget
class JournalDetailHeader extends StatelessWidget {
  final String title;
  final String dateString;
  final List<String> tags;

  const JournalDetailHeader({
    super.key,
    required this.title,
    required this.dateString,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Top row with Back button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF2ECE6), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ),
            const SizedBox(width: 48), // Spacer to balance the layout
          ],
        ),
        const SizedBox(height: 24),
        // Date
        Text(
          dateString.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFB57000), // Amber-brown theme
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 12),
        // Title
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1D1B1E),
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 18),
        // Tag Pills
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: tags.map((tag) => _buildTagChip(tag)).toList(),
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF2ECE6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: Color(0xFF514534),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 2. Journal Hero Image Card
class JournalDetailHeroImage extends StatelessWidget {
  final String imageUrl;

  const JournalDetailHeroImage({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback in case of network issues
            return Container(
              color: const Color(0xFFF0ECE6),
              child: const Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 3. Interactive Waveform Audio Player Widget
class JournalDetailAudioPlayer extends StatefulWidget {
  final int totalSeconds;

  const JournalDetailAudioPlayer({
    super.key,
    this.totalSeconds = 32,
  });

  @override
  State<JournalDetailAudioPlayer> createState() => _JournalDetailAudioPlayerState();
}

class _JournalDetailAudioPlayerState extends State<JournalDetailAudioPlayer> with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  int _elapsedSeconds = 0;
  Timer? _timer;
  late AnimationController _pulseController;

  // Wave heights mapping from design template
  final List<double> _baseWaveHeights = const [
    12.0, 18.0, 15.0, 24.0, 12.0, 18.0, 20.0, 12.0, 
    18.0, 24.0, 15.0, 18.0, 12.0, 15.0, 20.0, 12.0, 
    18.0, 24.0, 15.0, 12.0, 18.0, 9.0, 15.0, 6.0
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_isPlaying) {
        _isPlaying = false;
        _timer?.cancel();
        _pulseController.stop();
      } else {
        _isPlaying = true;
        _pulseController.repeat(reverse: true);
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_elapsedSeconds < widget.totalSeconds) {
          _elapsedSeconds++;
        } else {
          // Playback finished
          _elapsedSeconds = 0;
          _isPlaying = false;
          _timer?.cancel();
          _pulseController.stop();
        }
      });
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF2ECE6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Play/Pause Action Button
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF8B533),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF8B533).withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  key: ValueKey<bool>(_isPlaying),
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Interactive Waveform Audio Visualizer
          Expanded(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_baseWaveHeights.length, (index) {
                    // Check if this bar should be active based on elapsed time percentage
                    final double percentComplete = _elapsedSeconds / widget.totalSeconds;
                    final double barPercent = index / _baseWaveHeights.length;
                    final bool isActive = barPercent <= percentComplete;

                    // Dynamic wave pulsing simulation when playing
                    double pulseFactor = 1.0;
                    if (_isPlaying && isActive) {
                      final double phase = (index * 0.4) + (_pulseController.value * math.pi * 2);
                      pulseFactor = 0.75 + (math.sin(phase) * 0.25);
                    }

                    return Flexible(
                      child: Container(
                        height: _baseWaveHeights[index] * pulseFactor,
                        margin: const EdgeInsets.symmetric(horizontal: 1.0),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFFF8B533) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          // Track Duration Text
          Text(
            _formatDuration(_elapsedSeconds > 0 ? _elapsedSeconds : widget.totalSeconds),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF74777F),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// 4. Journal Content Text Body
class JournalDetailContentBody extends StatelessWidget {
  final List<String> paragraphs;
  final List<String> bulletPoints;
  final Map<int, Map<String, dynamic>> voiceMemos;
  final Map<int, Map<String, dynamic>> images;

  const JournalDetailContentBody({
    super.key,
    required this.paragraphs,
    required this.bulletPoints,
    this.voiceMemos = const {},
    this.images = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Paragraph 1
        if (paragraphs.isNotEmpty) ...[
          InlineVoiceText(
            text: paragraphs[0],
            voiceMemos: voiceMemos,
            images: images,
            style: const TextStyle(
              color: Color(0xFF4A4A4A),
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Bullet points
        if (bulletPoints.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: bulletPoints.map((bullet) => _buildBulletRow(bullet)).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Faded Paragraph (faded style from mockup)
        if (paragraphs.length > 1) ...[
          InlineVoiceText(
            text: paragraphs[1],
            voiceMemos: voiceMemos,
            images: images,
            style: TextStyle(
              color: const Color(0xFF4A4A4A).withOpacity(0.3),
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBulletRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8.0, right: 12.0),
            child: Icon(
              Icons.circle,
              size: 6,
              color: Color(0xFF2D2D2D),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF2D2D2D),
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 5. Journal Detail Bottom Floating Action Bar
class JournalFloatingActionBar extends StatelessWidget {
  final VoidCallback? onEditPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onDeletePressed;

  const JournalFloatingActionBar({
    super.key,
    this.onEditPressed,
    this.onSharePressed,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7E5700).withOpacity(0.08),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionItem(
              icon: Icons.edit_outlined,
              color: const Color(0xFF514534),
              onPressed: onEditPressed,
            ),
            _buildActionItem(
              icon: Icons.share_outlined,
              color: const Color(0xFF514534),
              onPressed: onSharePressed,
            ),
            _buildActionItem(
              icon: Icons.delete_outline_rounded,
              color: Colors.red[600]!,
              onPressed: onDeletePressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFF2ECE6), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
    );
  }
}

/// 6. A stateful widget that parses inline `[voice:id]` and `[image:id]` tokens in text
/// and renders them either as compact pins, or expanded inline cards.
class InlineVoiceText extends StatefulWidget {
  final String text;
  final Map<int, Map<String, dynamic>> voiceMemos;
  final Map<int, Map<String, dynamic>> images;
  final TextStyle? style;

  const InlineVoiceText({
    super.key,
    required this.text,
    required this.voiceMemos,
    this.images = const {},
    this.style,
  });

  @override
  State<InlineVoiceText> createState() => _InlineVoiceTextState();
}

class _InlineVoiceTextState extends State<InlineVoiceText> {
  final Set<int> _expandedVoiceMemos = {};
  final Set<int> _expandedImages = {};
  Timer? _playbackTimer;
  int? _playingVoiceId;

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _toggleExpand(int id) {
    setState(() {
      if (_expandedVoiceMemos.contains(id)) {
        _expandedVoiceMemos.remove(id);
      } else {
        _expandedVoiceMemos.add(id);
      }
    });
  }

  void _toggleImageExpand(int id) {
    setState(() {
      if (_expandedImages.contains(id)) {
        _expandedImages.remove(id);
      } else {
        _expandedImages.add(id);
      }
    });
  }

  void _togglePlay(int id) {
    final memo = widget.voiceMemos[id];
    if (memo == null) return;

    if (_playingVoiceId == id) {
      // Pause
      _playbackTimer?.cancel();
      setState(() {
        memo['isPlaying'] = false;
        _playingVoiceId = null;
      });
    } else {
      // Stop current playing
      if (_playingVoiceId != null) {
        _playbackTimer?.cancel();
        final prevMemo = widget.voiceMemos[_playingVoiceId!];
        if (prevMemo != null) {
          prevMemo['isPlaying'] = false;
          prevMemo['elapsed'] = 0;
        }
      }

      setState(() {
        _playingVoiceId = id;
        memo['isPlaying'] = true;
        memo['elapsed'] = 0;
      });

      final totalSeconds = memo['seconds'] as int? ?? 15;

      _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          final currentElapsed = (memo['elapsed'] as int? ?? 0) + 1;
          memo['elapsed'] = currentElapsed;
          if (currentElapsed >= totalSeconds) {
            _playbackTimer?.cancel();
            memo['isPlaying'] = false;
            _playingVoiceId = null;
            memo['elapsed'] = 0;
          }
        });
      });
    }
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = widget.style ??
        const TextStyle(
          color: Color(0xFF4A4A4A),
          fontSize: 15,
          height: 1.6,
          fontWeight: FontWeight.w500,
        );

    final List<InlineSpan> children = [];
    final pattern = RegExp(r'\[(voice|image):(\d+)\]');
    int lastIndex = 0;

    pattern.allMatches(widget.text).forEach((match) {
      if (match.start > lastIndex) {
        children.add(TextSpan(text: widget.text.substring(lastIndex, match.start)));
      }

      final type = match.group(1)!;
      final idStr = match.group(2)!;
      final id = int.tryParse(idStr) ?? 0;

      if (type == 'voice') {
        children.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _buildVoiceWidget(id),
        ));
      } else {
        children.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _buildImageWidget(id),
        ));
      }

      lastIndex = match.end;
    });

    if (lastIndex < widget.text.length) {
      children.add(TextSpan(text: widget.text.substring(lastIndex)));
    }

    return RichText(
      text: TextSpan(
        style: defaultStyle,
        children: children,
      ),
    );
  }

  Widget _buildVoiceWidget(int id) {
    final memo = widget.voiceMemos[id];
    if (memo == null) {
      return const SizedBox.shrink();
    }

    final isExpanded = _expandedVoiceMemos.contains(id);
    final isPlaying = memo['isPlaying'] == true;
    final duration = memo['duration'] as String? ?? '0:00';
    final elapsed = memo['elapsed'] as int? ?? 0;

    if (!isExpanded) {
      // Small circular mic pin in text flow
      return GestureDetector(
        onTap: () => _toggleExpand(id),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFFFB82B),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB82B).withOpacity(0.35),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.mic_none_rounded,
            size: 15,
            color: Color(0xFF6D4B00),
          ),
        ),
      );
    } else {
      // Expanded Inline Audio Waveform Player
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF9D8DB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF755C5F).withOpacity(0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _togglePlay(id),
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF755C5F),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Dynamic waveform visualizer bars
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(6, (barIndex) {
                final double height = isPlaying
                    ? 4.0 + 8.0 * math.sin((elapsed * 4) + barIndex)
                    : 6.0;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: 2.0,
                  height: height.clamp(3.0, 14.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF755C5F),
                    borderRadius: BorderRadius.circular(1),
                  ),
                );
              }),
            ),
            const SizedBox(width: 8),
            Text(
              isPlaying ? _formatDuration(elapsed) : duration,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF755C5F),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _toggleExpand(id),
              child: const Icon(
                Icons.unfold_less_rounded,
                size: 14,
                color: Color(0xFF755C5F),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildImageWidget(int id) {
    final imageItem = widget.images[id];
    if (imageItem == null) {
      return const SizedBox.shrink();
    }

    final isExpanded = _expandedImages.contains(id);
    final path = imageItem['path'] as String? ?? '';
    final label = imageItem['label'] as String? ?? 'Memory';

    if (!isExpanded) {
      // Small circular image pin in text flow
      return GestureDetector(
        onTap: () => _toggleImageExpand(id),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFFFB82B),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB82B).withOpacity(0.35),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.image_rounded,
            size: 15,
            color: Color(0xFF6D4B00),
          ),
        ),
      );
    } else {
      // Expanded Inline Image Card
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _toggleImageExpand(id),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF7E5700).withOpacity(0.08),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                path == 'selfie'
                    ? Container(
                        color: const Color(0xFFC8C0E5),
                        child: CustomPaint(
                          painter: SelfieAvatarPainter(),
                        ),
                      )
                    : Image.asset(
                        path,
                        fit: BoxFit.cover,
                      ),
                // Glass banner label at the bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    color: Colors.black.withOpacity(0.35),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.unfold_less_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

// --- Custom Painter for Stylized Front-Camera Avatar Portrait ---
class SelfieAvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Background gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE6DEFF), Color(0xFFC8C0E5)],
      ).createShader(Rect.fromLTWH(0, 0, width, height));
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    final paint = Paint()..style = PaintingStyle.fill;

    // Drawing a stylized retro Memphis head silhouette
    // Shoulder base
    paint.color = const Color(0xFF71585B);
    final shoulderPath = Path()
      ..moveTo(width * 0.2, height)
      ..quadraticBezierTo(width * 0.25, height * 0.7, width * 0.5, height * 0.7)
      ..quadraticBezierTo(width * 0.75, height * 0.7, width * 0.8, height)
      ..close();
    canvas.drawPath(shoulderPath, paint);

    // Neck
    paint.color = const Color(0xFFF9D8DB);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(width * 0.5, height * 0.62),
        width: width * 0.12,
        height: height * 0.15,
      ),
      paint,
    );

    // Head
    paint.color = const Color(0xFFFCDBDE);
    canvas.drawCircle(Offset(width * 0.5, height * 0.48), width * 0.2, paint);

    // Stylized Round Hair outline
    paint.color = const Color(0xFF605A7A);
    canvas.drawCircle(Offset(width * 0.5, height * 0.40), width * 0.22, paint);
    // Draw hair bangs
    final bangsPath = Path()
      ..moveTo(width * 0.3, height * 0.42)
      ..quadraticBezierTo(
        width * 0.5,
        height * 0.34,
        width * 0.7,
        height * 0.42,
      )
      ..quadraticBezierTo(
        width * 0.5,
        height * 0.46,
        width * 0.3,
        height * 0.42,
      )
      ..close();
    canvas.drawPath(bangsPath, paint);

    // Stylized Yellow round Sunglasses
    paint.color = const Color(0xFFFFB82B);
    canvas.drawCircle(Offset(width * 0.43, height * 0.48), width * 0.05, paint);
    canvas.drawCircle(Offset(width * 0.57, height * 0.48), width * 0.05, paint);
    // Sunglasses bridge
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    paint.color = const Color(0xFFFFB82B);
    canvas.drawLine(
      Offset(width * 0.47, height * 0.48),
      Offset(width * 0.53, height * 0.48),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
