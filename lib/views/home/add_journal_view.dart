// filepath: /Users/developer/Desktop/flutter/koda/lib/views/home/add_journal_view.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/app_background.dart';

/// A custom TextEditingController that parses simple markdown syntax and inline voice memos:
/// - **bold** for bold text
/// - *italic* for italic text
/// - [voice:id] for interactive inline voice player widget
class RichTextEditingController extends TextEditingController {
  final Map<int, Map<String, dynamic>> voiceMemos;
  final Set<int> expandedVoiceMemos;
  final Function(int) onToggleExpand;
  final Function(int) onPlayToggle;

  final Map<int, Map<String, dynamic>> imageAttachments;
  final Set<int> expandedImages;
  final Function(int) onToggleImageExpand;
  final Function(int) onDeleteImage;

  RichTextEditingController({
    required this.voiceMemos,
    required this.expandedVoiceMemos,
    required this.onToggleExpand,
    required this.onPlayToggle,
    required this.imageAttachments,
    required this.expandedImages,
    required this.onToggleImageExpand,
    required this.onDeleteImage,
  });

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> children = [];
    // Matches Bold, Italic, Voice PUA range, and Image PUA range
    final pattern = RegExp(
      r'(\*\*([^*]+)\*\*)|(\*([^*]+)\*)|([\uE001-\uEFFF])|([\uF001-\uFFFF])',
    );
    int lastIndex = 0;

    pattern.allMatches(text).forEach((match) {
      // Normal text segment
      if (match.start > lastIndex) {
        children.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      final fullMatch = match.group(0)!;
      if (fullMatch.startsWith('**') && fullMatch.endsWith('**')) {
        // Bold formatting
        final innerText = match.group(2)!;
        children.add(
          TextSpan(
            text: '**',
            style: const TextStyle(
              color: Colors.black26,
              fontWeight: FontWeight.normal,
            ),
          ),
        );
        children.add(
          TextSpan(
            text: innerText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
        children.add(
          TextSpan(
            text: '**',
            style: const TextStyle(
              color: Colors.black26,
              fontWeight: FontWeight.normal,
            ),
          ),
        );
      } else if (fullMatch.startsWith('*') && fullMatch.endsWith('*')) {
        // Italic formatting
        final innerText = match.group(4)!;
        children.add(
          TextSpan(
            text: '*',
            style: const TextStyle(
              color: Colors.black26,
              fontStyle: FontStyle.normal,
            ),
          ),
        );
        children.add(
          TextSpan(
            text: innerText,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
        children.add(
          TextSpan(
            text: '*',
            style: const TextStyle(
              color: Colors.black26,
              fontStyle: FontStyle.normal,
            ),
          ),
        );
      } else {
        // PUA characters representing inline media
        final charCode = fullMatch.codeUnitAt(0);
        if (charCode >= 0xE001 && charCode <= 0xEFFF) {
          final id = charCode - 0xE000;
          children.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.bottom,
              child: _buildVoiceWidget(id),
            ),
          );
        } else if (charCode >= 0xF001 && charCode <= 0xFFFF) {
          final id = charCode - 0xF000;
          children.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.bottom,
              child: _buildImageWidget(id),
            ),
          );
        }
      }
      lastIndex = match.end;
    });

    if (lastIndex < text.length) {
      children.add(TextSpan(text: text.substring(lastIndex)));
    }

    return TextSpan(style: style, children: children);
  }

  String getSerializedText() {
    String out = text;
    out = out.replaceAllMapped(RegExp(r'[\uE001-\uEFFF]'), (m) {
      final charCode = m.group(0)!.codeUnitAt(0);
      final id = charCode - 0xE000;
      return '[voice:$id]';
    });
    out = out.replaceAllMapped(RegExp(r'[\uF001-\uFFFF]'), (m) {
      final charCode = m.group(0)!.codeUnitAt(0);
      final id = charCode - 0xF000;
      return '[image:$id]';
    });
    return out;
  }

