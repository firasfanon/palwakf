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

extension PalWakfSisBreakpointsX on BuildContext {
  PalWakfSisDeviceClass get deviceClass => PalWakfSisBreakpoints.of(this);
  bool get isMobile => deviceClass == PalWakfSisDeviceClass.mobile;
  bool get isTablet => deviceClass == PalWakfSisDeviceClass.tablet;
  bool get isDesktop => deviceClass == PalWakfSisDeviceClass.desktop || deviceClass == PalWakfSisDeviceClass.laptop;

  double get responsivePadding {
    switch (deviceClass) {
      case PalWakfSisDeviceClass.mobile:
        return 16;
      case PalWakfSisDeviceClass.tablet:
        return 24;
      case PalWakfSisDeviceClass.laptop:
      case PalWakfSisDeviceClass.desktop:
        return 32;
    }
  }

  double get responsiveGutter {
    switch (deviceClass) {
      case PalWakfSisDeviceClass.mobile:
        return 12;
      case PalWakfSisDeviceClass.tablet:
        return 16;
      case PalWakfSisDeviceClass.laptop:
      case PalWakfSisDeviceClass.desktop:
        return 20;
    }
  }

  int responsiveColumns({int mobile = 1, int tablet = 2, int desktop = 3}) {
    switch (deviceClass) {
      case PalWakfSisDeviceClass.mobile:
        return mobile;
      case PalWakfSisDeviceClass.tablet:
        return tablet;
      case PalWakfSisDeviceClass.laptop:
      case PalWakfSisDeviceClass.desktop:
        return desktop;
    }
  }
}
