import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:screenshot_recording_detector/screenshot_recording_detector.dart';

import 'mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockScreenshotRecordingDetectorPlatform mockPlatform;

  setUp(() {
    mockPlatform = MockScreenshotRecordingDetectorPlatform();

    // Stub all methods that will be called
    when(() => mockPlatform.initialize()).thenAnswer((_) async {});
    when(() => mockPlatform.isScreenRecording).thenAnswer((_) async => false);
    when(
      () => mockPlatform.setBlockScreenshots(any()),
    ).thenAnswer((_) async {});
    when(() => mockPlatform.dispose()).thenAnswer((_) async {});
    when(
      () => mockPlatform.detectionStream,
    ).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    mockPlatform.disposeMock();
  });

  group('ScreenshotRecordingDetector', () {
    test('initialize delegates to platform', () async {
      await ScreenshotRecordingDetector.initialize();
      verify(() => mockPlatform.initialize()).called(1);
    });

    test('isScreenRecording delegates to platform', () async {
      when(() => mockPlatform.isScreenRecording).thenAnswer((_) async => true);
      expect(await ScreenshotRecordingDetector.isScreenRecording, isTrue);
      verify(() => mockPlatform.isScreenRecording).called(1);
    });

    test('setBlockScreenshots delegates to platform', () async {
      await ScreenshotRecordingDetector.setBlockScreenshots(true);
      verify(() => mockPlatform.setBlockScreenshots(true)).called(1);
    });

    test('dispose delegates to platform', () async {
      await ScreenshotRecordingDetector.dispose();
      verify(() => mockPlatform.dispose()).called(1);
    });

    group('detectionStream', () {
      test('converts platform events to DetectionEvent', () async {
        final testEvent = {
          'type': 'screenshot',
          'timestamp': 1234567890,
          'platform': 'android',
        };

        when(
          () => mockPlatform.detectionStream,
        ).thenAnswer((_) => Stream.value(testEvent));

        expect(
          ScreenshotRecordingDetector.detectionStream,
          emitsThrough(isA<Map<String, dynamic>>()),
        );
      });

      test('handles error events', () async {
        when(
          () => mockPlatform.detectionStream,
        ).thenAnswer((_) => Stream.error(Exception('Test error')));

        expect(
          ScreenshotRecordingDetector.detectionStream,
          emitsError(isA<Exception>()),
        );
      });
    });

    group('error handling', () {
      test('initialize propagates platform exceptions', () async {
        when(
          () => mockPlatform.initialize(),
        ).thenThrow(Exception('Initialization failed'));
        expect(
          ScreenshotRecordingDetector.initialize(),
          throwsA(isA<Exception>()),
        );
      });

      test('isScreenRecording returns false on error', () async {
        when(
          () => mockPlatform.isScreenRecording,
        ).thenThrow(Exception('Detection failed'));
        expect(await ScreenshotRecordingDetector.isScreenRecording, isFalse);
      });
    });
  });
}
