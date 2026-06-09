import 'voice_service_stub.dart'
    if (dart.library.html) 'voice_service_web.dart';

/// Lightweight voice I/O abstraction for PalWakf chat experiences.
///
/// - On Web: uses the browser Web Speech APIs (SpeechRecognition + SpeechSynthesis).
/// - On other platforms: no-op stub (keeps builds safe).
abstract class VoiceService {
  bool get isSpeechRecognitionSupported;
  bool get isTextToSpeechSupported;

  bool get isListening;
  bool get isSpeaking;

  /// Starts speech-to-text.
  ///
  /// [onPartial] may be called many times.
  /// [onFinal] is called once on the final transcript.
  Future<void> startListening({
    required String languageTag,
    void Function(String partialText)? onPartial,
    void Function(String finalText)? onFinal,
    void Function(Object error)? onError,
  });

  Future<void> stopListening();

  /// Speaks the given [text]. If already speaking, cancels then speaks.
  Future<void> speak({required String text, required String languageTag});

  Future<void> stopSpeaking();
}

/// Factory exposed to the rest of the app.
VoiceService createVoiceService() => createVoiceServiceImpl();
