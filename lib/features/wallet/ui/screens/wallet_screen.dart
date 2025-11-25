import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/auth/data/repositories/auth_repository.dart';
import 'package:verzus/features/wallet/data/models/wallet_model.dart';
import 'package:verzus/features/wallet/data/repositories/wallet_repository.dart';
import 'package:verzus/utils/responsive.dart';
import 'package:verzus/widgets/shimmers.dart';
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
    final responsive = Responsive(context);
    final authUser = ref.watch(authRepositoryProvider).currentUser;
    if (authUser == null) {
      return const Center(child: Text('Please sign in to view your wallet.'));
    }

    final walletStream = ref.watch(walletRepositoryProvider).listenToWallet(authUser.uid);
    final mode = ref.watch(walletModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: responsive.widthPercent(0.02)),
            child: _ModeToggle(
              mode: mode,
              onChanged: (v) => ref.read(walletModeProvider.notifier).state = v,
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
                return Padding(
                  padding: EdgeInsets.all(responsive.widthPercent(0.04)),
                  child: VerzusShimmers.card(height: responsive.heightPercent(0.25)),
                );
              }
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');

              final total = _calculateBalance(snapshot.data, mode, 'total');
              final available = _calculateBalance(snapshot.data, mode, 'available');
              final pending = _calculateBalance(snapshot.data, mode, 'pending');

              return _WalletCard(
                mode: mode, total: total, available: available, pending: pending,
                onDeposit: _showDepositDialog, onWithdraw: _showWithdrawDialog,
              );
            },
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: responsive.widthPercent(0.04)),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(responsive.diagonalPercent(0.015)),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [Tab(text: 'Transactions'), Tab(text: 'Deposits'), Tab(text: 'Withdrawals')],
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              indicator: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(responsive.diagonalPercent(0.012)),
              ),
              dividerColor: Colors.transparent,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionsList(authUser.uid, responsive),
                _buildEmptyState(responsive, icon: Icons.add, title: 'No Deposits', subtitle: ''),
                _buildEmptyState(responsive, icon: Icons.remove, title: 'No Withdrawals', subtitle: ''),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateBalance(Map<String, dynamic>? data, WalletKind mode, String type) {
    if (data == null) return 0.0;
    final balanceKey = mode == WalletKind.live ? 'live_balance' : 'demo_balance';
    final pendingKey = mode == WalletKind.live ? 'live_pending' : 'demo_pending';
    final balance = (data[balanceKey] ?? 0.0) as num;
    final pending = (data[pendingKey] ?? 0.0) as num;
    switch (type) {
      case 'total': return balance.toDouble() + pending.toDouble();
      case 'available': return balance.toDouble();
      case 'pending': return pending.toDouble();
      default: return 0.0;
    }
  }

  Widget _buildTransactionsList(String uid, Responsive responsive) {
    final transactionsStream = ref.watch(walletRepositoryProvider).getUserTransactions(uid);
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: transactionsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            padding: EdgeInsets.all(responsive.widthPercent(0.04)),
            itemCount: 5,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(bottom: responsive.heightPercent(0.015)),
              child: VerzusShimmers.listTile(),
            ),
          );
        }
        if (snapshot.hasError) return _buildErrorNotice(context, snapshot.error!);
        final transactions = snapshot.data ?? [];
        if (transactions.isEmpty) {
          return _buildEmptyState(responsive, icon: Icons.receipt_long, title: 'No Transactions', subtitle: 'Your transaction history will appear here.');
        }
        return ListView.builder(
          padding: EdgeInsets.all(responsive.widthPercent(0.04)),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final tx = transactions[index];
            final isDeposit = tx['type'] == 'deposit';
            return Card(
              margin: EdgeInsets.only(bottom: responsive.heightPercent(0.015)),
              child: ListTile(
                title: Text(tx['description'], style: TextStyle(fontSize: responsive.diagonalPercent(0.018))),
                subtitle: Text(tx['type'], style: TextStyle(fontSize: responsive.diagonalPercent(0.015))),
                trailing: Text(
                  '${isDeposit ? '+' : '-'}\$${(tx['amount'] as num).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isDeposit ? Colors.green : Colors.red,
                    fontSize: responsive.diagonalPercent(0.018),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDepositDialog() {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('Deposit'),
      content: const Text('Deposit functionality will be implemented here.'),
      actions: [VerzusButton.text(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
    ));
  }

  void _showWithdrawDialog() {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('Withdraw'),
      content: const Text('Withdraw functionality will be implemented here.'),
      actions: [VerzusButton.text(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
    ));
  }

  Widget _buildErrorNotice(BuildContext context, Object error) {
    return Center(child: Text('Error: $error'));
  }

  Widget _buildEmptyState(Responsive responsive, {required IconData icon, required String title, required String subtitle}) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: responsive.diagonalPercent(0.06), color: Colors.grey),
          SizedBox(height: responsive.heightPercent(0.02)),
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontSize: responsive.diagonalPercent(0.025))),
          SizedBox(height: responsive.heightPercent(0.01)),
          Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(fontSize: responsive.diagonalPercent(0.018))),
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
    required this.mode, required this.total, required this.available,
    required this.pending, required this.onDeposit, required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.all(responsive.widthPercent(0.04)),
      padding: EdgeInsets.all(responsive.diagonalPercent(0.025)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.7)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(responsive.diagonalPercent(0.025)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Balance (${mode == WalletKind.live ? 'Live' : 'Demo'})',
              style: TextStyle(color: Colors.white70, fontSize: responsive.diagonalPercent(0.018))),
          Text('\$${total.toStringAsFixed(2)}', style: TextStyle(
              color: Colors.white, fontSize: responsive.diagonalPercent(0.045), fontWeight: FontWeight.bold)),
          SizedBox(height: responsive.heightPercent(0.025)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BalanceChip(label: 'Available', amount: '\$${available.toStringAsFixed(2)}'),
              _BalanceChip(label: 'Pending', amount: '\$${pending.toStringAsFixed(2)}'),
            ],
          ),
          SizedBox(height: responsive.heightPercent(0.025)),
          Row(
            children: [
              Expanded(child: VerzusButton(onPressed: onDeposit, child: const Text('Deposit'))),
              SizedBox(width: responsive.widthPercent(0.04)),
              Expanded(child: VerzusButton.outline(onPressed: onWithdraw, child: const Text('Withdraw'))),
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
    final responsive = Responsive(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: responsive.diagonalPercent(0.016))),
        Text(amount, style: TextStyle(color: Colors.white, fontSize: responsive.diagonalPercent(0.022), fontWeight: FontWeight.w600)),
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
    final responsive = Responsive(context);
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(responsive.diagonalPercent(0.005)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pill(context, responsive, label: 'Live', selected: mode == WalletKind.live, onTap: () => onChanged(WalletKind.live)),
          _pill(context, responsive, label: 'Demo', selected: mode == WalletKind.demo, onTap: () => onChanged(WalletKind.demo)),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, Responsive responsive, {required String label, required bool selected, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: responsive.widthPercent(0.03), vertical: responsive.heightPercent(0.008)),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: responsive.diagonalPercent(0.016)
          ),
        ),
      ),
    );
  }
}
