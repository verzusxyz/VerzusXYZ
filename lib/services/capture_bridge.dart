// lib/services/capture_bridge.dart
// Unified screen-capture bridge for Android/iOS/Web. Web is implemented via capture.js.

import 'dart:async';
import 'dart:convert';
// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Conditional import to keep web-only dart:html usage out of mobile builds
import 'web_capture_interop_stub.dart'
    if (dart.library.html) 'web_capture_interop.dart' as webcap;

typedef FrameCallback = FutureOr<void> Function(
    Uint8List pngBytes, int timestamp);

class CaptureBridge {
  static final CaptureBridge _instance = CaptureBridge._internal();
  factory CaptureBridge() => _instance;
  CaptureBridge._internal();

  static const MethodChannel _channel = MethodChannel('com.verzusxyz.capture');

  StreamSubscription? _webSub;

  // Start capture according to platform. Provide crop rectangles & sampling rate.
  Future<void> startCapture({
    required String gameId,
    required Map<String, dynamic>
        cropRects, // {scoreRect: {x,y,w,h}, usernameRect: {...}, roomRect: {...}}
    required int fps,
    required FrameCallback onFrame,
  }) async {
    if (kIsWeb) {
      _webSub?.cancel();
      _webSub = webcap.webFrameStream().listen((event) async {
        try {
          final String base64Image = event.base64;
          final int ts = event.timestamp;
          final Uint8List bytes = base64Decode(base64Image);
          await onFrame(bytes, ts);
        } catch (e) {
          // ignore malformed frame
        }
      });
      await webcap.startWebCapture(
          {'fps': fps, 'cropRects': cropRects, 'gameId': gameId});
      return;
    }

    // For Android/iOS platform channels: we register an EventChannel for frames
    final EventChannel eventChannel =
        const EventChannel('com.verzusxyz.captureFrames');
    final Stream<dynamic> stream = eventChannel.receiveBroadcastStream({
      'gameId': gameId,
      'cropRects': cropRects,
      'fps': fps,
    });

    stream.listen((dynamic event) async {
      try {
        // Platform returns base64 PNG and timestamp
        final Map<dynamic, dynamic> map = event as Map<dynamic, dynamic>;
        final String base64Image = map['pngBase64'] as String;
        final int ts = (map['timestamp'] as num).toInt();
        final Uint8List bytes = base64Decode(base64Image);
        await onFrame(bytes, ts);
      } catch (err) {
        // ignore bad payloads
      }
    }, onError: (err) {
      // ignore errors for now; UI can surface toast if needed
      // print('CaptureBridge stream error: $err');
    });

    await _channel.invokeMethod('startPlatformCapture', {
      'gameId': gameId,
      'cropRects': cropRects,
      'fps': fps,
    });
  }

  Future<void> stopCapture() async {
    if (kIsWeb) {
      _webSub?.cancel();
      _webSub = null;
      await webcap.stopWebCapture();
      return;
    }
    await _channel.invokeMethod('stopPlatformCapture');
  }
}
