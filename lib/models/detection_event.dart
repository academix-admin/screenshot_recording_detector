enum CaptureType { screenshot, recording }

class DetectionEvent {
  final CaptureType type;
  final DateTime timestamp;
  final bool? isRecording;
  final String platform;

  DetectionEvent({
    required this.type,
    required this.timestamp,
    this.isRecording,
    required this.platform,
  });

  factory DetectionEvent.fromMap(Map<String, dynamic> map) {
    return DetectionEvent(
      type:
          map['type'] == 'screenshot'
              ? CaptureType.screenshot
              : CaptureType.recording,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isRecording: map['isRecording'],
      platform: map['platform'] ?? 'unknown',
    );
  }

  @override
  String toString() {
    return 'DetectionEvent(type: $type, timestamp: $timestamp, isRecording: $isRecording, platform: $platform)';
  }
}
