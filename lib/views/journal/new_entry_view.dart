// filepath: /Users/developer/Desktop/flutter/koda/lib/views/journal/new_entry_view.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../data/models/content_block.dart';
import '../../view_models/new_entry_view_model.dart';

// ---------------------------------------------------------------------------
// Entry point – injects the ViewModel
// ---------------------------------------------------------------------------
class NewEntryView extends StatelessWidget {
  const NewEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewEntryViewModel(),
      child: const _NewEntryScaffold(),
    );
  }
}

// ---------------------------------------------------------------------------
// Scaffold owns UI state (recording timer, image picker)
// ---------------------------------------------------------------------------
class _NewEntryScaffold extends StatefulWidget {
  const _NewEntryScaffold();

  @override
  State<_NewEntryScaffold> createState() => _NewEntryScaffoldState();
}

class _NewEntryScaffoldState extends State<_NewEntryScaffold> {
  final _titleController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _isRecording = false;
  Duration _recordDuration = Duration.zero;
  Timer? _recordTimer;

  @override
  void dispose() {
    _titleController.dispose();
    _recordTimer?.cancel();
    super.dispose();
  }

  // ── Recording ─────────────────────────────────────────────────────────────

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordDuration = Duration.zero;
    });
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordDuration += const Duration(seconds: 1));
    });
    // TODO: integrate `record` package for actual audio capture
  }

  void _stopRecording() {
    _recordTimer?.cancel();
    final duration = _recordDuration;
    setState(() {
      _isRecording = false;
      _recordDuration = Duration.zero;
    });
    context.read<NewEntryViewModel>().addVoiceBlock(duration);
  }

  // ── Image picker ──────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      context.read<NewEntryViewModel>().addImageBlock(File(picked.path));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NewEntryViewModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFDE8DC),
      body: Stack(
        children: [
          // Gradient background
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFFDEAC).withOpacity(0.5),
                    const Color(0xFFFDE8DC),
                    const Color(0xFFF9D8DB).withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // ── App bar ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      _CircleIconButton(
                        icon: Icons.close,
                        onTap: () => context.pop(),
                      ),
                      Expanded(
                        child: Text(
                          'New Entry',
                          textAlign: TextAlign.center,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                      ),
                      vm.isLoading
                          ? const SizedBox(
                              width: 72,
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : FilledButton(
                              onPressed: () => vm.save(context),
                              style: FilledButton.styleFrom(
                                backgroundColor: cs.primaryContainer,
                                foregroundColor: cs.onPrimaryContainer,
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                    ],
                  ),
                ),

                // ── Scrollable content ───────────────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    // Pull-to-scroll physics give a natural feel on iOS/Android
                    physics: const BouncingScrollPhysics(),
                    children: [
                      TextField(
                        controller: _titleController,
                        onChanged: vm.setTitle,
                        style: tt.headlineMedium?.copyWith(
                          color: const Color(0xFF2D2D2D),
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Title your reflection…',
                          hintStyle: tt.headlineMedium?.copyWith(color: Colors.black26),
                          border: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        maxLines: null,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 13, color: Colors.black38),
                          const SizedBox(width: 5),
                          Text(_formatEntryDate(vm.entryDate), style: tt.labelSmall?.copyWith(color: Colors.black38)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Content blocks – rendered INLINE in the scroll view
                      for (final block in vm.blocks)
                        switch (block) {
                          TextContentBlock() => _TextBlockWidget(
                              key: ValueKey(block.id),
                              block: block,
                              onChanged: (t) => vm.updateTextBlock(block.id, t),
                            ),
                          ImageContentBlock() => _ImageBlockWidget(
                              key: ValueKey(block.id),
                              block: block,
                              onRemove: () => vm.removeBlock(block.id),
                            ),
                          VoiceContentBlock() => _VoiceBlockWidget(
                              key: ValueKey(block.id),
                              block: block,
                              onRemove: () => vm.removeBlock(block.id),
                            ),
                        },
                    ],
                  ),
                ),

                // ── Recording banner ─────────────────────────────────────
                if (_isRecording)
                  Container(
                    color: Colors.red.withOpacity(0.08),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Row(
                      children: [
                        const _PulsingDot(),
                        const SizedBox(width: 10),
                        Text(
                          'Recording  ${_formatDuration(_recordDuration)}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _stopRecording,
                          child: const Text('Stop', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                // ── Bottom formatting / action bar ───────────────────────
                _JournalBottomBar(
                  onVoice: _isRecording ? _stopRecording : _startRecording,
                  onImage: _pickImage,
                  isRecording: _isRecording,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatEntryDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${months[d.month - 1]} ${d.day}, ${d.year}  •  $h:$m';
  }
}

// ---------------------------------------------------------------------------
// Text block – owns its own TextEditingController
// ---------------------------------------------------------------------------
class _TextBlockWidget extends StatefulWidget {
  final TextContentBlock block;
  final ValueChanged<String> onChanged;

  const _TextBlockWidget({required super.key, required this.block, required this.onChanged});

  @override
  State<_TextBlockWidget> createState() => _TextBlockWidgetState();
}

class _TextBlockWidgetState extends State<_TextBlockWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.block.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color(0xFF2D2D2D)),
      decoration: const InputDecoration(
        hintText: 'Write your thoughts…',
        hintStyle: TextStyle(color: Colors.black26),
        border: InputBorder.none,
        filled: false,
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
      maxLines: null,
      keyboardType: TextInputType.multiline,
    );
  }
}

// ---------------------------------------------------------------------------
// Image block – INLINE in the ListView (NOT a floating overlay)
// ---------------------------------------------------------------------------
class _ImageBlockWidget extends StatelessWidget {
  final ImageContentBlock block;
  final VoidCallback onRemove;

  const _ImageBlockWidget({required super.key, required this.block, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              block.file,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 220,
                color: Colors.black12,
                child: const Center(child: Icon(Icons.broken_image_outlined)),
              ),
            ),
          ),
          // Remove button — always reachable, rendered inside the block Stack
          Positioned(
            top: 10,
            right: 10,
            child: _RemoveButton(onTap: onRemove),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Voice block – INLINE playback card
// ---------------------------------------------------------------------------
class _VoiceBlockWidget extends StatefulWidget {
  final VoiceContentBlock block;
  final VoidCallback onRemove;

  const _VoiceBlockWidget({required super.key, required this.block, required this.onRemove});

  @override
  State<_VoiceBlockWidget> createState() => _VoiceBlockWidgetState();
}

class _VoiceBlockWidgetState extends State<_VoiceBlockWidget> {
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Timer? _playTimer;

  @override
  void dispose() {
    _playTimer?.cancel();
    super.dispose();
  }

  void _togglePlayback() {
    if (_isPlaying) {
      _playTimer?.cancel();
      setState(() => _isPlaying = false);
    } else {
      setState(() { _isPlaying = true; _position = Duration.zero; });
      _playTimer = Timer.periodic(const Duration(milliseconds: 200), (t) {
        setState(() => _position += const Duration(milliseconds: 200));
        if (_position >= widget.block.duration) {
          t.cancel();
          setState(() { _isPlaying = false; _position = Duration.zero; });
        }
      });
    }
    // TODO: integrate just_audio for real playback
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = widget.block.duration.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / widget.block.duration.inMilliseconds).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: _togglePlayback,
              icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
              color: cs.primary,
              iconSize: 36,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: cs.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(cs.primaryContainer),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(_position), style: const TextStyle(fontSize: 11, color: Colors.black45)),
                      Text(_fmt(widget.block.duration), style: const TextStyle(fontSize: 11, color: Colors.black45)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _RemoveButton(onTap: widget.onRemove, dark: false),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom formatting bar
// ---------------------------------------------------------------------------
class _JournalBottomBar extends StatelessWidget {
  final VoidCallback onVoice;
  final VoidCallback onImage;
  final bool isRecording;

  const _JournalBottomBar({
    required this.onVoice,
    required this.onImage,
    required this.isRecording,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Formatting buttons
          _FmtButton(label: 'B', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), onTap: () {}),
          _FmtButton(label: 'I', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16), onTap: () {}),
          _FmtButton(icon: Icons.format_list_bulleted, onTap: () {}),

          Container(width: 1, height: 24, color: Colors.black12),

          // Voice / Image
          _MediaButton(
            icon: isRecording ? Icons.stop_circle : Icons.mic_none,
            label: isRecording ? 'Stop' : 'Voice',
            color: isRecording ? Colors.red : cs.primary,
            onTap: onVoice,
          ),
          _MediaButton(
            icon: Icons.add_photo_alternate_outlined,
            label: 'Image',
            color: cs.primary,
            onTap: onImage,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

class _RemoveButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool dark;

  const _RemoveButton({required this.onTap, this.dark = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: dark ? Colors.black54 : Colors.black12,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.close, size: 16, color: dark ? Colors.white : Colors.black54),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class _FmtButton extends StatelessWidget {
  final String? label;
  final TextStyle? style;
  final IconData? icon;
  final VoidCallback onTap;

  const _FmtButton({this.label, this.style, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: icon != null
            ? Icon(icon, size: 20, color: Colors.black54)
            : Text(label!, style: style?.copyWith(color: Colors.black54) ?? const TextStyle(color: Colors.black54)),
      ),
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MediaButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _a = Tween<double>(begin: 0.4, end: 1.0).animate(_c);
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _a,
    child: const CircleAvatar(radius: 5, backgroundColor: Colors.red),
  );
}
