import 'package:flutter/material.dart';

import '../l10n/pwf_complaints_strings.dart';
import 'pwf_picked_file.dart';

class PwfUploadedFilesList extends StatelessWidget {
  final List<PwfPickedFile> files;
  final void Function(PwfPickedFile file) onRemove;

  const PwfUploadedFilesList({
    super.key,
    required this.files,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final s = PwfComplaintsStrings.of(context);
    if (files.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 12),
        for (final file in files)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Row(
              children: [
                const Icon(Icons.insert_drive_file, color: Color(0xFF0D3C61)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${file.name} (${_formatSize(file.sizeBytes)})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  tooltip: MaterialLocalizations.of(
                    context,
                  ).deleteButtonTooltip,
                  onPressed: () => onRemove(file),
                  icon: const Icon(Icons.close, color: Color(0xFFB22222)),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${s.t('complaints.form.attachments')}: ${files.length}',
            style: TextStyle(
              color: const Color(0xFF0D3C61).withValues(alpha: 150),
            ),
          ),
        ),
      ],
    );
  }

  static String _formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const k = 1024;
    const units = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= k && i < units.length - 1) {
      size /= k;
      i++;
    }
    return '${size.toStringAsFixed(i == 0 ? 0 : 2)} ${units[i]}';
  }
}
