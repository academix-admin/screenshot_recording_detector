import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:screenshot_recording_detector/screenshot_recording_detector_platform_interface.dart';

class MockScreenshotRecordingDetectorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements ScreenshotRecordingDetectorPlatform {
  factory MockScreenshotRecordingDetectorPlatform() {
    final mock = MockScreenshotRecordingDetectorPlatform._();
    ScreenshotRecordingDetectorPlatform.instance = mock;
    return mock;
  }

  MockScreenshotRecordingDetectorPlatform._();

  final StreamController<Map<String, dynamic>> _streamController =
      StreamController<Map<String, dynamic>>.broadcast();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> get isScreenRecording async => false;

  @override
  Future<void> setBlockScreenshots(bool block) async {}

  @override
  Future<void> dispose() async {}

  @override
  Stream<Map<String, dynamic>> get detectionStream => _streamController.stream;

  void emitTestEvent(Map<String, dynamic> event) {
    _streamController.add(event);
  }

  void emitError(Exception error) {
    _streamController.addError(error);
  }

  void disposeMock() {
    _streamController.close();
  }
}
