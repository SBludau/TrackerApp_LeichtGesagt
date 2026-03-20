import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Speech-to-text service backed by Android's built-in speech recognition.
///
/// Uses the [speech_to_text] package which delegates to the on-device
/// recogniser (Google Speech on most Android devices).
///
/// Production replacement: swap this with a [vosk_flutter] implementation
/// before the Play Store release so the app runs fully offline.
class SttService {
  final _speech = SpeechToText();

  bool _initialised = false;
  bool _isRecording = false;

  bool get isRecording => _isRecording;
  bool get isAvailable => _initialised;

  // ─── Init ──────────────────────────────────────────────────────────────────

  /// Requests microphone permission and initialises the recogniser.
  /// Must be called once before [startRecording].
  Future<bool> initialise() async {
    if (_initialised) return true;

    final status = await Permission.microphone.request();
    if (!status.isGranted) return false;

    _initialised = await _speech.initialize(
      onError: _onError,
      onStatus: _onStatus,
      debugLogging: false,
    );
    return _initialised;
  }

  // ─── Recording ─────────────────────────────────────────────────────────────

  /// Starts listening and streams partial + final results via callbacks.
  ///
  /// [onPartial] is called on every intermediate recognition result.
  /// [onFinal]   is called with the last recognised text when the user pauses.
  /// [onError]   is called if the recogniser encounters a problem.
  Future<void> startRecording({
    required void Function(String text) onPartial,
    required void Function(String text) onFinal,
    required void Function(String message) onError,
  }) async {
    if (!_initialised) {
      final ok = await initialise();
      if (!ok) {
        onError('Mikrofon-Zugriff verweigert oder Spracherkennung nicht verfügbar.');
        return;
      }
    }

    if (_speech.isListening) {
      await _speech.stop();
    }

    _isRecording = true;

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        if (result.finalResult) {
          _isRecording = false;
          onFinal(result.recognizedWords);
        } else {
          onPartial(result.recognizedWords);
        }
      },
      localeId: 'de_DE',
      pauseFor: const Duration(seconds: 3),
      listenFor: const Duration(seconds: 60),
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        cancelOnError: false,
      ),
    );
  }

  /// Stops recording and triggers the final result callback if still listening.
  Future<void> stopRecording() async {
    _isRecording = false;
    await _speech.stop();
  }

  /// Cancels recording without producing a result.
  Future<void> cancelRecording() async {
    _isRecording = false;
    await _speech.cancel();
  }

  // ─── Internal callbacks ────────────────────────────────────────────────────

  void _onError(SpeechRecognitionError error) {
    _isRecording = false;
  }

  void _onStatus(String status) {
    if (status == 'notListening' || status == 'done') {
      _isRecording = false;
    }
  }
}
