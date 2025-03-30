import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot_recording_detector/screenshot_recording_detector_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('screenshot_recording_detector');
  const eventChannel = EventChannel('screenshot_recording_events');

  late MethodChannelScreenshotRecordingDetector plugin;
  final log = <MethodCall>[];

  setUp(() {
    plugin = MethodChannelScreenshotRecordingDetector();
    log.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'initialize':
              return null;
            case 'isScreenRecording':
              return true;
            case 'setBlockScreenshots':
              return null;
            case 'dispose':
              return null;
            default:
              throw MissingPluginException();
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('EventChannel receives events', () async {
    const event = {
      'type': 'screenshot',
      'timestamp': 1234567890,
      'platform': 'android',
    };

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(eventChannel.name, (ByteData? message) async {
          return const StandardMethodCodec().encodeSuccessEnvelope(event);
        });

    expect(
      plugin.detectionStream,
      emitsInOrder([
        isA<Map<String, dynamic>>()
            .having((m) => m['type'], 'type', 'screenshot')
            .having((m) => m['platform'], 'platform', 'android'),
        emitsDone,
      ]),
    );
  });

  test('EventChannel handles errors', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(eventChannel.name, (ByteData? message) async {
          return const StandardMethodCodec().encodeErrorEnvelope(
            code: 'TEST_ERROR',
            message: 'Test error',
            details: null,
          );
        });

    expect(
      plugin.detectionStream,
      emitsError(
        isA<PlatformException>()
            .having((e) => e.code, 'code', 'TEST_ERROR')
            .having((e) => e.message, 'message', 'Test error'),
      ),
    );
  });
}
