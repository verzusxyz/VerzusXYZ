import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/wallet/data/models/wallet_model.dart';

final walletModeProvider = StateProvider<WalletKind>((ref) => WalletKind.live);
