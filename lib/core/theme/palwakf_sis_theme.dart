import 'package:flutter/material.dart';

import 'palwakf_sis_colors.dart';

class PalWakfSisTheme {
  const PalWakfSisTheme._();

  static ThemeData light() {
    const sis = PalWakfSisColors.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: sis.sovereignBlue,
      primary: sis.sovereignBlue,
      secondary: sis.waqfGold,
      error: sis.royalRed,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: sis.surfacePaper,
      extensions: const [PalWakfSisColors.light],
    );
  }

  static ThemeData dark() {
    const sis = PalWakfSisColors.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: sis.sovereignBlue,
      primary: sis.sovereignBlue,
      secondary: sis.waqfGold,
      error: sis.royalRed,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: sis.surfacePaper,
      extensions: const [PalWakfSisColors.dark],
    );
  }
}
