import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'mobile_documents_screen.dart';
import 'web_documents_screen.dart';


class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const WebDocumentsScreen();
    } else {
      return const MobileDocumentsScreen();
    }
  }
}
