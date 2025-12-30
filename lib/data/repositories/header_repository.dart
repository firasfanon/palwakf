// lib/data/repositories/header_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/header_settings.dart';

class HeaderRepository {
  final SupabaseClient _supabase;

  HeaderRepository(this._supabase);

  Future<HeaderSettings> fetchHeaderSettings() async {
    final response = await _supabase
        .from('header_settings')
        .select()
        .single();

    return HeaderSettings.fromJson(response);
  }

  Future<void> updateHeaderSettings(HeaderSettings settings) async {
    await _supabase
        .from('header_settings')
        .update({
      'logo_url': settings.logoUrl,
      'logo_alt': settings.logoAlt,
      'site_name': settings.siteName,
      'site_tagline': settings.siteTagline,
      'favicon_url': settings.faviconUrl,
      'show_breaking_news': settings.showBreakingNews,
      'breaking_news_text': settings.breakingNewsText,
      'updated_at': DateTime.now().toIso8601String(),
    })
        .eq('id', settings.id);
  }
}