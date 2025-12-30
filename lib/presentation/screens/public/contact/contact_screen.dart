import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'mobile_contact_screen.dart';
import 'web_contact_screen.dart';


class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const WebContactScreen();
    } else {
      return const MobileContactScreen();
    }
  }
}