  static String deserializeText(String input) {
    String out = input;
    out = out.replaceAllMapped(RegExp(r'\[voice:(\d+)\]'), (m) {
      final id = int.parse(m.group(1)!);
      return String.fromCharCode(0xE000 + id);
    });
    out = out.replaceAllMapped(RegExp(r'\[image:(\d+)\]'), (m) {
      final id = int.parse(m.group(1)!);
      return String.fromCharCode(0xF000 + id);
    });
    return out;
  }

  Widget _buildVoiceWidget(int id) {
    final memo = voiceMemos[id];
    if (memo == null) {
      return const SizedBox.shrink();
    }

    final isExpanded = expandedVoiceMemos.contains(id);
    final isPlaying = memo['isPlaying'] == true;
    final duration = memo['duration'] as String? ?? '0:00';
    final elapsed = memo['elapsed'] as int? ?? 0;

    if (!isExpanded) {
      // Small circular mic pin in text flow
      return GestureDetector(
        onTap: () => onToggleExpand(id),
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
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onToggleExpand(id),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF9D8DB), // soft pink container
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
                onTap: () => onPlayToggle(id),
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
              const Icon(
                Icons.unfold_less_rounded,
                size: 14,
                color: Color(0xFF755C5F),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildImageWidget(int id) {
    final imageItem = imageAttachments[id];
    if (imageItem == null) {
      return const SizedBox.shrink();
    }

    final isExpanded = expandedImages.contains(id);
    final path = imageItem['path'] as String? ?? '';
    final label = imageItem['label'] as String? ?? 'Memory';

    if (!isExpanded) {
      // Small circular image pin in text flow
      return GestureDetector(
        onTap: () => onToggleImageExpand(id),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFFFB82B), // same yellow color
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
            color: Color(0xFF6D4B00), // same dark gold
          ),
        ),
      );
    } else {
      // Expanded Inline Image Card
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onToggleImageExpand(id),
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
                        color: const Color(0xFFC8C0E5), // Front Selfie canvas
                        child: CustomPaint(painter: SelfieAvatarPainter()),
                      )
                    : Image.asset(path, fit: BoxFit.cover),
                // Glass banner label at the bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 8,
                    ),
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
                // Delete Button at top right
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => onDeleteImage(id),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
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

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class AddJournalView extends StatefulWidget {
  const AddJournalView({super.key});

  @override
  State<AddJournalView> createState() => _AddJournalViewState();
}

class _AddJournalViewState extends State<AddJournalView>
    with TickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final Map<int, Map<String, dynamic>> _voiceMemos = {};
  final Set<int> _expandedVoiceMemos = {};
  late final RichTextEditingController _contentController;
  final FocusNode _editorFocusNode = FocusNode();

  // Images state
  final Map<int, Map<String, dynamic>> _images = {};
  final Set<int> _expandedImages = {};
  String _lastText = '';

  // Voice recording state
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  List<double> _recordingWaves = List.filled(10, 8.0);

  // Active playing voice memo index
  int? _playingVoiceIndex;
  Timer? _playbackTimer;

  // Camera & Gallery states
  bool _isCameraOpen = false;
  bool _isSelfieMode =
      false; // false for Back (scenic), true for Front (selfie)
  bool _isCameraShutterFlash = false;
  bool _isGalleryOpen = false;

  @override
  void initState() {
    super.initState();
    _contentController = RichTextEditingController(
      voiceMemos: _voiceMemos,
      expandedVoiceMemos: _expandedVoiceMemos,
      onToggleExpand: (id) {
        setState(() {
          if (_expandedVoiceMemos.contains(id)) {
            _expandedVoiceMemos.remove(id);
          } else {
            _expandedVoiceMemos.add(id);
          }
        });
        _contentController.notifyListeners();
      },
      onPlayToggle: (id) {
        _toggleVoicePlaybackInline(id);
      },
      imageAttachments: _images,
      expandedImages: _expandedImages,
      onToggleImageExpand: (id) {
        setState(() {
          if (_expandedImages.contains(id)) {
            _expandedImages.remove(id);
          } else {
            _expandedImages.add(id);
          }
        });
        _contentController.notifyListeners();
      },
      onDeleteImage: (id) {
        _deleteImageInline(id);
      },
    );
    _lastText = _contentController.text;
    _contentController.addListener(_onEditorTextChanged);
  }

