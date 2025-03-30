import 'dart:async';

import 'package:flutter/material.dart';
import 'package:screenshot_recording_detector/models/detection_event.dart';
import 'package:screenshot_recording_detector/screenshot_recording_detector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenshotRecordingDetector.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<DetectionEvent> _events = [];
  bool? _isRecording;
  StreamSubscription<DetectionEvent>? _detectionSubscription;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _startListening();
    _checkRecordingStatus();
  }

  void _startListening() {
    _detectionSubscription = ScreenshotRecordingDetector.detectionStream.listen(
      _handleDetectionEvent,
      onError: (error) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      },
    );
  }

  void _handleDetectionEvent(DetectionEvent event) {
    setState(() => _events.insert(0, event));

    if (event.type == CaptureType.recording) {
      _checkRecordingStatus();
    }

    _showEventNotification(event);
  }

  Future<void> _checkRecordingStatus() async {
    final isRecording = await ScreenshotRecordingDetector.isScreenRecording;
    setState(() => _isRecording = isRecording);
  }

  void _showEventNotification(DetectionEvent event) {
    final message =
        event.type == CaptureType.screenshot
            ? '📸 Screenshot detected!'
            : '🎥 Screen recording ${event.isRecording == true ? 'started' : 'stopped'}';

    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capture Detector',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Capture Detector'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _checkRecordingStatus,
                tooltip: 'Refresh recording status',
              ),
            ],
          ),
          body: Column(children: [_buildStatusIndicator(), _buildEventList()]),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Screen Recording:', style: TextStyle(fontSize: 16)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    _isRecording == true ? Colors.red[100] : Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    _isRecording == true ? Icons.videocam : Icons.videocam_off,
                    color: _isRecording == true ? Colors.red : Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isRecording == true ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      color: _isRecording == true ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList() {
    return Expanded(
      child:
          _events.isEmpty
              ? const Center(child: Text('No capture events detected yet'))
              : ListView.builder(
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final event = _events[index];
                  return _buildEventCard(event);
                },
              ),
    );
  }

  Widget _buildEventCard(DetectionEvent event) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          event.type == CaptureType.screenshot
              ? Icons.camera_alt
              : event.isRecording == true
              ? Icons.videocam
              : Icons.videocam_off,
          color:
              event.type == CaptureType.screenshot ? Colors.blue : Colors.red,
        ),
        title: Text(
          event.type == CaptureType.screenshot
              ? 'Screenshot'
              : 'Screen Recording ${event.isRecording == true ? 'Started' : 'Stopped'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Platform: ${event.platform.toUpperCase()}'),
            Text('Time: ${event.timestamp.toLocal()}'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _detectionSubscription?.cancel();
    ScreenshotRecordingDetector.dispose();
    super.dispose();
  }
}
