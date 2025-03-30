import Flutter
import UIKit
import ReplayKit

public class ScreenshotRecordingDetectorPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var isMonitoring = false
    private var timer: Timer?
    private var wasRecording = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = ScreenshotRecordingDetectorPlugin()

        let methodChannel = FlutterMethodChannel(
            name: "screenshot_recording_detector",
            binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(instance, channel: methodChannel)

        let eventChannel = FlutterEventChannel(
            name: "screenshot_recording_events",
            binaryMessenger: registrar.messenger()
        )
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            startMonitoring()
            result(nil)
        case "isScreenRecording":
            result(isScreenRecording())
        case "dispose":
            stopMonitoring()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startMonitoring() {
        if isMonitoring { return }
        isMonitoring = true

        // Screenshot detection
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didTakeScreenshot),
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil
        )

        // Screen recording detection
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(checkScreenRecording),
            userInfo: nil,
            repeats: true
        )
    }

    private func stopMonitoring() {
        isMonitoring = false
        NotificationCenter.default.removeObserver(self)
        timer?.invalidate()
        timer = nil
    }

    @objc private func didTakeScreenshot() {
        DispatchQueue.main.async { [weak self] in
            self?.eventSink?([
                "type": "screenshot",
                "timestamp": Int64(Date().timeIntervalSince1970 * 1000),
                "platform": "ios"
            ])
        }
    }

    @objc private func checkScreenRecording() {
        let isRecording = isScreenRecording()
        if isRecording != wasRecording {
            DispatchQueue.main.async { [weak self] in
                self?.eventSink?([
                    "type": "recording",
                    "timestamp": Int64(Date().timeIntervalSince1970 * 1000),
                    "platform": "ios",
                    "isRecording": isRecording
                ])
            }
            wasRecording = isRecording
        }
    }

    @available(iOS 11.0, *)
    private func isScreenRecording() -> Bool {
        return UIScreen.main.isCaptured
    }

    // FlutterStreamHandler
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}