import 'package:flutter_riverpod/flutter_riverpod.dart';

final developerShowRoutesProvider = StateProvider<bool>((ref) => false);
final developerShowPageNamesProvider = StateProvider<bool>((ref) => false);

final adminSidebarCollapsedProvider = StateProvider<bool>((ref) => false);
