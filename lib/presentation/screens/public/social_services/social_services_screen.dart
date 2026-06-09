import 'package:flutter/material.dart';
import '../../../widgets/public/public_page_scaffold.dart';

class SocialServicesScreen extends StatelessWidget {
  const SocialServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PublicPageScaffold(
      title: 'الاجتماعيات',
      child: Center(
        child: Text(
          'تهاني وتعازي ومناسبات اجتماعية رسمية ضمن المركز الإعلامي، وليست خدمة جمهور أو معاملة إلكترونية.',
        ),
      ),
    );
  }
}
