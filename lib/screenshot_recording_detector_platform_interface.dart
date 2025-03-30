import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:screenshot_recording_detector/screenshot_recording_detector_method_channel.dart';

/// The interface that implementations of screenshot_recording_detector must implement.
///
/// Platform implementations should extend this class rather than implement it
/// directly to maintain backwards compatibility.
abstract class ScreenshotRecordingDetectorPlatform extends PlatformInterface {
  /// Constructs a ScreenshotRecordingDetectorPlatform.
  ScreenshotRecordingDetectorPlatform() : super(token: _token);

  static final Object _token = Object();
  static ScreenshotRecordingDetectorPlatform _instance =
      MethodChannelScreenshotRecordingDetector();

  /// The default instance of [ScreenshotRecordingDetectorPlatform].
  static ScreenshotRecordingDetectorPlatform get instance => _instance;

  /// Sets the platform instance.
  static set instance(ScreenshotRecordingDetectorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initializes the platform-specific detection implementation.
  Future<void> initialize() {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Returns a stream of platform events converted to maps.
  Stream<Map<String, dynamic>> get detectionStream {
    throw UnimplementedError('detectionStream has not been implemented.');
  }

  /// Checks if screen recording is currently active.
  Future<bool> get isScreenRecording {
    throw UnimplementedError('isScreenRecording has not been implemented.');
  }

  /// Set Screenshots ability
  Future<void> setBlockScreenshots(bool block) {
    throw UnimplementedError('setBlockScreenshots has not been implemented.');
  }

  /// Cleans up platform resources.
  Future<void> dispose() {
    throw UnimplementedError('dispose() has not been implemented.');
  }
}
