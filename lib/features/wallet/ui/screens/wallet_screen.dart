import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/core/theme.dart';
import 'package:verzus/features/auth/data/repositories/auth_repository.dart';
import 'package:verzus/features/wallet/data/repositories/wallet_repository.dart';
import 'package:verzus/models/wallet_model.dart';
import 'package:verzus/widgets/verzus_button.dart';

// A simple provider to manage the wallet mode (Live/Demo)
final walletModeProvider = StateProvider<WalletKind>((ref) => WalletKind.live);

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authRepositoryProvider).currentUser;
    if (authUser == null) {
      return const Center(child: Text('Please sign in to view your wallet.'));
    }

    final walletStream =
        ref.watch(walletRepositoryProvider).listenToWallet(authUser.uid);
    final mode = ref.watch(walletModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _ModeToggle(
              mode: mode,
              onChanged: (v) =>
                  ref.read(walletModeProvider.notifier).state = v,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          StreamBuilder<Map<String, dynamic>?>(
            stream: walletStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              final walletData = snapshot.data;
              final total = _calculateBalance(walletData, mode, 'total');
              final available = _calculateBalance(walletData, mode, 'available');
              final pending = _calculateBalance(walletData, mode, 'pending');

              return _WalletCard(
                mode: mode,
                total: total,
                available: available,
                pending: pending,
                onDeposit: _showDepositDialog,
                onWithdraw: _showWithdrawDialog,
              );
            },
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Transactions'),
                Tab(text: 'Deposits'),
                Tab(text: 'Withdrawals'),
              ],
              labelColor: VerzusColors.primaryPurple,
              unselectedLabelColor:
                  Theme.of(context).colorScheme.onSurfaceVariant,
              indicator: BoxDecoration(
                color: VerzusColors.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              dividerColor: Colors.transparent,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionsList(authUser.uid),
                _buildEmptyState(
                    icon: Icons.add, title: 'No Deposits', subtitle: ''),
                _buildEmptyState(
                    icon: Icons.remove, title: 'No Withdrawals', subtitle: ''),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateBalance(
      Map<String, dynamic>? data, WalletKind mode, String type) {
    if (data == null) return 0.0;
    final balance = (mode == WalletKind.live
            ? data['live_balance']
            : data['demo_balance']) ??
        0.0;
    final pending = (mode == WalletKind.live
            ? data['live_pending']
            : data['demo_pending']) ??
        0.0;
    switch (type) {
      case 'total':
        return balance + pending;
      case 'available':
        return balance;
      case 'pending':
        return pending;
      default:
        return 0.0;
    }
  }

  Widget _buildTransactionsList(String uid) {
    final transactionsStream =
        ref.watch(walletRepositoryProvider).getUserTransactions(uid);
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: transactionsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildErrorNotice(context, snapshot.error!);
        }
        final transactions = snapshot.data ?? [];
        if (transactions.isEmpty) {
          return _buildEmptyState(
            icon: Icons.receipt_long,
            title: 'No Transactions',
            subtitle: 'Your transaction history will appear here.',
          );
        }
        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final tx = transactions[index];
            return ListTile(
              title: Text(tx['description']),
              subtitle: Text(tx['type']),
              trailing: Text(
                '\$${(tx['amount'] as num).toStringAsFixed(2)}',
                style: TextStyle(
                  color: tx['type'] == 'deposit' ? Colors.green : Colors.red,
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDepositDialog() {
    // Simplified deposit dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deposit'),
        content: const Text('Deposit functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    // Simplified withdraw dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw'),
        content: const Text('Withdraw functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorNotice(BuildContext context, Object error) {
    return Center(child: Text('Error: $error'));
  }

  Widget _buildEmptyState(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final WalletKind mode;
  final double total;
  final double available;
  final double pending;
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;

  const _WalletCard({
    required this.mode,
    required this.total,
    required this.available,
    required this.pending,
    required this.onDeposit,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [VerzusColors.primaryPurple, VerzusColors.primaryPurpleLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance (${mode == WalletKind.live ? 'Live' : 'Demo'})',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: const TextStyle(
                color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BalanceChip(
                  label: 'Available',
                  amount: '\$${available.toStringAsFixed(2)}'),
              _BalanceChip(
                  label: 'Pending',
                  amount: '\$${pending.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: VerzusButton(
                  onPressed: onDeposit,
                  child: const Text('Deposit'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: VerzusButton.outline(
                  onPressed: onWithdraw,
                  child: const Text('Withdraw'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  final String label;
  final String amount;

  const _BalanceChip({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(amount,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final WalletKind mode;
  final ValueChanged<WalletKind> onChanged;
  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pill(context,
              label: 'Live',
              selected: mode == WalletKind.live,
              onTap: () => onChanged(WalletKind.live)),
          _pill(context,
              label: 'Demo',
              selected: mode == WalletKind.demo,
              onTap: () => onChanged(WalletKind.demo)),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context,
      {required String label,
      required bool selected,
      required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? VerzusColors.primaryPurple.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected
                    ? VerzusColors.primaryPurple
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ),
    );
  }
}
