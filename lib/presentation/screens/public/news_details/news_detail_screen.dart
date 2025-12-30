import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'mobile_news_details_screen.dart';
import 'web_news_details_screen.dart';

class NewsDetailScreen extends StatelessWidget {
  final dynamic article;

  const NewsDetailScreen({super.key, this.article});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return WebNewsDetailScreen(article: article);
    } else {
      return MobileNewsDetailScreen(article: article);
    }
  }
}