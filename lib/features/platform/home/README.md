# PWF Home New – Widget Tree Contract

الهدف: تحويل صفحة **palwak_homepage.html** إلى Flutter Web **1:1** (شكل/ترتيب/تأثيرات) داخل المنصة، مع منع تعارض المسميات عبر prefix **Pwf**.

## ترتيب الأقسام (مطابق للـ HTML)

1. Islamic patterns overlay (decor) – `PwfIslamicPatternsOverlay`
2. Scroll to top – `PwfScrollToTopButton`
3. Theme controls – `PwfThemeControlsOverlay`
4. Header (TopBar + MainHeader + MainNav) – `PwfHeader`
5. Hero – `PwfHeroSliderSection`
6. Stats – `PwfStatsSection`
7. E-Services – `PwfEServicesPortalSection`
8. Minister word – `PwfMinisterWordSection`
9. Quick services – `PwfQuickServicesSection`
10. News – `PwfNewsSection`
11. Media gallery (photos/videos/events tabs) – `PwfMediaGallerySection`
12. Announcements – `PwfAnnouncementsSection`
13. Activities – `PwfActivitiesSection`
14. Friday sermons – `PwfFridaySermonsSection`
15. Important links – `PwfImportantLinksSection`
16. Prayer times – `PwfPrayerTimesWidget`
17. Footer – `PwfFooterSection`
18. Login modal – `PwfLoginModal`

## ملاحظات
- كل Widget الآن Placeholder (بدون UI كامل) باستثناء شاشة الجذر والتعامل مع ScrollController (جزء حرج).
- الربط مع Providers/Repos يتم لاحقًا لكل قسم على حدة مع الحفاظ على نفس أسماء الـ Widgets.
- راجع `pwf_home_new_contract.dart` للمفاتيح والثوابت.
