import 'package:flutter/foundation.dart';

@immutable
class PwfPickedFile {
  final String name;
  final int sizeBytes;
  const PwfPickedFile({required this.name, required this.sizeBytes});
}
