import '../widgets/pwf_picked_file.dart';

Future<List<PwfPickedFile>> pwfPickFiles({required bool multiple}) async {
  // Mobile/Desktop native pickers require a package; blocked by project rules.
  return const <PwfPickedFile>[];
}
