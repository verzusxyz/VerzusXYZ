import 'package:flutter/material.dart';
import 'package:verzus/features/wallet/data/models/wallet_model.dart';

class WalletToggle extends StatelessWidget {
  final WalletKind groupValue;
  final ValueChanged<WalletKind> onSelectionChanged;

  const WalletToggle({
    super.key,
    required this.groupValue,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<WalletKind>(
      segments: const <ButtonSegment<WalletKind>>[
        ButtonSegment<WalletKind>(
            value: WalletKind.live,
            label: Text('Live'),
            icon: Icon(Icons.monetization_on)),
        ButtonSegment<WalletKind>(
            value: WalletKind.demo,
            label: Text('Demo'),
            icon: Icon(Icons.videogame_asset)),
      ],
      selected: <WalletKind>{groupValue},
      onSelectionChanged: (Set<WalletKind> newSelection) {
        onSelectionChanged(newSelection.first);
      },
    );
  }
}
