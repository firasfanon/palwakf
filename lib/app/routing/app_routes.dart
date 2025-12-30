import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  // Admin
  static const adminUsers = '/admin/users';
  static const adminFridaySermons = '/admin/friday-sermons';
  static const adminMosques = '/admin/mosques';
  static const adminOrgUnits = '/admin/org-units';

  // Public
  /// Root of the public website. We redirect it to the ministry unit (/home).
  static const root = '/';
  static const home = '/home';
  static const news = '/news';
  static const newsDetail = '/news/detail';
  static const announcements = '/announcements';
  static const activities = '/activities';
  static const services = '/services';
  static const eservices = '/eservices';
  static const socialServices = '/social-services';
  static const mosques = '/mosques';
  static const projects = '/projects';
  static const about = '/about';
  static const minister = '/minister';
  static const visionMission = '/vision-mission';
  static const structure = '/structure';
  static const formerMinisters = '/former-ministers';
  static const fridaySermon = '/friday-sermon';
  static const contact = '/contact';
  static const search = '/search';
  static const notFound = '/not-found';

  /// Transition route when moving from the public website to a service system.
  /// Example: /switch/mustakshif
  static const switchSystemBase = '/switch';

  // Auth
  static const login = '/login';

  // Platform Admin
  static const adminLogin = '/admin/login';
  static const adminDashboard = '/admin/dashboard';
  static const adminWaqfLands = '/admin/waqf-lands';
  static const adminCases = '/admin/cases';
  static const adminDocuments = '/admin/documents';
  static const adminProfile = '/admin/profile';
  static const adminActivities = '/admin/activities';
  static const adminSettings = '/admin/settings';
  static const adminReports = '/admin/reports';
  static const adminHomeManagement = '/admin/home-management';
  static const adminHeroSlider = '/admin/hero-slider';
  static const adminBreakingNews = '/admin/breaking-news';
  static const adminActivitiesManagement = '/admin/activities-management';

  // Systems
  static const mustakshif = '/mustakshif';
  static const adminData = '/admin-data';
  static const lands = '/lands';
  static const properties = '/properties';
  static const cases = '/cases';
  static const tasks = '/tasks';
  static const mosquesSystem = '/mosques-system';
  static const billing = '/billing';

  // Guards
  static const forbidden = '/forbidden';

  /// GoRouter equivalent of "push and clear stack" (Navigator legacy).
  /// On GoRouter, `go()` replaces the stack.
  static void pushAndClearStack(BuildContext context, String location) {
    GoRouter.of(context).go(location);
  }

  /// GoRouter equivalent of "push replacement".
  static void pushReplacement(BuildContext context, String location) {
    // `replace` keeps the same shell but replaces the current location.
    GoRouter.of(context).replace(location);
  }
}
