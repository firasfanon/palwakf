// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

abstract class PwfWebHomeHtmlScreenBase extends StatefulWidget {
  final String unitSlug;
  final String? unitTitle;

  const PwfWebHomeHtmlScreenBase({
    super.key,
    this.unitSlug = 'home',
    this.unitTitle,
  });

  @override
  State<PwfWebHomeHtmlScreenBase> createState() =>
      _PwfWebHomeHtmlScreenBaseState();
}

class _PwfWebHomeHtmlScreenBaseState extends State<PwfWebHomeHtmlScreenBase> {
  late final String _viewType;
  static final Set<String> _registered = <String>{};

  @override
  void initState() {
    super.initState();
    // Unique per unitSlug to avoid view factory collisions across routes.
    _viewType = 'pwf-home-html-${widget.unitSlug}';
    _registerIfNeeded();
  }

  void _registerIfNeeded() {
    if (_registered.contains(_viewType)) return;
    _registered.add(_viewType);

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.display = 'block'
        ..allowFullscreen = true;

      final lang = html.window.localStorage['pwf_lang'] ?? 'ar';
      final theme = html.window.localStorage['pwf_theme'] ?? 'islamic';

      // Flutter web serves assets under /assets/ + relative path.
      // If the asset is at assets/web/palwafkplatform.html, the served URL becomes:
      //   assets/assets/web/palwafkplatform.html
      final src =
          'assets/assets/web/palwafkplatform.html'
          '?unit=${Uri.encodeComponent(widget.unitSlug)}'
          '&lang=${Uri.encodeComponent(lang)}'
          '&theme=${Uri.encodeComponent(theme)}';

      iframe.src = src;
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No app bar: the HTML file already contains its own top/header/nav.
      body: SizedBox.expand(child: HtmlElementView(viewType: _viewType)),
    );
  }
}
