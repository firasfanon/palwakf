import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:waqf/core/constants/app_constants.dart';

class SharedContentMediaUploadHelper {
  static const String bucket = AppConstants.mediaGalleryBucket;

  static Future<String?> pickAndUpload({
    required BuildContext context,
    required String familyKey,
    required String folder,
    required String unitScopeKey,
    required List<String> allowedExtensions,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return null;

      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        if (!context.mounted) return null;
        _showSnack(context, 'تعذر قراءة الملف. حاول مجددًا.');
        return null;
      }

      final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9_\-.]'), '_');
      final ext = (file.extension ?? '').trim().isEmpty
          ? 'bin'
          : file.extension!.trim();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final path =
          'shared-content/$familyKey/$folder/$unitScopeKey/${ts}_$safeName.$ext';

      final dynamic storage = Supabase.instance.client.storage.from(bucket);
      final dynamic options = FileOptions(upsert: true);

      bool uploaded = false;
      try {
        await storage.uploadBinary(path, bytes, fileOptions: options);
        uploaded = true;
      } catch (_) {
        try {
          await storage.upload(path, bytes, fileOptions: options);
          uploaded = true;
        } catch (_) {
          uploaded = false;
        }
      }

      if (!uploaded) {
        if (!context.mounted) return null;
        _showSnack(context, 'فشل رفع الملف. تحقق من bucket والسياسات.');
        return null;
      }

      final url = storage.getPublicUrl(path);
      if (!context.mounted) return null;
      _showSnack(context, 'تم رفع الملف بنجاح ✅');
      return url;
    } catch (e) {
      if (!context.mounted) return null;
      _showSnack(context, 'تعذر رفع الملف: $e');
      return null;
    }
  }

  static void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class SharedContentUploadField extends StatelessWidget {
  const SharedContentUploadField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.buttonLabel,
    required this.busy,
    required this.onUpload,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final String buttonLabel;
  final bool busy;
  final Future<void> Function() onUpload;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(labelText: label, hintText: hintText),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: busy ? null : () => onUpload(),
            icon: busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file_rounded),
            label: Text(buttonLabel),
          ),
        ),
      ],
    );
  }
}
