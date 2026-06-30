// filepath: /Users/developer/Desktop/flutter/koda/lib/view_models/new_entry_view_model.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/content_block.dart';
import 'base_view_model.dart';

class NewEntryViewModel extends BaseViewModel {
  String _title = '';
  final DateTime entryDate = DateTime.now();
  final List<ContentBlock> _blocks = [TextContentBlock()];

  String get title => _title;
  List<ContentBlock> get blocks => List.unmodifiable(_blocks);

  void setTitle(String value) {
    _title = value;
  }

  void updateTextBlock(String id, String text) {
    final block = _blocks.firstWhere((b) => b.id == id);
    if (block is TextContentBlock) block.text = text;
  }

  void addImageBlock(File file) {
    _blocks.add(ImageContentBlock(file: file));
    _blocks.add(TextContentBlock());
    notifyListeners();
  }

  void addVoiceBlock(Duration duration) {
    _blocks.add(VoiceContentBlock(duration: duration));
    _blocks.add(TextContentBlock());
    notifyListeners();
  }

  void removeBlock(String id) {
    _blocks.removeWhere((b) => b.id == id);
    if (_blocks.isEmpty || _blocks.every((b) => b is! TextContentBlock)) {
      _blocks.add(TextContentBlock());
    }
    notifyListeners();
  }

  Future<void> save(BuildContext context) async {
    setLoading(true);
    await Future.delayed(const Duration(milliseconds: 600));
    setLoading(false);
    if (context.mounted) Navigator.of(context).pop();
  }
}
