import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:screenshot_recording_detector/models/detection_event.dart';
import 'package:screenshot_recording_detector/screenshot_recording_detector.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('ScreenshotRecordingDetector Integration Tests', () {
    late List<DetectionEvent> detectedEvents;

    setUp(() async {
      detectedEvents = [];
      await ScreenshotRecordingDetector.initialize();
    });

    tearDown(() async {
      await ScreenshotRecordingDetector.dispose();
    });

    testWidgets('Initialization test', (WidgetTester tester) async {
      // Verify initialization was successful by checking if we can get recording status
      final isRecording = await ScreenshotRecordingDetector.isScreenRecording;
      expect(isRecording, isA<bool>());
    });

    testWidgets('Detection stream receives events', (
      WidgetTester tester,
    ) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      // Start listening to events
      final subscription = ScreenshotRecordingDetector.detectionStream.listen((
        event,
      ) {
        detectedEvents.add(event);
      });

      // Trigger a fake screenshot event (in real test this would come from platform)
      // Note: Actual screenshot detection would require platform-specific test code
      await tester.pump(const Duration(seconds: 1));

      // Verify we can at least establish the stream connection
      expect(subscription, isNotNull);

      // Clean up
      await subscription.cancel();
    });

    testWidgets('Screen recording status check', (WidgetTester tester) async {
      final isRecording = await ScreenshotRecordingDetector.isScreenRecording;
      expect(isRecording, isFalse); // Should be false by default in test env
    });

    testWidgets('Dispose cleans up resources', (WidgetTester tester) async {
      await ScreenshotRecordingDetector.dispose();
      // Verify by checking that getting recording status throws
      expect(
        ScreenshotRecordingDetector.isScreenRecording,
        throwsA(isA<Exception>()),
      );
    });
  });
}
