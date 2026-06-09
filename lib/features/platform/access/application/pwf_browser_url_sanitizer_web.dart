// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

void replaceBrowserUrlWithHashRoute(String route) {
  final normalizedRoute = route.startsWith('/') ? route : '/$route';
  final cleanUrl = '${html.window.location.origin}/#$normalizedRoute';
  html.window.history.replaceState(null, html.document.title, cleanUrl);
}
