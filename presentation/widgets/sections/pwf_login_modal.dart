import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:waqf/app/routing/app_routes.dart';

import '../../providers/pwf_ui_prefs_provider.dart';
import '../../theme/pwf_home_palette.dart';
import '../../theme/pwf_theme_tokens.dart';
import '../shared/pwf_outlined_button.dart';
import '../shared/pwf_primary_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Login modal in the new HTML identity.
///
/// Note: This widget itself renders nothing; use [show] to open the dialog.
class PwfLoginModal extends StatelessWidget {
  const PwfLoginModal({super.key});

  /// Open the modal (HTML-like overlay).
  static Future<void> show(BuildContext context) async {
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'login',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, a1, a2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Consumer(
              builder: (context, ref, _) {
                final themeKey = ref.watch(
                  pwfUiPrefsProvider.select((s) => s.themeKey),
                );
                final t = PwfThemeTokens.forKey(themeKey);

                return Container(
                  width: 420,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: t.cardBg,
                    borderRadius: PwfHomeRadii.br16,
                    border: Border.all(color: t.cardBorder),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 24,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                            color: t.onSurface,
                            tooltip: 'إغلاق',
                          ),
                        ],
                      ),
                      Text(
                        'تسجيل دخول الموظفين',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: t.onSurface,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _field(
                        controller: userCtrl,
                        label: 'اسم المستخدم',
                        isPassword: false,
                        tokens: t,
                      ),
                      const SizedBox(height: 14),
                      _field(
                        controller: passCtrl,
                        label: 'كلمة المرور',
                        isPassword: true,
                        tokens: t,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: PwfPrimaryButton(
                          label: 'تسجيل الدخول',
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.go(AppRoutes.adminLogin);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: PwfOutlinedButton(
                          label: 'إغلاق',
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
      transitionBuilder: (context, anim, secondary, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.96,
              end: 1,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
    );
  }

  static Widget _field({
    required TextEditingController controller,
    required String label,
    required bool isPassword,
    required PwfThemeTokensData tokens,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: tokens.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.cairo(fontSize: 13, color: tokens.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: tokens.inputBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: PwfHomeRadii.br10,
              borderSide: BorderSide(color: tokens.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: PwfHomeRadii.br10,
              borderSide: BorderSide(color: tokens.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: PwfHomeRadii.br10,
              borderSide: BorderSide(color: tokens.primary, width: 1.2),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: FaIcon(
                isPassword ? FontAwesomeIcons.lock : FontAwesomeIcons.user,
                size: 14,
                color: tokens.muted,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // This widget is triggered via [show].
    return const SizedBox.shrink();
  }
}