  void _onEditorTextChanged() {
    final currentText = _contentController.text;
    if (currentText != _lastText) {
      _lastText = currentText;
      if (_expandedImages.isNotEmpty || _expandedVoiceMemos.isNotEmpty) {
        setState(() {
          _expandedImages.clear();
          _expandedVoiceMemos.clear();
        });
      }
    }
  }

  void _deleteImageInline(int id) {
    setState(() {
      _images.remove(id);
      _expandedImages.remove(id);
      final currentText = _contentController.text;
      final charTag = String.fromCharCode(0xF000 + id);
      if (currentText.contains(charTag)) {
        final index = currentText.indexOf(charTag);
        _contentController.value = TextEditingValue(
          text: currentText.replaceFirst(charTag, ''),
          selection: TextSelection.collapsed(
            offset: index.clamp(0, currentText.length - 1),
          ),
        );
      }
    });
  }

  void _insertImageInline(String path, String label) {
    setState(() {
      final newId = _images.length + 1;
      _images[newId] = {'id': newId, 'path': path, 'label': label};

      final text = _contentController.text;
      final selection = _contentController.selection;
      final charTag = String.fromCharCode(0xF000 + newId);

      final newText = selection.isValid
          ? text.replaceRange(selection.start, selection.end, charTag)
          : text + charTag;

      final newSelection = selection.isValid
          ? TextSelection.collapsed(offset: selection.start + 1)
          : TextSelection.collapsed(offset: newText.length);

      _contentController.value = TextEditingValue(
        text: newText,
        selection: newSelection,
      );
    });
  }

  @override
  void dispose() {
    _contentController.removeListener(_onEditorTextChanged);
    _titleController.dispose();
    _contentController.dispose();
    _editorFocusNode.dispose();
    _recordingTimer?.cancel();
    _playbackTimer?.cancel();
    super.dispose();
  }

