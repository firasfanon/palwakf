// lib/data/repositories/footer_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/footer_settings.dart';

class FooterRepository {
  final SupabaseClient _supabase;

  FooterRepository(this._supabase);

  Future<FooterSettings> fetchFooterSettings() async {
    final response = await _supabase
        .from('footer_settings')
        .select()
        .single();

    // Parse JSONB arrays
    final data = Map<String, dynamic>.from(response);

    if (data['quick_links'] != null) {
      data['quick_links'] = (data['quick_links'] as List)
          .map((e) => FooterLink.fromJson(e))
          .toList();
    }

    if (data['services_links'] != null) {
      data['services_links'] = (data['services_links'] as List)
          .map((e) => FooterLink.fromJson(e))
          .toList();
    }

    if (data['bottom_links'] != null) {
      data['bottom_links'] = (data['bottom_links'] as List)
          .map((e) => FooterLink.fromJson(e))
          .toList();
    }

    if (data['partners'] != null) {
      data['partners'] = (data['partners'] as List)
          .map((e) => FooterPartner.fromJson(e))
          .toList();
    }

    return FooterSettings.fromJson(data);
  }

  Future<void> updateFooterSettings(FooterSettings settings) async {
    await _supabase
        .from('footer_settings')
        .update({
      'ministry_logo_url': settings.ministryLogoUrl,
      'ministry_name': settings.ministryName,
      'ministry_subtitle': settings.ministrySubtitle,
      'ministry_description': settings.ministryDescription,
      'contact_phone': settings.contactPhone,
      'contact_fax': settings.contactFax,
      'contact_email': settings.contactEmail,
      'contact_address': settings.contactAddress,
      'working_days': settings.workingDays,
      'working_hours': settings.workingHours,
      'facebook_url': settings.facebookUrl,
      'twitter_url': settings.twitterUrl,
      'instagram_url': settings.instagramUrl,
      'youtube_url': settings.youtubeUrl,
      'linkedin_url': settings.linkedinUrl,
      'quick_links': settings.quickLinks.map((e) => e.toJson()).toList(),
      'services_links': settings.servicesLinks.map((e) => e.toJson()).toList(),
      'bottom_links': settings.bottomLinks.map((e) => e.toJson()).toList(),
      'partners': settings.partners.map((e) => e.toJson()).toList(),
      'show_partners': settings.showPartners,
      'copyright_text': settings.copyrightText,
      'developer_credit': settings.developerCredit,
      'show_developer_credit': settings.showDeveloperCredit,
      'show_phone': settings.showPhone,
      'show_email': settings.showEmail,
      'show_address': settings.showAddress,
      'show_working_hours': settings.showWorkingHours,
      'updated_at': DateTime.now().toIso8601String(),
    })
        .eq('id', settings.id);
  }
}