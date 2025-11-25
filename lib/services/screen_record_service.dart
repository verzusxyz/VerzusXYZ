import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RecordingState {
  idle,
  recording,
  processing,
}

final recordingStateProvider =
    StateProvider<RecordingState>((ref) => RecordingState.idle);

/// A service to manage the screen recording lifecycle.
///
/// **NOTE:** This is a functional simulation. In a real build environment,
/// this service would be implemented with platform-specific native code.
/// - **Android:** MediaProjection API
/// - **iOS:** ReplayKit
/// - **Web:** navigator.mediaDevices.getDisplayMedia()
/// - **Desktop:** FFI bridge to native APIs (e.g., desktop_capture)
class ScreenRecordService {
  final Ref _ref;
  ScreenRecordService(this._ref);

  /// Starts the screen recording process.
  ///
  /// This method will change the recording state to `recording` and then
  /// simulate a 10-second recording session.
  Future<void> startRecording() async {
    _ref.read(recordingStateProvider.notifier).state = RecordingState.recording;
    // Simulate a 10-second recording session
    await Future.delayed(const Duration(seconds: 10));
    stopRecording();
  }

  /// Stops the screen recording process.
  ///
  /// This method will change the recording state to `processing`, simulate
  /// a 2-second processing time, and then return the state to `idle`.
  Future<void> stopRecording() async {
    _ref.read(recordingStateProvider.notifier).state = RecordingState.processing;
    // Simulate a 2-second processing time
    await Future.delayed(const Duration(seconds: 2));
    _ref.read(recordingStateProvider.notifier).state = RecordingState.idle;
  }
}

final screenRecordServiceProvider = Provider((ref) => ScreenRecordService(ref));
