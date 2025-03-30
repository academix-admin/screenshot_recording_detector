import 'dart:async';

import 'package:flutter/services.dart';

import 'models/detection_event.dart';
import 'screenshot_recording_detector_platform_interface.dart';

/// A plugin for detecting screenshots and screen recordings on Android and iOS.
///
/// ## Features
/// - Detect when a screenshot is taken
/// - Detect when screen recording starts/stops
/// - Check current screen recording status
/// - Cross-platform support (Android/iOS)
///
/// ## Usage
/// ```dart
/// // Initialize the detector
/// await ScreenshotRecordingDetector.initialize();
///
/// // Listen for events
/// ScreenshotRecordingDetector.detectionStream.listen((event) {
///   print('Capture event detected: $event');
/// });
///
/// // Check recording status
/// bool isRecording = await ScreenshotRecordingDetector.isScreenRecording;
/// ```
class ScreenshotRecordingDetector {
  static final _platform = ScreenshotRecordingDetectorPlatform.instance;

  /// Initializes the detector and starts listening for events.
  ///
  /// Must be called before accessing [detectionStream] or [isScreenRecording].
  ///
  /// Throws a [PlatformException] if initialization fails.
  static Future<void> initialize() async {
    try {
      await _platform.initialize();
    } on PlatformException catch (e) {
      throw Exception('Failed to initialize detector: ${e.message}');
    }
  }

  /// A stream of [DetectionEvent]s when screenshots are taken or
  /// screen recording state changes.
  ///
  /// Events include:
  /// - [CaptureType.screenshot] when a screenshot is detected
  /// - [CaptureType.screenRecording] with [RecordingState] when recording starts/stops
  ///
  /// Requires calling [initialize()] first.
  static Stream<DetectionEvent> get detectionStream {
    return _platform.detectionStream.map(DetectionEvent.fromMap);
  }

  /// Checks if the screen is currently being recorded.
  ///
  /// Returns `true` if screen recording is active, `false` otherwise.
  ///
  /// Note: On iOS, this may have a slight delay due to platform limitations.
  static Future<bool> get isScreenRecording async {
    try {
      return await _platform.isScreenRecording;
    } on PlatformException {
      return false;
    }
  }

  ///Set To block Screenshots
  ///-- ONLY ON ANDROID
  static Future<void> setBlockScreenshots(bool block) async {
    await _platform.setBlockScreenshots(block);
  }

  /// Stops listening for events and releases resources.
  ///
  /// Call this when detection is no longer needed to save resources.
  static Future<void> dispose() async {
    await _platform.dispose();
  }
}
