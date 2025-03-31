package com.screenshot.recording.detector.screenshot_recording_detector

import android.annotation.SuppressLint
import android.app.Activity
import android.content.ContentResolver
import android.content.Context
import android.database.ContentObserver
import android.hardware.display.DisplayManager
import android.media.projection.MediaProjectionManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.provider.Settings
import android.view.Display
import android.view.WindowManager
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.content.Intent
import android.os.PowerManager

class ScreenshotRecordingDetectorPlugin : FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var eventChannel: EventChannel
  private var eventSink: EventChannel.EventSink? = null
  private var context: Context? = null
  private var contentObserver: ContentObserver? = null
  private var handler: Handler? = null
  private var lastEventTime: Long = 0
  private val DEBOUNCE_TIME_MS = 500L

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "screenshot_recording_detector")
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "screenshot_recording_events")
    channel.setMethodCallHandler(this)
    eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
      }

      override fun onCancel(arguments: Any?) {
        eventSink = null
      }
    })
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "initialize" -> {
        startMonitoring()
//        checkBatteryOptimization()
        result.success(null)
      }
      "isScreenRecording" -> {
        result.success(isScreenRecording())
      }
      "setBlockScreenshots" -> {
        setSecureFlag(call.arguments as Boolean)
        result.success(null)
      }
      "dispose" -> {
        stopMonitoring()
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }

  private fun setSecureFlag(enable: Boolean) {
    (context as? Activity)?.window?.let { window ->
      if (enable) {
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
      } else {
        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
      }
    }
  }

  private fun startMonitoring() {
    handler = Handler(Looper.getMainLooper())
    contentObserver = object : ContentObserver(handler) {
      override fun onChange(selfChange: Boolean, uri: Uri?) {
        val currentTime = System.currentTimeMillis()
        if (currentTime - lastEventTime < DEBOUNCE_TIME_MS) return

        lastEventTime = currentTime
        if (isScreenshot(uri)) {
          eventSink?.success(mapOf(
            "type" to "screenshot",
            "timestamp" to currentTime,
            "platform" to "android"
          ))
        }
      }
    }

    context?.contentResolver?.registerContentObserver(
      MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
      true,
      contentObserver!!
    )

    // Screen recording check
    handler?.postDelayed(object : Runnable {
      override fun run() {
        if (isScreenRecording()) {
          eventSink?.success(mapOf(
            "type" to "recording",
            "timestamp" to System.currentTimeMillis(),
            "platform" to "android",
            "isRecording" to true
          ))
        }
        handler?.postDelayed(this, 1000)
      }
    }, 1000)
  }

  private fun isScreenshot(uri: Uri?): Boolean {
    uri ?: return false
    val path = uri.toString().lowercase()
    val isMediaStoreScreenshot = path.contains("screenshot") ||
            path.contains("screen") ||
            path.contains("capture")

    if (isMediaStoreScreenshot) return true

    val projection = arrayOf(MediaStore.Images.Media.DATA)
    val cursor = context?.contentResolver?.query(uri, projection, null, null, null)
    cursor?.use {
      if (it.moveToFirst()) {
        val filePath = it.getString(it.getColumnIndexOrThrow(MediaStore.Images.Media.DATA))
        if (filePath?.lowercase()?.contains("screenshot") == true) {
          return true
        }
      }
    }
    return false
  }


  @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
  private fun isScreenRecording(): Boolean {
    // Method 1: Check for virtual displays
    val displayManager = context?.getSystemService(Context.DISPLAY_SERVICE) as? DisplayManager
    displayManager?.displays?.forEach { display ->
      if (display.flags and Display.FLAG_SECURE != 0 ||
        display.flags and Display.FLAG_PRESENTATION != 0 ||
        display.name.contains("Overlay") ||
        display.name.contains("Virtual")) {
        return true
      }
    }

    // Method 2: Check for media projection (alternative approach)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      val mediaProjectionManager = context?.getSystemService(Context.MEDIA_PROJECTION_SERVICE) as? MediaProjectionManager
      try {
        // Alternative check without reflection
        val intent = mediaProjectionManager?.createScreenCaptureIntent()
        if (intent != null && intent.resolveActivity(context?.packageManager!!) != null) {
          // This doesn't guarantee recording is active, but suggests the capability exists
          return true
        }
      } catch (e: Exception) {
        // Fall through
      }
    }

    return false
  }

  @SuppressLint("BatteryLife")
  private fun checkBatteryOptimization() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      val packageName = context?.packageName ?: return
      val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
        data = Uri.parse("package:$packageName")
        // Add this flag when starting from non-Activity context
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      }

      // Check if the intent can be resolved
      if (intent.resolveActivity(context?.packageManager!!) != null) {
        context?.startActivity(intent)
      }
    }
  }

  private fun stopMonitoring() {
    contentObserver?.let {
      context?.contentResolver?.unregisterContentObserver(it)
      contentObserver = null
    }
    handler?.removeCallbacksAndMessages(null)
    handler = null
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    stopMonitoring()
  }
}