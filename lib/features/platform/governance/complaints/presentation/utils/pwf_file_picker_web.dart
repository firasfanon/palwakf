// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;

import '../widgets/pwf_picked_file.dart';

Future<List<PwfPickedFile>> pwfPickFiles({required bool multiple}) async {
  final completer = Completer<List<PwfPickedFile>>();

  final input = html.FileUploadInputElement()
    ..multiple = multiple
    ..accept = '*/*';

  input.onChange.listen((_) {
    final files = input.files ?? const <html.File>[];
    final out = <PwfPickedFile>[];
    for (final f in files) {
      out.add(PwfPickedFile(name: f.name, sizeBytes: f.size));
    }
    completer.complete(out);
  });

  input.click();

  return completer.future;
}
