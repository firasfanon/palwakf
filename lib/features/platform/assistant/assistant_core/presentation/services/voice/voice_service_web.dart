// Web implementation kept analyzer-safe for the current Flutter/Dart toolchain.
//
// Mega Batch E note:
// The previous implementation used legacy JS utility APIs that are not
// available in the installed dependency set and caused analyzer errors. Until
// the assistant voice module is migrated to package:web + dart:js_interop, the
// web voice service degrades safely to a no-op implementation. This preserves
// chat/assistant runtime stability and avoids breaking platform navigation.

import 'voice_service.dart';

class _VoiceServiceWeb implements VoiceService {
  bool _isListening = false;
  bool _isSpeaking = false;

  @override
  bool get isSpeechRecognitionSupported => false;

  @override
  bool get isTextToSpeechSupported => false;

  @override
  bool get isListening => _isListening;

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Future<void> startListening({
    required String languageTag,
    void Function(String partialText)? onPartial,
    void Function(String finalText)? onFinal,
    void Function(Object error)? onError,
  }) async {
    _isListening = false;
    onError?.call(
      StateError(
        'Voice recognition is temporarily disabled pending web JS interop migration.',
      ),
    );
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
  }

  @override
  Future<void> speak({
    required String text,
    required String languageTag,
  }) async {
    _isSpeaking = false;
  }

  @override
  Future<void> stopSpeaking() async {
    _isSpeaking = false;
  }
}

VoiceService createVoiceServiceImpl() => _VoiceServiceWeb();
