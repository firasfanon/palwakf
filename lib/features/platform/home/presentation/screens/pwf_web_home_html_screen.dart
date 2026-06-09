import 'pwf_web_home_html_screen_stub.dart'
    if (dart.library.html) 'pwf_web_home_html_screen_web.dart';

/// Web-only: renders the new HTML homepage (pixel-identical) inside an iframe.
///
/// NOTE: This keeps the original HTML visual identity (colors/fonts/effects) intact.
/// On non-web platforms it falls back to an empty placeholder.
class PwfWebHomeHtmlScreen extends PwfWebHomeHtmlScreenBase {
  const PwfWebHomeHtmlScreen({super.key, super.unitSlug, super.unitTitle});
}
