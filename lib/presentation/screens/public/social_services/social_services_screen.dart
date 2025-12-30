import 'package:flutter/material.dart';
import '../../../widgets/public/public_page_scaffold.dart';

class SocialServicesScreen extends StatelessWidget {
  const SocialServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PublicPageScaffold(
      title: 'الخدمات الاجتماعية',
      child: Center(
        child: Text('سيتم ربط هذه الصفحة بخدمات الوزارة وبرامجها الاجتماعية قريبًا.'),
      ),
    );
  }
}
