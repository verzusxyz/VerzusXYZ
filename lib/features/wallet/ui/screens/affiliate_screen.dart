import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/auth/data/repositories/auth_repository.dart';
import 'package:verzus/features/wallet/data/repositories/affiliate_repository.dart';
import 'package:verzus/services/wallet_service.dart';
import 'package:verzus/widgets/verzus_button.dart';

class AffiliateScreen extends ConsumerWidget {
  const AffiliateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authUser = ref.watch(authRepositoryProvider).currentUser;
    final wallet = ref.watch(walletProvider);
    final affiliateHistory = ref.watch(affiliateHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Affiliate'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Affiliate Balance',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '\$${wallet?.affiliateBalance.toStringAsFixed(2) ?? '0.00'}',
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
            VerzusButton(
              onPressed: () async {
                if (authUser != null) {
                  await ref
                      .read(affiliateRepositoryProvider)
                      .withdrawAffiliateEarnings(authUser.uid);
                }
              },
              child: const Text('Withdraw'),
            ),
            const SizedBox(height: 32),
            Text(
              'History',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: affiliateHistory.when(
                data: (history) {
                  if (history.isEmpty) {
                    return const Center(
                      child: Text('No affiliate history.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title:
                            Text('Referred user ${item['referred_user_id']}'),
                        trailing: Text('+\$${item['amount']}'),
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

final affiliateHistoryProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final authUser = ref.watch(authRepositoryProvider).currentUser;
  if (authUser != null) {
    return ref
        .watch(affiliateRepositoryProvider)
        .getAffiliateHistory(authUser.uid);
  }
  return Stream.value([]);
});
