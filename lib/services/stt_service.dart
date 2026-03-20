import 'dart:async';

/// Stub speech-to-text service.
///
/// In a production build this would integrate with Vosk or a similar
/// offline STT engine. For development / emulator use it simulates a
/// recording session: after [_recordingDuration] it resolves with a
/// hard-coded transcript.
class SttService {
  static const _recordingDuration = Duration(seconds: 3);

  bool _isRecording = false;
  Completer<String>? _completer;
  Timer? _timer;

  bool get isRecording => _isRecording;

  /// Begins a simulated recording session.
  /// Call [stopRecording] to finalise early, or wait for the auto-stop.
  Future<String> startRecording() {
    if (_isRecording) {
      stopRecording();
    }

    _isRecording = true;
    _completer = Completer<String>();

    _timer = Timer(_recordingDuration, () {
      _finishRecording();
    });

    return _completer!.future;
  }

  /// Stops recording and returns the transcript (even if called early).
  void stopRecording() {
    _timer?.cancel();
    _timer = null;
    _finishRecording();
  }

  void _finishRecording() {
    if (!_isRecording) return;
    _isRecording = false;
    _completer?.complete(_mockTranscript);
    _completer = null;
  }

  /// Cancels the current recording without producing a result.
  void cancelRecording() {
    _timer?.cancel();
    _timer = null;
    _isRecording = false;
    _completer?.completeError('cancelled');
    _completer = null;
  }

  static const _mockTranscript =
      'Heute war der Stress so bei einer 7, '
      'Energie war okay vielleicht 6, '
      'hab gut geschlafen würde sagen 8. '
      'Hatte heute Morgen Kaffee und dann Sport gemacht.';
}
