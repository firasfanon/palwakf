import '../widgets/pwf_picked_file.dart';
import 'pwf_file_picker_stub.dart'
    if (dart.library.html) 'pwf_file_picker_web.dart';

class PwfFilePicker {
  static Future<List<PwfPickedFile>> pickFiles({bool multiple = true}) {
    return pwfPickFiles(multiple: multiple);
  }
}
