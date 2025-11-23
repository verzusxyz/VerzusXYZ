// lib/services/web_capture_interop.dart
// Only compiled on web. Bridges window.postMessage frames from web/capture.js into a Dart stream.

import 'dart:async';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:js_util' as js_util;

class _WebFrameEvent {
  final String base64;
  final int timestamp;
  _WebFrameEvent(this.base64, this.timestamp);
}

final _controller = StreamController<_WebFrameEvent>.broadcast();

bool _listening = false;

void _ensureListening() {
  if (_listening) return;
  _listening = true;
  html.window.onMessage.listen((event) {
    final data = event.data;
    if (data is Map && data['type'] == 'verzus_frame') {
      final String? b64 = data['base64'] as String?;
      final int? ts = (data['timestamp'] as num?)?.toInt();
      if (b64 != null && ts != null) {
        _controller.add(_WebFrameEvent(b64, ts));
      }
    }
  });
}

// ignore: library_private_types_in_public_api
Stream<_WebFrameEvent> webFrameStream() {
  _ensureListening();
  return _controller.stream;
}

Future<void> startWebCapture(Map<String, dynamic> settings) async {
  _ensureListening();
  // Call JS global function injected by web/capture.js
  final fps = settings['fps'] ?? 3;
  try {
    js_util.callMethod(html.window, 'startWebCapture', [
      settings..addAll({'fps': fps})
    ]);
  } catch (_) {
    // no-op if JS not loaded
  }
}

Future<void> stopWebCapture() async {
  try {
    js_util.callMethod(html.window, 'stopWebCapture', []);
  } catch (_) {
    // ignore
  }
}
