import 'package:flutter/material.dart';
import 'palwakf_sis_colors.dart';

extension PalWakfSisColorsX on BuildContext {
  PalWakfSisColors get sisColors =>
      Theme.of(this).extension<PalWakfSisColors>() ?? PalWakfSisColors.light;
}
