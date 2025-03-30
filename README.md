# Screenshot & Recording Detector

[![pub package](https://img.shields.io/pub/v/screenshot_recording_detector.svg)](https://pub.dev/packages/screenshot_recording_detector)
![License](https://img.shields.io/github/license/academix-admin/screenshot_recording_detector)

A Flutter plugin to detect screenshots and screen recordings on Android/iOS with content protection features.

## Features

✔️ Detect screenshots in real-time  
✔️ Detect screen recording status
✔️ Cross-platform support (Android/iOS)

## Installation

Add to your `pubspec.yaml`:
```yaml
dependencies:
  screenshot_recording_detector: ^1.0.0
```

## Usage

### Basic Detection
```dart
import 'package:screenshot_recording_detector/screenshot_recording_detector.dart';

// Initialize
await ScreenshotRecordingDetector.initialize();

// Listen for events
ScreenshotRecordingDetector.detectionStream.listen((event) {
  if (event.type == 'screenshot') {
    print('Screenshot detected!');
  } else if (event.isRecording) {
    print('Screen recording started');
  }
});

// Check current status
bool isRecording = await ScreenshotRecordingDetector.isScreenRecording;
```

### Content Protection
```dart
// Blur content when recording (Android/iOS)
Stack(
  children: [
    YourSensitiveContent(),
    if(_isRecording) // Set this via stream listener
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(color: Colors.black.withOpacity(0.3)),
      ),
  ],
)

// Block screenshots entirely (Android only)
await ScreenshotRecordingDetector.setBlockScreenshots(true);
```

## Platform Setup

### Android
Add this to your `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS
Add this to your `Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Need access to detect screenshots</string>
```

## Limitations
- iOS screenshot detection has a slight delay
- Screen recording detection may not work with all apps
- Physical cameras can still capture content

## Contributing
Pull requests are welcome! See the [GitHub repo](https://github.com/academix-admin/screenshot_recording_detector).

## License
MIT - See [LICENSE](LICENSE) for details.