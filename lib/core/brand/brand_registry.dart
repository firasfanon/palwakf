import 'package:flutter/material.dart';
import '../enums/enums.dart';
import 'brand_spec.dart';

/// Central palette: Blue/Gold + Royal Red
class BrandRegistry {
  static const Color _platformBlue = Color(0xFF0D47A1);
  static const Color _platformGold = Color(0xFFD4AF37);
  static const Color _royalRed = Color(0xFFB22222);

  static const BrandSpec platform = BrandSpec(
    name: 'PalWakf',
    primary: _platformBlue,
    secondary: _platformGold,
    accent: _royalRed,
    brightness: Brightness.light,
  );

  static const Map<SystemKey, BrandSpec> systems = {
    SystemKey.site: platform,
    SystemKey.platformAdmin: BrandSpec(
      name: 'Platform Admin',
      primary: Color(0xFF1B5E20),
      secondary: _platformGold,
      accent: _royalRed,
    ),
    SystemKey.mustakshif: BrandSpec(
      name: 'Mustakshif',
      primary: Color(0xFF1565C0),
      secondary: Color(0xFF00ACC1),
      accent: _royalRed,
    ),
    SystemKey.adminData: BrandSpec(
      name: 'Admin Data',
      primary: Color(0xFF4E342E),
      secondary: _platformGold,
      accent: _royalRed,
    ),
    SystemKey.lands: BrandSpec(
      name: 'Lands',
      primary: Color(0xFF2E7D32),
      secondary: _platformGold,
      accent: _royalRed,
    ),
    SystemKey.properties: BrandSpec(
      name: 'Properties',
      primary: Color(0xFF6A1B9A),
      secondary: _platformGold,
      accent: _royalRed,
    ),
    SystemKey.cases: BrandSpec(
      name: 'Cases',
      primary: Color(0xFF5D4037),
      secondary: _platformGold,
      accent: _royalRed,
    ),
    SystemKey.tasks: BrandSpec(
      name: 'Tasks',
      primary: Color(0xFF0277BD),
      secondary: _platformGold,
      accent: _royalRed,
    ),
    SystemKey.mosques: BrandSpec(
      name: 'Mosques',
      primary: Color(0xFF0F766E),
      secondary: _platformGold,
      accent: _royalRed,
    ),
    SystemKey.billing: BrandSpec(
      name: 'Billing',
      primary: Color(0xFF37474F),
      secondary: _platformGold,
      accent: _royalRed,
    ),
  };

  static BrandSpec of(SystemKey key) => systems[key] ?? platform;
}
