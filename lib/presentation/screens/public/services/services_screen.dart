// lib/presentation/screens/public/home_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../home/mobile_home_screen.dart';
import 'web_services_screen.dart';


class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const WebServicesScreen();
    } else {
      return const MobileHomeScreen();
    }
  }
}