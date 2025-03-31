enum CaptureType { screenshot, recording, none }

class DetectionEvent {
  final CaptureType type;
  final DateTime? timestamp;
  final bool? isRecording;
  final String platform;

  DetectionEvent({
    required this.type,
    required this.timestamp,
    this.isRecording,
    required this.platform,
  });

  factory DetectionEvent.fromMap(Map<dynamic, dynamic> map) {
    return DetectionEvent(
      type: map['type'] == 'screenshot'
          ? CaptureType.screenshot
          : (map['type'] == 'recording')
              ? CaptureType.recording
              : CaptureType.none,
      timestamp: (map['timestamp'] != null)
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          : null,
      isRecording: map['isRecording'],
      platform: map['platform'] ?? 'unknown',
    );
  }

  @override
  String toString() {
    return 'DetectionEvent(type: $type, timestamp: $timestamp, isRecording: $isRecording, platform: $platform)';
  }
}
