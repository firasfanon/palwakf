import 'package:flutter/widgets.dart';

enum PalWakfSisDeviceClass { mobile, tablet, laptop, desktop }

class PalWakfSisBreakpoints {
  const PalWakfSisBreakpoints._();

  static PalWakfSisDeviceClass of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 640) return PalWakfSisDeviceClass.mobile;
    if (width < 1024) return PalWakfSisDeviceClass.tablet;
    if (width < 1280) return PalWakfSisDeviceClass.laptop;
    return PalWakfSisDeviceClass.desktop;
  }
}
