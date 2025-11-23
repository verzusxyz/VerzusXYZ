// lib/services/web_capture_interop_stub.dart
// Fallback for non-web platforms so imports compile.

class _WebFrameEvent {
  final String base64;
  final int timestamp;
  _WebFrameEvent(this.base64, this.timestamp);
}

// ignore: library_private_types_in_public_api
Stream<_WebFrameEvent> webFrameStream() async* {
  // No frames on non-web.
}

Future<void> startWebCapture(Map<String, dynamic> settings) async {}

Future<void> stopWebCapture() async {}
