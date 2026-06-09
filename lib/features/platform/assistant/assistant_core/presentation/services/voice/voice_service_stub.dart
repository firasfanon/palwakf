import 'voice_service.dart';

class _VoiceServiceStub implements VoiceService {
  @override
  bool get isSpeechRecognitionSupported => false;

  @override
  bool get isTextToSpeechSupported => false;

  @override
  bool get isListening => false;

  @override
  bool get isSpeaking => false;

  @override
  Future<void> startListening({
    required String languageTag,
    void Function(String partialText)? onPartial,
    void Function(String finalText)? onFinal,
    void Function(Object error)? onError,
  }) async {
    onError?.call(StateError('Voice is not supported on this platform.'));
  }

  @override
  Future<void> stopListening() async {}

  @override
  Future<void> speak({
    required String text,
    required String languageTag,
  }) async {}

  @override
  Future<void> stopSpeaking() async {}
}

VoiceService createVoiceServiceImpl() => _VoiceServiceStub();
