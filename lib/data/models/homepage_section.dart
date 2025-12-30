// lib/data/models/homepage_section.dart
import 'package:json_annotation/json_annotation.dart';

part 'homepage_section.g.dart';

/// Model for homepage sections stored in Supabase
@JsonSerializable()
class HomepageSection {
  final String id;
  final String sectionName;
  final Map<String, dynamic> settings;
  final bool isActive;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? updatedBy;

  const HomepageSection({
    required this.id,
    required this.sectionName,
    required this.settings,
    this.isActive = true,
    this.displayOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.updatedBy,
  });

  factory HomepageSection.fromJson(Map<String, dynamic> json) =>
      _$HomepageSectionFromJson(json);

  Map<String, dynamic> toJson() => _$HomepageSectionToJson(this);

  HomepageSection copyWith({
    String? id,
    String? sectionName,
    Map<String, dynamic>? settings,
    bool? isActive,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return HomepageSection(
      id: id ?? this.id,
      sectionName: sectionName ?? this.sectionName,
      settings: settings ?? this.settings,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

// ============================================
// SITE SETTINGS (New - Single Row)
// ============================================

@JsonSerializable()
class SiteSettings {
  final String id;
  final String logoUrl;
  final String? faviconUrl;
  final String siteTitle;
  final String siteSubtitle;
  final String? contactEmail;
  final String? contactPhone;
  final String? contactAddress;
  final String? facebookUrl;
  final String? twitterUrl;
  final String? instagramUrl;
  final String? youtubeUrl;
  final String? footerText;
  final bool sliderAutoplay;
  final int sliderSpeed;
  final bool sliderShowDots;
  final bool sliderShowArrows;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? updatedBy;

  const SiteSettings({
    required this.id,
    required this.logoUrl,
    this.faviconUrl,
    required this.siteTitle,
    required this.siteSubtitle,
    this.contactEmail,
    this.contactPhone,
    this.contactAddress,
    this.facebookUrl,
    this.twitterUrl,
    this.instagramUrl,
    this.youtubeUrl,
    this.footerText,
    this.sliderAutoplay = true,
    this.sliderSpeed = 5000,
    this.sliderShowDots = true,
    this.sliderShowArrows = true,
    required this.createdAt,
    required this.updatedAt,
    this.updatedBy,
  });

  factory SiteSettings.fromJson(Map<String, dynamic> json) =>
      _$SiteSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SiteSettingsToJson(this);

  SiteSettings copyWith({
    String? id,
    String? logoUrl,
    String? faviconUrl,
    String? siteTitle,
    String? siteSubtitle,
    String? contactEmail,
    String? contactPhone,
    String? contactAddress,
    String? facebookUrl,
    String? twitterUrl,
    String? instagramUrl,
    String? youtubeUrl,
    String? footerText,
    bool? sliderAutoplay,
    int? sliderSpeed,
    bool? sliderShowDots,
    bool? sliderShowArrows,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return SiteSettings(
      id: id ?? this.id,
      logoUrl: logoUrl ?? this.logoUrl,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      siteTitle: siteTitle ?? this.siteTitle,
      siteSubtitle: siteSubtitle ?? this.siteSubtitle,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      contactAddress: contactAddress ?? this.contactAddress,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      twitterUrl: twitterUrl ?? this.twitterUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      footerText: footerText ?? this.footerText,
      sliderAutoplay: sliderAutoplay ?? this.sliderAutoplay,
      sliderSpeed: sliderSpeed ?? this.sliderSpeed,
      sliderShowDots: sliderShowDots ?? this.sliderShowDots,
      sliderShowArrows: sliderShowArrows ?? this.sliderShowArrows,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

// ============================================
// HERO SLIDE (New - Multiple Rows)
// ============================================

@JsonSerializable()
class HeroSlide {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final String? ctaText;        // ← Make nullable
  final String? ctaLink;        // ← Make nullable
  final int displayOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? updatedBy;  // ← Add this


  HeroSlide({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    this.ctaText,              // ← Remove 'required'
    this.ctaLink,              // ← Remove 'required'
    required this.displayOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.updatedBy,  // ← Add this

  });

  factory HeroSlide.fromJson(Map<String, dynamic> json) {
    return HeroSlide(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      ctaText: json['cta_text'] as String?,     // ← Add ? (nullable cast)
      ctaLink: json['cta_link'] as String?,     // ← Add ? (nullable cast)
      displayOrder: json['display_order'] as int,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      updatedBy: json['updated_by'] as String?,  // ← Add this

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'image_url': imageUrl,
      'cta_text': ctaText,           // Can be null ✅
      'cta_link': ctaLink,           // Can be null ✅
      'display_order': displayOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'updated_by': updatedBy,  // ← Add this

    };
  }

  HeroSlide copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    String? imageUrl,
    String? ctaText,
    String? ctaLink,
    int? displayOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedBy,  // ← Add this

  }) {
    return HeroSlide(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ctaText: ctaText ?? this.ctaText,
      ctaLink: ctaLink ?? this.ctaLink,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,  // ← Add this

    );
  }
}
// ============================================
// Specific Section Settings Models
// ============================================

/// Minister Section Settings
class MinisterSectionSettings {
  final String name;
  final String position;
  final String message;
  final String quote;
  final String imageUrl;
  final bool showQuote;
  final bool showSignature;
  final String messageLink;

  const MinisterSectionSettings({
    required this.name,
    required this.position,
    required this.message,
    required this.quote,
    required this.imageUrl,
    this.showQuote = true,
    this.showSignature = true,
    this.messageLink = '/minister',
  });

  factory MinisterSectionSettings.fromJson(Map<String, dynamic> json) {
    return MinisterSectionSettings(
      name: json['name'] as String? ?? '',
      position: json['position'] as String? ?? '',
      message: json['message'] as String? ?? '',
      quote: json['quote'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      showQuote: json['showQuote'] as bool? ?? true,
      showSignature: json['showSignature'] as bool? ?? true,
      messageLink: json['messageLink'] as String? ?? '/minister',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'position': position,
      'message': message,
      'quote': quote,
      'imageUrl': imageUrl,
      'showQuote': showQuote,
      'showSignature': showSignature,
      'messageLink': messageLink,
    };
  }

  MinisterSectionSettings copyWith({
    String? name,
    String? position,
    String? message,
    String? quote,
    String? imageUrl,
    bool? showQuote,
    bool? showSignature,
    String? messageLink,
  }) {
    return MinisterSectionSettings(
      name: name ?? this.name,
      position: position ?? this.position,
      message: message ?? this.message,
      quote: quote ?? this.quote,
      imageUrl: imageUrl ?? this.imageUrl,
      showQuote: showQuote ?? this.showQuote,
      showSignature: showSignature ?? this.showSignature,
      messageLink: messageLink ?? this.messageLink,
    );
  }
}

/// Statistics Counter
class StatisticCounter {
  final String label;
  final int value;
  final String icon;
  final String color;
  final int target;

  const StatisticCounter({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.target,
  });

  factory StatisticCounter.fromJson(Map<String, dynamic> json) {
    return StatisticCounter(
      label: json['label'] as String? ?? '',
      value: json['value'] as int? ?? 0,
      icon: json['icon'] as String? ?? 'building',
      color: json['color'] as String? ?? '#22C55E',
      target: json['target'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'icon': icon,
      'color': color,
      'target': target,
    };
  }
}

/// Statistics Section Settings
class StatisticsSectionSettings {
  final bool showAnimatedCounters;
  final int animationDuration;
  final List<StatisticCounter> counters;
  final bool showTargets;
  final bool showProgress;
  final String layout;

  const StatisticsSectionSettings({
    this.showAnimatedCounters = true,
    this.animationDuration = 2000,
    required this.counters,
    this.showTargets = true,
    this.showProgress = true,
    this.layout = 'grid',
  });

  factory StatisticsSectionSettings.fromJson(Map<String, dynamic> json) {
    final countersList = json['counters'] as List<dynamic>? ?? [];
    return StatisticsSectionSettings(
      showAnimatedCounters: json['showAnimatedCounters'] as bool? ?? true,
      animationDuration: json['animationDuration'] as int? ?? 2000,
      counters: countersList
          .map((e) => StatisticCounter.fromJson(e as Map<String, dynamic>))
          .toList(),
      showTargets: json['showTargets'] as bool? ?? true,
      showProgress: json['showProgress'] as bool? ?? true,
      layout: json['layout'] as String? ?? 'grid',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showAnimatedCounters': showAnimatedCounters,
      'animationDuration': animationDuration,
      'counters': counters.map((e) => e.toJson()).toList(),
      'showTargets': showTargets,
      'showProgress': showProgress,
      'layout': layout,
    };
  }
}

/// News Section Settings
class NewsSectionSettings {
  final int showCount;
  final bool showCategories;
  final bool showViewCounts;
  final bool showDates;
  final String layout;
  final bool autoRefresh;
  final int refreshInterval;
  final bool showExcerpts;
  final bool showAuthors;
  final bool showImages;

  const NewsSectionSettings({
    this.showCount = 3,
    this.showCategories = true,
    this.showViewCounts = true,
    this.showDates = true,
    this.layout = 'grid',
    this.autoRefresh = false,
    this.refreshInterval = 300000,
    this.showExcerpts = true,
    this.showAuthors = true,
    this.showImages = true,
  });

  factory NewsSectionSettings.fromJson(Map<String, dynamic> json) {
    return NewsSectionSettings(
      showCount: json['showCount'] as int? ?? 3,
      showCategories: json['showCategories'] as bool? ?? true,
      showViewCounts: json['showViewCounts'] as bool? ?? true,
      showDates: json['showDates'] as bool? ?? true,
      layout: json['layout'] as String? ?? 'grid',
      autoRefresh: json['autoRefresh'] as bool? ?? false,
      refreshInterval: json['refreshInterval'] as int? ?? 300000,
      showExcerpts: json['showExcerpts'] as bool? ?? true,
      showAuthors: json['showAuthors'] as bool? ?? true,
      showImages: json['showImages'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showCount': showCount,
      'showCategories': showCategories,
      'showViewCounts': showViewCounts,
      'showDates': showDates,
      'layout': layout,
      'autoRefresh': autoRefresh,
      'refreshInterval': refreshInterval,
      'showExcerpts': showExcerpts,
      'showAuthors': showAuthors,
      'showImages': showImages,
    };
  }
}

/// Announcements Section Settings
class AnnouncementsSectionSettings {
  final int showCount;
  final bool showPriorities;
  final bool showExpiry;
  final bool highlightUrgent;
  final String layout;
  final bool showIcons;
  final bool showDates;

  const AnnouncementsSectionSettings({
    this.showCount = 4,
    this.showPriorities = true,
    this.showExpiry = true,
    this.highlightUrgent = true,
    this.layout = 'cards',
    this.showIcons = true,
    this.showDates = true,
  });

  factory AnnouncementsSectionSettings.fromJson(Map<String, dynamic> json) {
    return AnnouncementsSectionSettings(
      showCount: json['showCount'] as int? ?? 4,
      showPriorities: json['showPriorities'] as bool? ?? true,
      showExpiry: json['showExpiry'] as bool? ?? true,
      highlightUrgent: json['highlightUrgent'] as bool? ?? true,
      layout: json['layout'] as String? ?? 'cards',
      showIcons: json['showIcons'] as bool? ?? true,
      showDates: json['showDates'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showCount': showCount,
      'showPriorities': showPriorities,
      'showExpiry': showExpiry,
      'highlightUrgent': highlightUrgent,
      'layout': layout,
      'showIcons': showIcons,
      'showDates': showDates,
    };

  }

}


// ============================================
// BREAKING NEWS (Multiple Rows)
// ============================================

/// Individual Breaking News Item
class BreakingNewsItem {
  final String id;
  final String text;
  final String? link;
  final String? icon;
  final String priority; // 'urgent', 'high', 'normal'
  final String bgColor;
  final String textColor;
  final int displayOrder;
  final bool isActive;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? updatedBy;

  const BreakingNewsItem({
    required this.id,
    required this.text,
    this.link,
    this.icon,
    this.priority = 'normal',
    this.bgColor = '#DC2626',
    this.textColor = '#FFFFFF',
    required this.displayOrder,
    this.isActive = true,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.updatedBy,
  });

  factory BreakingNewsItem.fromJson(Map<String, dynamic> json) {
    return BreakingNewsItem(
      id: json['id'] as String,
      text: json['text'] as String,
      link: json['link'] as String?,
      icon: json['icon'] as String?,
      priority: json['priority'] as String? ?? 'normal',
      bgColor: json['bg_color'] as String? ?? '#DC2626',
      textColor: json['text_color'] as String? ?? '#FFFFFF',
      displayOrder: json['display_order'] as int,
      isActive: json['is_active'] as bool? ?? true,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      updatedBy: json['updated_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'link': link,
      'icon': icon,
      'priority': priority,
      'bg_color': bgColor,
      'text_color': textColor,
      'display_order': displayOrder,
      'is_active': isActive,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'updated_by': updatedBy,
    };
  }

  BreakingNewsItem copyWith({
    String? id,
    String? text,
    String? link,
    String? icon,
    String? priority,
    String? bgColor,
    String? textColor,
    int? displayOrder,
    bool? isActive,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return BreakingNewsItem(
      id: id ?? this.id,
      text: text ?? this.text,
      link: link ?? this.link,
      icon: icon ?? this.icon,
      priority: priority ?? this.priority,
      bgColor: bgColor ?? this.bgColor,
      textColor: textColor ?? this.textColor,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

/// Breaking News Section Settings
class BreakingNewsSectionSettings {
  final bool enabled;
  final bool autoScroll;
  final int scrollSpeed; // pixels per second
  final int pauseDuration; // milliseconds
  final bool showIcon;
  final String defaultIcon;
  final bool showSeparator;
  final String separatorText;
  final bool allowClick;
  final bool showBorder;
  final int maxItems;

  const BreakingNewsSectionSettings({
    this.enabled = true,
    this.autoScroll = true,
    this.scrollSpeed = 50,
    this.pauseDuration = 3000,
    this.showIcon = true,
    this.defaultIcon = 'campaign',
    this.showSeparator = true,
    this.separatorText = '•',
    this.allowClick = true,
    this.showBorder = true,
    this.maxItems = 10,
  });

  factory BreakingNewsSectionSettings.fromJson(Map<String, dynamic> json) {
    return BreakingNewsSectionSettings(
      enabled: json['enabled'] as bool? ?? true,
      autoScroll: json['autoScroll'] as bool? ?? true,
      scrollSpeed: json['scrollSpeed'] as int? ?? 50,
      pauseDuration: json['pauseDuration'] as int? ?? 3000,
      showIcon: json['showIcon'] as bool? ?? true,
      defaultIcon: json['defaultIcon'] as String? ?? 'campaign',
      showSeparator: json['showSeparator'] as bool? ?? true,
      separatorText: json['separatorText'] as String? ?? '•',
      allowClick: json['allowClick'] as bool? ?? true,
      showBorder: json['showBorder'] as bool? ?? true,
      maxItems: json['maxItems'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'autoScroll': autoScroll,
      'scrollSpeed': scrollSpeed,
      'pauseDuration': pauseDuration,
      'showIcon': showIcon,
      'defaultIcon': defaultIcon,
      'showSeparator': showSeparator,
      'separatorText': separatorText,
      'allowClick': allowClick,
      'showBorder': showBorder,
      'maxItems': maxItems,
    };
  }

  BreakingNewsSectionSettings copyWith({
    bool? enabled,
    bool? autoScroll,
    int? scrollSpeed,
    int? pauseDuration,
    bool? showIcon,
    String? defaultIcon,
    bool? showSeparator,
    String? separatorText,
    bool? allowClick,
    bool? showBorder,
    int? maxItems,




  }) {
    return BreakingNewsSectionSettings(
      enabled: enabled ?? this.enabled,
      autoScroll: autoScroll ?? this.autoScroll,
      scrollSpeed: scrollSpeed ?? this.scrollSpeed,
      pauseDuration: pauseDuration ?? this.pauseDuration,
      showIcon: showIcon ?? this.showIcon,
      defaultIcon: defaultIcon ?? this.defaultIcon,
      showSeparator: showSeparator ?? this.showSeparator,
      separatorText: separatorText ?? this.separatorText,
      allowClick: allowClick ?? this.allowClick,
      showBorder: showBorder ?? this.showBorder,
      maxItems: maxItems ?? this.maxItems,
    );
  }
}













