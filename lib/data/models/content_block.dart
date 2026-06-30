// filepath: /Users/developer/Desktop/flutter/koda/lib/data/models/content_block.dart
import 'dart:io';

String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

/// Sealed union of all content block types inside a journal entry.
sealed class ContentBlock {
  final String id;
  ContentBlock(this.id);
}

final class TextContentBlock extends ContentBlock {
  String text;
  TextContentBlock({String? id, this.text = ''}) : super(id ?? _newId());
}

final class ImageContentBlock extends ContentBlock {
  final File file;
  ImageContentBlock({String? id, required this.file}) : super(id ?? _newId());
}

final class VoiceContentBlock extends ContentBlock {
  final Duration duration;
  VoiceContentBlock({String? id, required this.duration}) : super(id ?? _newId());
}
