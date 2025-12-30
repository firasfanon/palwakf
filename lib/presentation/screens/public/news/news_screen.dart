import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'mobile_news_screen.dart';
import 'web_news_screen.dart';

class NewsScreen extends StatelessWidget {
  final String unitSlug;

  const NewsScreen({super.key, required this.unitSlug});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return WebNewsScreen(unitSlug: unitSlug);
    } else {
      return MobileNewsScreen(unitSlug: unitSlug);
    }
  }
}