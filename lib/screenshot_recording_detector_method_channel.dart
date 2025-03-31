import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'screenshot_recording_detector_platform_interface.dart';

/// The method channel implementation of [ScreenshotRecordingDetectorPlatform].
class MethodChannelScreenshotRecordingDetector
    extends ScreenshotRecordingDetectorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('screenshot_recording_detector');

  /// The event channel used to receive detection events from the native platform.
  @visibleForTesting
  final eventChannel = const EventChannel('screenshot_recording_events');

  @override
  Future<void> initialize() async {
    await methodChannel.invokeMethod('initialize');
  }

  @override
  Stream<Map<dynamic, dynamic>> get detectionStream {
    return eventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return event.cast<dynamic, dynamic>();
      }
      return <dynamic, dynamic>{};
    });
  }

  @override
  Future<bool> get isScreenRecording async {
    final result = await methodChannel.invokeMethod<bool>('isScreenRecording');
    return result ?? false;
  }

  @override
  Future<void> setBlockScreenshots(bool block) async {
    await methodChannel.invokeMethod('setBlockScreenshots', block);
  }

  @override
  Future<void> dispose() async {
    await methodChannel.invokeMethod('dispose');
  }
}
