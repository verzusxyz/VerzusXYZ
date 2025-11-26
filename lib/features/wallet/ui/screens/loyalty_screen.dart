import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/auth/data/repositories/auth_repository.dart';
import 'package:verzus/features/wallet/data/models/wallet_model.dart';
import 'package:verzus/features/wallet/data/repositories/loyalty_repository.dart';
import 'package:verzus/services/wallet_service.dart';
import 'package:verzus/widgets/verzus_button.dart';

class LoyaltyScreen extends ConsumerWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authUser = ref.watch(authRepositoryProvider).currentUser;
    final wallet = ref.watch(walletProvider);
    final loyaltyHistory = ref.watch(loyaltyHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loyalty'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loyalty Points',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${wallet?.loyaltyPoints ?? 0}',
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
            VerzusButton(
              onPressed: () async {
                if (authUser != null) {
                  await ref
                      .read(loyaltyRepositoryProvider)
                      .redeemLoyaltyPoints(authUser.uid);
                }
              },
              child: const Text('Redeem'),
            ),
            const SizedBox(height: 32),
            Text(
              'History',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: loyaltyHistory.when(
                data: (history) {
                  if (history.isEmpty) {
                    return const Center(
                      child: Text('No loyalty history.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return ListTile(
                        leading: const Icon(Icons.star),
                        title: Text(item['description']),
                        trailing: Text('+${item['points']}'),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text('Error: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final loyaltyHistoryProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final authUser = ref.watch(authRepositoryProvider).currentUser;
  if (authUser != null) {
    return ref.watch(loyaltyRepositoryProvider).getLoyaltyHistory(authUser.uid);
  }
  return Stream.value([]);
});
