import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/services/screen_record_service.dart';

class RecordingIndicator extends ConsumerWidget {
  const RecordingIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(recordingStateProvider);

    if (recordingState == RecordingState.idle) {
      return const SizedBox.shrink();
    }

    String text;
    Color color;

    switch (recordingState) {
      case RecordingState.recording:
        text = 'GAME LIVE';
        color = Colors.blue;
        break;
      case RecordingState.processing:
        text = 'MATCH ON';
        color = Colors.blueAccent;
        break;
      case RecordingState.idle:
        text = '';
        color = Colors.transparent;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