  // --- Date Formatter ---
  String _getFormattedDateTime() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final month = months[now.month - 1];
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final hour = now.hour > 12
        ? now.hour - 12
        : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    return '$month ${now.day}, ${now.year} • ${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  // --- Markdown Formatting Helpers ---
  void _toggleFormat(String delimiter) {
    final text = _contentController.text;
    final selection = _contentController.selection;

    if (!selection.isValid || selection.isCollapsed) {
      // If no active selection, insert the tags and place cursor in the middle
      final offset = selection.baseOffset >= 0
          ? selection.baseOffset
          : text.length;
      final newText =
          text.substring(0, offset) +
          delimiter +
          delimiter +
          text.substring(offset);
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: offset + delimiter.length),
      );
      _editorFocusNode.requestFocus();
      return;
    }

    final start = selection.start;
    final end = selection.end;
    final selectedText = text.substring(start, end);

    // Case 1: Check if the text surrounding the selection has the delimiters
    final surroundingStart = start - delimiter.length;
    final surroundingEnd = end + delimiter.length;
    final hasSurrounding =
        surroundingStart >= 0 &&
        surroundingEnd <= text.length &&
        text.substring(surroundingStart, start) == delimiter &&
        text.substring(end, surroundingEnd) == delimiter;

    // Case 2: Check if the selected text itself is wrapped in the delimiters
    final isWrapped =
        selectedText.startsWith(delimiter) &&
        selectedText.endsWith(delimiter) &&
        selectedText.length >= (delimiter.length * 2);

    if (hasSurrounding) {
      // Unwrap surrounding delimiters
      final before = text.substring(0, surroundingStart);
      final after = text.substring(surroundingEnd);
      final unwrapped = before + selectedText + after;
      _contentController.value = TextEditingValue(
        text: unwrapped,
        selection: TextSelection(
          baseOffset: surroundingStart,
          extentOffset: surroundingStart + selectedText.length,
        ),
      );
    } else if (isWrapped) {
      // Unwrap selected text delimiters
      final unwrappedText = selectedText.substring(
        delimiter.length,
        selectedText.length - delimiter.length,
      );
      final before = text.substring(0, start);
      final after = text.substring(end);
      final unwrapped = before + unwrappedText + after;
      _contentController.value = TextEditingValue(
        text: unwrapped,
        selection: TextSelection(
          baseOffset: start,
          extentOffset: start + unwrappedText.length,
        ),
      );
    } else {
      // Wrap selection in delimiters
      final before = text.substring(0, start);
      final after = text.substring(end);
      final wrapped = before + delimiter + selectedText + delimiter + after;
      _contentController.value = TextEditingValue(
        text: wrapped,
        selection: TextSelection(
          baseOffset: start + delimiter.length,
          extentOffset: start + delimiter.length + selectedText.length,
        ),
      );
    }
    _editorFocusNode.requestFocus();
  }

  void _insertBullet() {
    final text = _contentController.text;
    final selection = _contentController.selection;
    final offset = selection.baseOffset >= 0
        ? selection.baseOffset
        : text.length;

    // Insert bullet point
    final newText = text.substring(0, offset) + '\n• ' + text.substring(offset);
    _contentController.text = newText;
    _contentController.selection = TextSelection.collapsed(offset: offset + 3);
    _editorFocusNode.requestFocus();
  }

  // --- Voice Recorder Mock Logic ---
  void _toggleRecording() {
    if (_isRecording) {
      // Stop recording
      _recordingTimer?.cancel();
      setState(() {
        _isRecording = false;
        final durationStr = _formatDuration(_recordingSeconds);

        final newId = _voiceMemos.length + 1;
        _voiceMemos[newId] = {
          'id': newId,
          'duration': durationStr,
          'seconds': _recordingSeconds,
          'isPlaying': false,
          'elapsed': 0,
        };

        // Insert the voice memo tag as PUA character
        final text = _contentController.text;
        final selection = _contentController.selection;
        final offset = selection.baseOffset >= 0
            ? selection.baseOffset
            : text.length;
        final charTag = String.fromCharCode(0xE000 + newId);
        final newText =
            text.substring(0, offset) + charTag + text.substring(offset);

        _contentController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: offset + 1),
        );
        _recordingSeconds = 0;
      });

      // Keep keyboard focus on the editor
      _editorFocusNode.requestFocus();
    } else {
      // Start recording
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingSeconds++;
          // Randomize heights for simulated visualizer bars
          final rand = math.Random();
          _recordingWaves = List.generate(
            10,
            (index) => 6.0 + rand.nextDouble() * 20.0,
          );
        });
      });
    }
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // --- Voice Player Mock Logic (Inline) ---
  void _toggleVoicePlaybackInline(int id) {
    final memo = _voiceMemos[id];
    if (memo == null) return;

    if (_playingVoiceIndex == id) {
      // Pause
      _playbackTimer?.cancel();
      setState(() {
        memo['isPlaying'] = false;
        _playingVoiceIndex = null;
      });
      _contentController.notifyListeners();
    } else {
      // If another is playing, stop it first
      if (_playingVoiceIndex != null) {
        _playbackTimer?.cancel();
        final prevMemo = _voiceMemos[_playingVoiceIndex!];
        if (prevMemo != null) {
          prevMemo['isPlaying'] = false;
          prevMemo['elapsed'] = 0;
        }
      }

      setState(() {
        _playingVoiceIndex = id;
        memo['isPlaying'] = true;
        memo['elapsed'] = 0;
      });
      _contentController.notifyListeners();

      int totalSeconds = memo['seconds'] as int? ?? 15;
      if (totalSeconds <= 0) {
        totalSeconds = 5; // Minimum mock duration
      }

      _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          final currentElapsed = (memo['elapsed'] as int? ?? 0) + 1;
          memo['elapsed'] = currentElapsed;
          if (currentElapsed >= totalSeconds) {
            _playbackTimer?.cancel();
            memo['isPlaying'] = false;
            _playingVoiceIndex = null;
            memo['elapsed'] = 0;
          }
        });
        _contentController.notifyListeners();
      });
    }
  }

  // --- Camera Action Mock ---
  void _openCamera() {
    setState(() {
      _isCameraOpen = true;
      _isSelfieMode = false;
    });
  }

  void _triggerCameraShutter() {
    setState(() {
      _isCameraShutterFlash = true;
    });

    Timer(const Duration(milliseconds: 150), () {
      setState(() {
        _isCameraShutterFlash = false;
        _isCameraOpen = false;

        final path = _isSelfieMode ? 'selfie' : 'assets/images/evening.jpg';
        final label = _isSelfieMode ? 'Selfie' : 'Sunset Reflection';
        _insertImageInline(path, label);
      });
    });
  }

  // --- Gallery Action Mock ---
  void _openGallery() {
    setState(() {
      _isGalleryOpen = true;
    });
  }

  void _selectGalleryImage(String path, String label) {
    _insertImageInline(path, label);
    setState(() {
      _isGalleryOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        // 1. App Background configuration
        Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7E5700).withOpacity(0.06),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Color(0xFF7E5700),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'New Entry',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: const Color(0xFF7E5700),
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Mock Save reflection
                    final serialized = _contentController.getSerializedText();
                    debugPrint('Serialized Journal Content: $serialized');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Journal entry saved successfully!'),
                        backgroundColor: Color(0xFF7E5700),
                      ),
                    );
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFFFFB82B,
                    ), // Primary Container amber
                    foregroundColor: const Color(
                      0xFF6D4B00,
                    ), // On primary container
                    elevation: 0,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
            ],
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: AppBackground(
            backgroundImagePath: 'assets/images/journal_background.png',
            child: Stack(
              children: [
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      top: 12.0,
                      bottom: 120.0, // Space for bottom formatting bar
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Entry Header Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFF837561).withOpacity(0.12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _titleController,
                                style: textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1D1B1E),
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Title your reflection...',
                                  hintStyle: TextStyle(color: Colors.black26),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: const Color(
                                      0xFF7E5700,
                                    ).withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _getFormattedDateTime(),
                                    style: TextStyle(
                                      color: const Color(
                                        0xFF7E5700,
                                      ).withOpacity(0.7),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Rich Text Editor Area
                        Container(
                          constraints: const BoxConstraints(minHeight: 280),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _contentController,
                            focusNode: _editorFocusNode,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            style: textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              color: const Color(0xFF1D1B1E),
                              height: 1.6,
                            ),
                            decoration: const InputDecoration(
                              hintText:
                                  'I woke up feeling a strange sense of quiet today...',
                              hintStyle: TextStyle(color: Colors.black26),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Active Recording Visualizer Banner
                        if (_isRecording)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDE8E9), // Active red tint
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(
                                  0xFFBA1A1A,
                                ).withOpacity(0.15),
                              ),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: _toggleRecording,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFBA1A1A),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.stop,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Recording Voice Memo...',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFFBA1A1A),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // Simulated recording waveform
                                      SizedBox(
                                        height: 16,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: List.generate(
                                            _recordingWaves.length,
                                            (i) {
                                              return Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 1.5,
                                                    ),
                                                width: 3,
                                                height: _recordingWaves[i]
                                                    .clamp(4.0, 16.0),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFBA1A1A,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _formatDuration(_recordingSeconds),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFBA1A1A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // 2. Formatting Contextual Toolbar (Sticky Bottom)
                Positioned(
                  bottom: 24,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7E5700).withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.format_bold),
                              color: const Color(0xFF514534),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              onPressed: () => _toggleFormat('**'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.format_italic),
                              color: const Color(0xFF514534),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              onPressed: () => _toggleFormat('*'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.format_list_bulleted),
                              color: const Color(0xFF514534),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              onPressed: _insertBullet,
                            ),
                          ],
                        ),
                        Container(
                          width: 1.2,
                          height: 20,
                          color: const Color(0xFFD5C4AD),
                        ),
                        Row(
                          children: [
                            // Voice record toggle
                            GestureDetector(
                              onTap: _toggleRecording,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _isRecording
                                      ? const Color(0xFFFDE8E9)
                                      : const Color(
                                          0xFF7E5700,
                                        ).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _isRecording
                                          ? Icons.stop_circle_outlined
                                          : Icons.mic,
                                      size: 16,
                                      color: _isRecording
                                          ? const Color(0xFFBA1A1A)
                                          : const Color(0xFF7E5700),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _isRecording ? 'Recording' : 'Voice',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _isRecording
                                            ? const Color(0xFFBA1A1A)
                                            : const Color(0xFF7E5700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Image Sheet Toggle
                            GestureDetector(
                              onTap: () {
                                _isGalleryOpen ? null : _openGallery();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF605A7A,
                                  ).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 16,
                                      color: Color(0xFF605A7A),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Image',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF605A7A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Simulated Camera Viewfinder Modal
        if (_isCameraOpen)
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: SafeArea(
                child: Column(
                  children: [
                    // Top Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              setState(() {
                                _isCameraOpen = false;
                              });
                            },
                          ),
                          Text(
                            _isSelfieMode ? 'Selfie Camera' : 'Rear Camera',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.flip_camera_ios_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              setState(() {
                                _isSelfieMode = !_isSelfieMode;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    // Viewfinder area
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Viewfinder Backdrop
                              _isSelfieMode
                                  ? Container(
                                      color: const Color(
                                        0xFFC8C0E5,
                                      ), // Purple background
                                      child: CustomPaint(
                                        painter: SelfieAvatarPainter(),
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/images/evening.jpg',
                                      fit: BoxFit.cover,
                                    ),
                              // Grid Alignment Guides
                              CustomPaint(painter: CameraGridPainter()),
                              // Shutter flash effect
                              if (_isCameraShutterFlash)
                                Positioned.fill(
                                  child: Container(color: Colors.white),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Capture Control Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _triggerCameraShutter,
                            child: Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 5,
                                ),
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // 4. Custom Gallery Modal Bottom Sheet
        if (_isGalleryOpen)
          Positioned.fill(
            child: Stack(
              children: [
                // Dim screen backdrop
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isGalleryOpen = false;
                      });
                    },
                    child: Container(color: Colors.black.withOpacity(0.4)),
                  ),
                ),
                // Sheet Body
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Material(
                    color: const Color(0xFFFEF8FC),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                width: 48,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF837561,
                                  ).withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Add a Memory',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1D1B1E),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Picker actions: Gallery vs Camera Viewfinder
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      // Open Simulated Photo Grid
                                      setState(() {
                                        _isGalleryOpen = false;
                                        _openGalleryGrid();
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 24,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECE6EA),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Column(
                                        children: [
                                          Icon(
                                            Icons.photo_library,
                                            size: 36,
                                            color: Color(0xFF7E5700),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Gallery',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isGalleryOpen = false;
                                        _openCamera();
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 24,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECE6EA),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Column(
                                        children: [
                                          Icon(
                                            Icons.photo_camera,
                                            size: 36,
                                            color: Color(0xFF71585B),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Camera',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isGalleryOpen = false;
                                });
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Color(0xFF7E5700),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // --- Simulated Gallery Grid Sheet ---
  void _openGalleryGrid() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFEF8FC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        final images = [
          {'path': 'assets/images/morning.jpg', 'label': 'Morning Coffee'},
          {'path': 'assets/images/evening.jpg', 'label': 'Sunset Glow'},
          {'path': 'assets/images/night.jpg', 'label': 'Cozy Fireplace'},
          {'path': 'assets/images/background.png', 'label': 'Memphis Art'},
        ];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Select from Gallery',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7E5700),
                ),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final img = images[index];
                  return GestureDetector(
                    onTap: () {
                      _selectGalleryImage(img['path']!, img['label']!);
                      Navigator.pop(context);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(img['path']!, fit: BoxFit.cover),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.black45,
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              child: Text(
                                img['label']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

// --- Custom Painter for Camera Alignment Grid ---
class CameraGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Horizontal Lines
    canvas.drawLine(
      Offset(0, size.height * 0.33),
      Offset(size.width, size.height * 0.33),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.66),
      Offset(size.width, size.height * 0.66),
      paint,
    );

    // Vertical Lines
    canvas.drawLine(
      Offset(size.width * 0.33, 0),
      Offset(size.width * 0.33, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.66, 0),
      Offset(size.width * 0.66, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
