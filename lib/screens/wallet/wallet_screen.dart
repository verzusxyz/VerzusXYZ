// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:verzus/services/auth_service.dart';
// import 'package:verzus/services/wallet_service.dart';
// import 'package:verzus/services/payment_service.dart';
// import 'package:verzus/theme.dart';
// import 'package:verzus/widgets/verzus_button.dart';
// import 'package:verzus/models/wallet_model.dart';

// class WalletScreen extends ConsumerStatefulWidget {
//   const WalletScreen({super.key});

//   @override
//   ConsumerState<WalletScreen> createState() => _WalletScreenState();
// }

// class _WalletScreenState extends ConsumerState<WalletScreen> with TickerProviderStateMixin {
//   // Helper: robustly resolve signed-in user details
//   String? _getUserId() {
//     final auth = ref.read(authStateProvider).value;
//     if (auth != null) return auth.uid;
//     final model = ref.read(currentUserProvider).value;
//     return model?.uid;
//   }

//   String? _getUserEmail() {
//     final auth = ref.read(authStateProvider).value;
//     if (auth != null) return auth.email;
//     final model = ref.read(currentUserProvider).value;
//     return model?.email;
//   }

//   String? _getUserDisplayName() {
//     final auth = ref.read(authStateProvider).value;
//     if (auth != null) return auth.displayName;
//     final model = ref.read(currentUserProvider).value;
//     return model?.displayName;
//   }

//   late TabController _tabController;
//   double _depositAmount = 10.0;
//   String _depositCurrency = 'USD';
//   String _withdrawCurrency = 'USD';
//   final List<String> _supportedCurrencies = ['USD', 'KES', 'NGN', 'GHS'];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isTablet = screenWidth > 600;

//     // ✅ KEEP ALL ORIGINAL PROVIDERS & WATCHERS
//     final userAsync = ref.watch(currentUserProvider);
//     final wallet = ref.watch(walletProvider);
//     final mode = ref.watch(walletModeProvider);

//     // ✅ ORIGINAL: Auto-load wallet
//     userAsync.whenData((user) {
//       if (user != null && wallet == null) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ref.read(walletProvider.notifier).loadWallet(user.uid);
//         });
//       }
//     });

//     // ✅ ORIGINAL: Calculate balances exactly as before
//     final total = wallet != null
//         ? (mode == WalletKind.live
//             ? wallet.liveTotalFunds()
//             : wallet.demoTotalFunds())
//         : 0.0;
//     final available = wallet != null
//         ? (mode == WalletKind.live ? wallet.liveAvailable : wallet.demoAvailable)
//         : 0.0;
//     final pending = wallet != null
//         ? (mode == WalletKind.live ? wallet.pendingBalance : wallet.demoPendingBalance)
//         : 0.0;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Wallet'),
//         elevation: 0,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 12),
//             child: _ModeToggle(
//               mode: mode,
//               onChanged: (v) => ref.read(walletModeProvider.notifier).setMode(v),
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // ✅ FIXED: Compact Responsive Wallet Card
//           Container(
//             margin: EdgeInsets.all(isTablet ? 20 : 16),
//             padding: EdgeInsets.all(isTablet ? 24 : 20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [VerzusColors.primaryPurple, VerzusColors.primaryPurpleLight],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: VerzusColors.primaryPurple.withValues(alpha: 0.15),
//                   blurRadius: 20,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Header
//                 Row(
//                   children: [
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withValues(alpha: 0.2),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         mode == WalletKind.live ? 'LIVE' : 'DEMO',
//                         style: Theme.of(context).textTheme.labelSmall?.copyWith(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 11,
//                         ),
//                       ),
//                     ),
//                     const Spacer(),
//                     GestureDetector(
//                       onTap: () => context.push('/profile'),
//                       child: Container(
//                         width: 36,
//                         height: 36,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withValues(alpha: 0.2),
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
//                         ),
//                         child: const Icon(
//                           Icons.person_outline_rounded,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 // Total Balance
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Total Balance',
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: Colors.white.withValues(alpha: 0.8),
//                         fontSize: 13,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       _formatCurrency(total),
//                       style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         height: 1.1,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 // Balance Chips
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildCompactBalanceChip(
//                         'Available',
//                         _formatCurrency(available),
//                         Icons.check_circle_outline,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: _buildCompactBalanceChip(
//                         'Pending',
//                         _formatCurrency(pending),
//                         Icons.schedule_outlined,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 // Action Buttons - ONLY HERE
//                 Row(
//                   children: [
//                     Expanded(
//                       child: VerzusButton(
//                         size: VerzusButtonSize.small,
//                         onPressed: mode == WalletKind.live
//                             ? _showDepositDialog
//                             : () async {
//                                 final uid = _getUserId();
//                                 if (uid == null) return;
//                                 await ref.read(walletProvider.notifier).addDemoFunds(50);
//                                 if (!mounted) return;
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(content: Text('Added 50 demo coins')),
//                                 );
//                               },
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(mode == WalletKind.live ? Icons.add : Icons.stars, size: 16),
//                             const SizedBox(width: 4),
//                             Text(mode == WalletKind.live ? 'Deposit' : 'Demo'),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: VerzusButton.outline(
//                         size: VerzusButtonSize.small,
//                         onPressed: mode == WalletKind.live
//                             ? _showWithdrawDialog
//                             : () async {
//                                 await ref.read(walletProvider.notifier).resetWallet();
//                               },
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(mode == WalletKind.live ? Icons.remove : Icons.refresh, size: 16),
//                             const SizedBox(width: 4),
//                             Text(mode == WalletKind.live ? 'Withdraw' : 'Reset'),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // Tabs - NO DUPLICATE BUTTONS
//           Container(
//             margin: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.surfaceContainer,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: TabBar(
//               controller: _tabController,
//               labelColor: VerzusColors.primaryPurple,
//               unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
//               indicator: BoxDecoration(
//                 color: VerzusColors.primaryPurple.withValues(alpha: 0.12),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               dividerColor: Colors.transparent,
//               labelStyle: const TextStyle(fontWeight: FontWeight.w600),
//               tabs: const [
//                 Tab(icon: Icon(Icons.receipt_long, size: 20), text: 'Transactions'),
//                 Tab(icon: Icon(Icons.add_circle_outline, size: 20), text: 'Deposits'),
//                 Tab(icon: Icon(Icons.remove_circle_outline, size: 20), text: 'Withdrawals'),
//               ],
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Tab Content - NO BUTTONS
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildTransactionsList(),
//                 _buildDepositsList(), // NO BUTTON
//                 _buildWithdrawalsList(), // NO BUTTON
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ Compact Balance Chip
//   Widget _buildCompactBalanceChip(String label, String value, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.2),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(icon, size: 16, color: Colors.white),
//               const SizedBox(width: 4),
//               Flexible(
//                 child: Text(
//                   value,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 2),
//           Text(
//             label,
//             style: TextStyle(
//               color: Colors.white.withValues(alpha: 0.8),
//               fontSize: 10,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ ORIGINAL Formatting
//   String _formatCurrency(double value) => '\$${value.toStringAsFixed(2)}';

//   // ✅ NO BUTTONS IN TABS
//   Widget _buildTransactionsList() {
//     return ListView(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//       children: [
//         _buildEmptyState(
//           icon: Icons.receipt_long_rounded,
//           title: 'No Transactions',
//           subtitle: 'Your transaction history will appear here',
//         ),
//       ],
//     );
//   }

//   Widget _buildDepositsList() {
//     return ListView(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//       children: [
//         _buildEmptyState(
//           icon: Icons.add_circle_outline_rounded,
//           title: 'No Deposits',
//           subtitle: 'Your deposit history will appear here',
//           // ✅ NO BUTTON
//         ),
//       ],
//     );
//   }

//   Widget _buildWithdrawalsList() {
//     return ListView(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//       children: [
//         _buildEmptyState(
//           icon: Icons.remove_circle_outline_rounded,
//           title: 'No Withdrawals',
//           subtitle: 'Your withdrawal history will appear here',
//           // ✅ NO BUTTON
//         ),
//       ],
//     );
//   }

//   Widget _buildEmptyState({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.all(40),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.surfaceContainer,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             title,
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Text(
//               subtitle,
//               style: Theme.of(context).textTheme.bodyMedium,
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ ORIGINAL Deposit Dialog
//   void _showDepositDialog() {
//     final mode = ref.read(walletModeProvider);
//     if (mode == WalletKind.demo) {
//       showDialog(
//         context: context,
//         builder: (ctx) => AlertDialog(
//           title: const Text('Add Demo Coins'),
//           content: const Text('Demo wallet is for practice only. Add coins to try the experience.'),
//           actions: [
//             TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.of(ctx).pop();
//                 final uid = _getUserId();
//                 if (uid != null) {
//                   await ref.read(walletProvider.notifier).addDemoFunds(50);
//                 }
//                 if (!mounted) return;
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Added 50 demo coins')),
//                 );
//               },
//               child: const Text('Add 50'),
//             )
//           ],
//         ),
//       );
//       return;
//     }
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => _buildDepositSheet(),
//     );
//   }

//   // ✅ ORIGINAL Withdraw Dialog
//   void _showWithdrawDialog() {
//     final mode = ref.read(walletModeProvider);
//     if (mode == WalletKind.demo) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Withdrawals are disabled in Demo mode')),
//       );
//       return;
//     }
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => _buildWithdrawSheet(),
//     );
//   }

//   // ✅ ORIGINAL Deposit Sheet
//   Widget _buildDepositSheet() {
//     return Container(
//       padding: EdgeInsets.only(
//         left: 24,
//         right: 24,
//         top: 24,
//         bottom: MediaQuery.of(context).viewInsets.bottom + 24,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 'Deposit Funds',
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//               const Spacer(),
//               IconButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 icon: const Icon(Icons.close_rounded),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'Deposit Amount',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//           ),
//           const SizedBox(height: 12),
//           _AmountField(onAmountChanged: (v) => _depositAmount = v),
//           const SizedBox(height: 16),
//           Text(
//             'Currency',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//           ),
//           const SizedBox(height: 8),
//           DropdownButtonFormField<String>(
//             value: _depositCurrency,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//               contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             ),
//             items: _supportedCurrencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
//             onChanged: (v) => setState(() => _depositCurrency = v ?? 'USD'),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Choose Payment Method',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//           ),
//           const SizedBox(height: 16),
//           _buildPaymentMethodCard(
//             title: 'Paystack',
//             subtitle: 'Card, Bank Transfer, USSD',
//             icon: Icons.credit_card_rounded,
//             color: VerzusColors.accentGreen,
//             onTap: _onPaystackDeposit,
//           ),
//           const SizedBox(height: 12),
//           _buildPaymentMethodCard(
//             title: 'Flutterwave',
//             subtitle: 'Multiple payment options',
//             icon: Icons.payment_rounded,
//             color: VerzusColors.accentOrange,
//             onTap: _onFlutterwaveDeposit,
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ ORIGINAL Withdraw Sheet
//   Widget _buildWithdrawSheet() {
//     final mode = ref.read(walletModeProvider);
//     final w = ref.read(walletProvider);
//     final available = (w == null)
//         ? 0.0
//         : (mode == WalletKind.live ? w.balance : w.demoBalance);
//     double withdrawAmount = available > 0 ? (available >= 10 ? 10.0 : available) : 0.0;

//     return StatefulBuilder(
//       builder: (context, setState) {
//         return Container(
//           padding: EdgeInsets.only(
//             left: 24,
//             right: 24,
//             top: 24,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 24,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     'Withdraw Funds',
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     icon: const Icon(Icons.close_rounded),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Available: ${_formatCurrency(available)}',
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       color: Theme.of(context).colorScheme.onSurfaceVariant,
//                     ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Withdraw Amount',
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                 decoration: InputDecoration(
//                   prefixText: '',
//                   labelText: 'Amount',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onChanged: (value) {
//                   final v = double.tryParse(value) ?? 0.0;
//                   setState(() => withdrawAmount = v);
//                 },
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Currency',
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//               const SizedBox(height: 8),
//               DropdownButtonFormField<String>(
//                 value: _withdrawCurrency,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 ),
//                 items: _supportedCurrencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
//                 onChanged: (v) => setState(() => _withdrawCurrency = v ?? 'USD'),
//               ),
//               const SizedBox(height: 12),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.surfaceContainerHighest,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Summary',
//                       style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 8),
//                     Text('Amount: ' + withdrawAmount.toStringAsFixed(2) + ' ' + _withdrawCurrency),
//                     Text('Fee: ' + (withdrawAmount * 0.015).toStringAsFixed(2) + ' ' + _withdrawCurrency),
//                     Text('You receive: ' + (withdrawAmount * 0.985).toStringAsFixed(2) + ' ' + _withdrawCurrency),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Choose Payout Method',
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildPaymentMethodCard(
//                       title: 'Paystack',
//                       subtitle: 'Bank/account payout',
//                       icon: Icons.account_balance_rounded,
//                       color: VerzusColors.accentGreen,
//                       onTap: () => _onRequestWithdrawal(method: 'paystack', amount: withdrawAmount, currency: _withdrawCurrency),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _buildPaymentMethodCard(
//                       title: 'Flutterwave',
//                       subtitle: 'Bank/mobile money payout',
//                       icon: Icons.account_balance_wallet_rounded,
//                       color: VerzusColors.accentOrange,
//                       onTap: () => _onRequestWithdrawal(method: 'flutterwave', amount: withdrawAmount, currency: _withdrawCurrency),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // ✅ ORIGINAL Payment Method Card
//   Widget _buildPaymentMethodCard({
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: color.withValues(alpha: 0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: color.withValues(alpha: 0.3),
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               color: color,
//               size: 24,
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: color,
//                         ),
//                   ),
//                   Text(
//                     subtitle,
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: Theme.of(context).colorScheme.onSurfaceVariant,
//                         ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               color: color,
//               size: 16,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ ORIGINAL Withdrawal Request
//   Future<void> _onRequestWithdrawal({required String method, required double amount, required String currency}) async {
//     final userId = _getUserId();
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Please sign in to continue'),
//           backgroundColor: VerzusColors.dangerRed,
//         ),
//       );
//       return;
//     }
//     if (amount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Enter a valid amount'),
//           backgroundColor: VerzusColors.dangerRed,
//         ),
//       );
//       return;
//     }

//     await showDialog(
//       context: context,
//       builder: (ctx) {
//         return AlertDialog(
//           title: const Text('Confirm Withdrawal'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Amount: ${amount.toStringAsFixed(2)} $currency'),
//               Text('Fee: ${(amount * 0.015).toStringAsFixed(2)} $currency'),
//               Text('You receive: ${(amount * 0.985).toStringAsFixed(2)} $currency'),
//             ],
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.of(ctx).pop();
//                 Navigator.of(context).pop();
//                 try {
//                   final payment = ref.read(paymentServiceProvider);
//                   await payment.requestWithdrawal(
//                     userId: userId,
//                     amount: amount,
//                     method: method,
//                     currency: currency,
//                     note: 'Standard withdrawal',
//                   );
//                   // ✅ CRITICAL: RELOAD WALLET
//                   await ref.read(walletProvider.notifier).loadWallet(userId);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Withdrawal requested: ${amount.toStringAsFixed(2)} $currency'),
//                       backgroundColor: VerzusColors.accentGreen,
//                     ),
//                   );
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Withdrawal failed: $e'),
//                       backgroundColor: VerzusColors.dangerRed,
//                     ),
//                   );
//                 }
//               },
//               child: const Text('Confirm'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ✅ ORIGINAL Paystack Deposit
//   Future<void> _onPaystackDeposit() async {
//     final userId = _getUserId();
//     final email = _getUserEmail();
//     if (userId == null || (email == null || email.isEmpty)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Please sign in to continue'),
//           backgroundColor: VerzusColors.dangerRed,
//         ),
//       );
//       return;
//     }

//     final mode = ref.read(walletModeProvider);
//     if (mode == WalletKind.demo) {
//       await ref.read(walletProvider.notifier).addDemoFunds(_depositAmount);
//       if (mounted) {
//         Navigator.of(context).pop();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Added ${_depositAmount.toStringAsFixed(2)} demo coins'),
//             backgroundColor: VerzusColors.accentGreen,
//           ),
//         );
//       }
//       return;
//     }

//     Navigator.of(context).pop();
//     final payment = ref.read(paymentServiceProvider);
//     try {
//       await payment.depositWithPaystack(
//         context: context,
//         userId: userId,
//         email: email,
//         amount: _depositAmount,
//         currency: _depositCurrency,
//         channel: 'card',
//       );
//       // ✅ CRITICAL: RELOAD WALLET
//       await ref.read(walletProvider.notifier).loadWallet(userId);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Deposited ${_depositAmount.toStringAsFixed(2)} ${_depositCurrency} via Paystack'),
//           backgroundColor: VerzusColors.accentGreen,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Deposit failed: $e'),
//           backgroundColor: VerzusColors.dangerRed,
//         ),
//       );
//     }
//   }

//   // ✅ ORIGINAL Flutterwave Deposit
//   Future<void> _onFlutterwaveDeposit() async {
//     final userId = _getUserId();
//     final email = _getUserEmail();
//     final name = _getUserDisplayName() ?? 'Verzus User';
//     if (userId == null || (email == null || email.isEmpty)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Please sign in to continue'),
//           backgroundColor: VerzusColors.dangerRed,
//         ),
//       );
//       return;
//     }

//     final mode = ref.read(walletModeProvider);
//     if (mode == WalletKind.demo) {
//       await ref.read(walletProvider.notifier).addDemoFunds(_depositAmount);
//       if (mounted) {
//         Navigator.of(context).pop();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Added ${_depositAmount.toStringAsFixed(2)} demo coins'),
//             backgroundColor: VerzusColors.accentGreen,
//           ),
//         );
//       }
//       return;
//     }

//     Navigator.of(context).pop();
//     final payment = ref.read(paymentServiceProvider);
//     try {
//       await payment.depositWithFlutterwave(
//         context: context,
//         userId: userId,
//         email: email,
//         fullName: name,
//         amount: _depositAmount,
//         currency: _depositCurrency,
//         channel: 'card',
//       );
//       // ✅ CRITICAL: RELOAD WALLET
//       await ref.read(walletProvider.notifier).loadWallet(userId);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Deposited ${_depositAmount.toStringAsFixed(2)} ${_depositCurrency} via Flutterwave'),
//           backgroundColor: VerzusColors.accentGreen,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Deposit failed: $e'),
//           backgroundColor: VerzusColors.dangerRed,
//         ),
//       );
//     }
//   }
// }

// // ✅ ORIGINAL Mode Toggle
// class _ModeToggle extends StatelessWidget {
//   final WalletKind mode;
//   final ValueChanged<WalletKind> onChanged;
//   const _ModeToggle({required this.mode, required this.onChanged});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surfaceContainerHighest,
//         borderRadius: BorderRadius.circular(999),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _pill(context, label: 'Live', selected: mode == WalletKind.live, onTap: () => onChanged(WalletKind.live)),
//           _pill(context, label: 'Demo', selected: mode == WalletKind.demo, onTap: () => onChanged(WalletKind.demo)),
//         ],
//       ),
//     );
//   }

//   Widget _pill(BuildContext context, {required String label, required bool selected, required VoidCallback onTap}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(999),
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: selected ? VerzusColors.primaryPurple.withValues(alpha: 0.15) : Colors.transparent,
//             borderRadius: BorderRadius.circular(999),
//           ),
//           child: Text(
//             label,
//             style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                   color: selected ? VerzusColors.primaryPurple : Theme.of(context).colorScheme.onSurfaceVariant,
//                   fontWeight: selected ? FontWeight.bold : FontWeight.normal,
//                 ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ✅ ORIGINAL Amount Field
// class _AmountField extends StatefulWidget {
//   final ValueChanged<double> onAmountChanged;
//   const _AmountField({required this.onAmountChanged});

//   @override
//   State<_AmountField> createState() => _AmountFieldState();
// }

// class _AmountFieldState extends State<_AmountField> {
//   late final TextEditingController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController(text: '10.00');
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: _controller,
//       keyboardType: const TextInputType.numberWithOptions(decimal: true),
//       decoration: InputDecoration(
//         prefixText: '',
//         labelText: 'Amount',
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//       onChanged: (value) {
//         final v = double.tryParse(value) ?? 0.0;
//         widget.onAmountChanged(v);
//       },
//     );
//   }
// }
// ------------------------------------------------------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verzus/services/auth_service.dart';
import 'package:verzus/services/wallet_service.dart';
import 'package:verzus/services/payment_service.dart';
import 'package:verzus/providers/firebase_providers.dart';
import 'package:verzus/theme.dart';
import 'package:verzus/widgets/verzus_button.dart';
import 'package:verzus/models/wallet_model.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with TickerProviderStateMixin {
  // ✅ BULLETPROOF: Use userId from auth (never null when signed in)
  String get _userId {
    final auth = ref.read(authStateProvider).value;
    if (auth != null) return auth.uid;
    final model = ref.read(currentUserProvider).value;
    return model?.uid ?? '';
  }

  late TabController _tabController;
  double _depositAmount = 10.0;
  String _depositCurrency = 'USD';
  String _withdrawCurrency = 'USD';
  final List<String> _supportedCurrencies = ['USD', 'KES', 'NGN', 'GHS'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // ✅ BULLETPROOF: Auto-load on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_userId.isNotEmpty) {
        ref.read(walletProvider.notifier).loadWallet(_userId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // ✅ BULLETPROOF: Watch STREAM PROVIDER (auto-syncs with Firestore)
    final walletAsync = ref.watch(userWalletProvider);
    final mode = ref.watch(walletModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _ModeToggle(
              mode: mode,
              onChanged: (v) {
                ref.read(walletModeProvider.notifier).setMode(v);
                // ✅ BULLETPROOF: RELOAD on mode switch
                if (_userId.isNotEmpty) {
                  ref.read(walletProvider.notifier).loadWallet(_userId);
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ BULLETPROOF WALLET CARD
          Container(
            margin: EdgeInsets.all(isTablet ? 20 : 16),
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  VerzusColors.primaryPurple,
                  VerzusColors.primaryPurpleLight
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: VerzusColors.primaryPurple.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: walletAsync.when(
              // ✅ LOADING
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
              // ✅ ERROR
              error: (error, _) => _buildErrorCard(error.toString()),
              // ✅ SUCCESS - BULLETPROOF CALCULATIONS (NO DocumentSnapshot!)
              data: (walletData) {
                if (walletData == null) {
                  return _buildEmptyWalletCard();
                }

                // ✅ FIXED: Direct calculation from Map data - NO DocumentSnapshot!
                final total = mode == WalletKind.live
                    ? (walletData['live_balance'] ?? 0.0) +
                        (walletData['live_pending'] ?? 0.0)
                    : (walletData['demo_balance'] ?? 0.0) +
                        (walletData['demo_pending'] ?? 0.0);
                final available = mode == WalletKind.live
                    ? (walletData['live_balance'] ?? 0.0)
                    : (walletData['demo_balance'] ?? 0.0);
                final pending = mode == WalletKind.live
                    ? (walletData['live_pending'] ?? 0.0)
                    : (walletData['demo_pending'] ?? 0.0);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            mode == WalletKind.live ? 'LIVE' : 'DEMO',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              // ignore: deprecated_member_use
                              border: Border.all(
                                  // ignore: deprecated_member_use
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Total Balance
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Balance',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    // ignore: deprecated_member_use
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(total),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Balance Chips
                    Row(
                      children: [
                        Expanded(
                          child: _buildCompactBalanceChip(
                            'Available',
                            _formatCurrency(available),
                            Icons.check_circle_outline,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildCompactBalanceChip(
                            'Pending',
                            _formatCurrency(pending),
                            Icons.schedule_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: VerzusButton(
                            size: VerzusButtonSize.small,
                            onPressed: mode == WalletKind.live
                                ? _showDepositDialog
                                : () async {
                                    await ref
                                        .read(walletProvider.notifier)
                                        .addDemoFunds(50);
                                    if (!mounted) return;
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Added 50 demo coins')),
                                    );
                                  },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                    mode == WalletKind.live
                                        ? Icons.add
                                        : Icons.stars,
                                    size: 16),
                                const SizedBox(width: 4),
                                Text(mode == WalletKind.live
                                    ? 'Deposit'
                                    : 'Demo'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: VerzusButton.outline(
                            size: VerzusButtonSize.small,
                            onPressed: mode == WalletKind.live
                                ? _showWithdrawDialog
                                : () async {
                                    await ref
                                        .read(walletProvider.notifier)
                                        .resetWallet();
                                  },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                    mode == WalletKind.live
                                        ? Icons.remove
                                        : Icons.refresh,
                                    size: 16),
                                const SizedBox(width: 4),
                                Text(mode == WalletKind.live
                                    ? 'Withdraw'
                                    : 'Reset'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),

          // Tabs
          Container(
            margin: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: VerzusColors.primaryPurple,
              unselectedLabelColor:
                  Theme.of(context).colorScheme.onSurfaceVariant,
              indicator: BoxDecoration(
                // ignore: deprecated_member_use
                color: VerzusColors.primaryPurple.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(
                    icon: Icon(Icons.receipt_long, size: 20),
                    text: 'Transactions'),
                Tab(
                    icon: Icon(Icons.add_circle_outline, size: 20),
                    text: 'Deposits'),
                Tab(
                    icon: Icon(Icons.remove_circle_outline, size: 20),
                    text: 'Withdrawals'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionsList(),
                _buildDepositsList(),
                _buildWithdrawalsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ BULLETPROOF: Error Card
  Widget _buildErrorCard(String error) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ignore: deprecated_member_use
          Icon(Icons.error_outline,
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.7),
              size: 48),
          const SizedBox(height: 16),
          Text('Wallet Error',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 8),
          // ignore: deprecated_member_use
          Text(error,
              // ignore: deprecated_member_use
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          VerzusButton(
            onPressed: () =>
                ref.read(walletProvider.notifier).loadWallet(_userId),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ✅ BULLETPROOF: Empty Wallet Card
  Widget _buildEmptyWalletCard() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ignore: deprecated_member_use
          Icon(Icons.wallet_outlined,
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.7),
              size: 48),
          const SizedBox(height: 16),
          Text('No Wallet',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 8),
          // ignore: deprecated_member_use
          Text('Create your first deposit',
              // ignore: deprecated_member_use
              style: TextStyle(color: Colors.white.withOpacity(0.7))),
        ],
      ),
    );
  }

  // ✅ Compact Balance Chip
  Widget _buildCompactBalanceChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ✅ Formatting
  String _formatCurrency(double value) => '\$${value.toStringAsFixed(2)}';

  // ✅ Tab Lists
  Widget _buildTransactionsList() => ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildEmptyState(
            icon: Icons.receipt_long_rounded,
            title: 'No Transactions',
            subtitle: 'Your transaction history will appear here',
          ),
        ],
      );

  Widget _buildDepositsList() => ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildEmptyState(
            icon: Icons.add_circle_outline_rounded,
            title: 'No Deposits',
            subtitle: 'Your deposit history will appear here',
          ),
        ],
      );

  Widget _buildWithdrawalsList() => ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildEmptyState(
            icon: Icons.remove_circle_outline_rounded,
            title: 'No Withdrawals',
            subtitle: 'Your withdrawal history will appear here',
          ),
        ],
      );

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Deposit Dialog
  void _showDepositDialog() {
    final mode = ref.read(walletModeProvider);
    if (mode == WalletKind.demo) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Add Demo Coins'),
          content: const Text(
              'Demo wallet is for practice only. Add coins to try the experience.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await ref.read(walletProvider.notifier).addDemoFunds(50);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added 50 demo coins')),
                );
              },
              child: const Text('Add 50'),
            )
          ],
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildDepositSheet(),
    );
  }

  // ✅ Withdraw Dialog
  void _showWithdrawDialog() {
    final mode = ref.read(walletModeProvider);
    if (mode == WalletKind.demo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Withdrawals are disabled in Demo mode')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildWithdrawSheet(),
    );
  }

  // ✅ Deposit Sheet
  Widget _buildDepositSheet() {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Deposit Funds',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Deposit Amount',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _AmountField(onAmountChanged: (v) => _depositAmount = v),
          const SizedBox(height: 16),
          Text(
            'Currency',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _depositCurrency,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _supportedCurrencies
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _depositCurrency = v ?? 'USD'),
          ),
          const SizedBox(height: 16),
          Text(
            'Choose Payment Method',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildPaymentMethodCard(
            title: 'Paystack',
            subtitle: 'Card, Bank Transfer, USSD',
            icon: Icons.credit_card_rounded,
            color: VerzusColors.accentGreen,
            onTap: _onPaystackDeposit,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodCard(
            title: 'Flutterwave',
            subtitle: 'Multiple payment options',
            icon: Icons.payment_rounded,
            color: VerzusColors.accentOrange,
            onTap: _onFlutterwaveDeposit,
          ),
        ],
      ),
    );
  }

  // ✅ Withdraw Sheet
  Widget _buildWithdrawSheet() {
    final mode = ref.read(walletModeProvider);
    final walletAsync = ref.read(userWalletProvider);
    double available = 0.0;

    // ✅ FIXED: Use whenData properly
    walletAsync.whenData((walletData) {
      if (walletData != null) {
        available = mode == WalletKind.live
            ? (walletData['live_balance'] ?? 0.0)
            : (walletData['demo_balance'] ?? 0.0);
      }
    });

    double withdrawAmount =
        available > 0 ? (available >= 10 ? 10.0 : available) : 0.0;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Withdraw Funds',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Available: ${_formatCurrency(available)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Withdraw Amount',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: '',
                  labelText: 'Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  final v = double.tryParse(value) ?? 0.0;
                  setState(() => withdrawAmount = v);
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Currency',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _withdrawCurrency,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _supportedCurrencies
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _withdrawCurrency = v ?? 'USD'),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        'Amount: ${withdrawAmount.toStringAsFixed(2)} $_withdrawCurrency'),
                    Text(
                        'Fee: ${(withdrawAmount * 0.015).toStringAsFixed(2)} $_withdrawCurrency'),
                    Text(
                        'You receive: ${(withdrawAmount * 0.985).toStringAsFixed(2)} $_withdrawCurrency'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Choose Payout Method',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentMethodCard(
                      title: 'Paystack',
                      subtitle: 'Bank/account payout',
                      icon: Icons.account_balance_rounded,
                      color: VerzusColors.accentGreen,
                      onTap: () => _onRequestWithdrawal(
                          method: 'paystack',
                          amount: withdrawAmount,
                          currency: _withdrawCurrency),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPaymentMethodCard(
                      title: 'Flutterwave',
                      subtitle: 'Bank/mobile money payout',
                      icon: Icons.account_balance_wallet_rounded,
                      color: VerzusColors.accentOrange,
                      onTap: () => _onRequestWithdrawal(
                          method: 'flutterwave',
                          amount: withdrawAmount,
                          currency: _withdrawCurrency),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ Payment Method Card
  Widget _buildPaymentMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Withdrawal Request
  Future<void> _onRequestWithdrawal(
      {required String method,
      required double amount,
      required String currency}) async {
    final userId = _userId;
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to continue'),
          backgroundColor: VerzusColors.dangerRed,
        ),
      );
      return;
    }
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter a valid amount'),
          backgroundColor: VerzusColors.dangerRed,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Confirm Withdrawal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amount: ${amount.toStringAsFixed(2)} $currency'),
              Text('Fee: ${(amount * 0.015).toStringAsFixed(2)} $currency'),
              Text(
                  'You receive: ${(amount * 0.985).toStringAsFixed(2)} $currency'),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
                try {
                  final payment = ref.read(paymentServiceProvider);
                  await payment.requestWithdrawal(
                    userId: userId,
                    amount: amount,
                    method: method,
                    currency: currency,
                    note: 'Standard withdrawal',
                  );
                  // ✅ BULLETPROOF: RELOAD WALLET
                  await ref.read(walletProvider.notifier).loadWallet(userId);
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Withdrawal requested: ${amount.toStringAsFixed(2)} $currency'),
                      backgroundColor: VerzusColors.accentGreen,
                    ),
                  );
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Withdrawal failed: $e'),
                      backgroundColor: VerzusColors.dangerRed,
                    ),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // ✅ Paystack Deposit
  Future<void> _onPaystackDeposit() async {
    final userId = _userId;
    final email = ref.read(authStateProvider).value?.email ?? '';
    if (userId.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to continue'),
          backgroundColor: VerzusColors.dangerRed,
        ),
      );
      return;
    }

    final mode = ref.read(walletModeProvider);
    if (mode == WalletKind.demo) {
      await ref.read(walletProvider.notifier).addDemoFunds(_depositAmount);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Added ${_depositAmount.toStringAsFixed(2)} demo coins'),
            backgroundColor: VerzusColors.accentGreen,
          ),
        );
      }
      return;
    }

    Navigator.of(context).pop();
    final payment = ref.read(paymentServiceProvider);
    try {
      await payment.depositWithPaystack(
        context: context,
        userId: userId,
        email: email,
        amount: _depositAmount,
        currency: _depositCurrency,
        channel: 'card',
      );
      // ✅ BULLETPROOF: RELOAD WALLET
      await ref.read(walletProvider.notifier).loadWallet(userId);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Deposited ${_depositAmount.toStringAsFixed(2)} $_depositCurrency via Paystack'),
          backgroundColor: VerzusColors.accentGreen,
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deposit failed: $e'),
          backgroundColor: VerzusColors.dangerRed,
        ),
      );
    }
  }

  // ✅ Flutterwave Deposit
  Future<void> _onFlutterwaveDeposit() async {
    final userId = _userId;
    final email = ref.read(authStateProvider).value?.email ?? '';
    final name =
        ref.read(currentUserProvider).value?.displayName ?? 'Verzus User';
    if (userId.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to continue'),
          backgroundColor: VerzusColors.dangerRed,
        ),
      );
      return;
    }

    final mode = ref.read(walletModeProvider);
    if (mode == WalletKind.demo) {
      await ref.read(walletProvider.notifier).addDemoFunds(_depositAmount);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Added ${_depositAmount.toStringAsFixed(2)} demo coins'),
            backgroundColor: VerzusColors.accentGreen,
          ),
        );
      }
      return;
    }

    Navigator.of(context).pop();
    final payment = ref.read(paymentServiceProvider);
    try {
      await payment.depositWithFlutterwave(
        context: context,
        userId: userId,
        email: email,
        fullName: name,
        amount: _depositAmount,
        currency: _depositCurrency,
        channel: 'card',
      );
      // ✅ BULLETPROOF: RELOAD WALLET
      await ref.read(walletProvider.notifier).loadWallet(userId);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Deposited ${_depositAmount.toStringAsFixed(2)} $_depositCurrency via Flutterwave'),
          backgroundColor: VerzusColors.accentGreen,
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deposit failed: $e'),
          backgroundColor: VerzusColors.dangerRed,
        ),
      );
    }
  }
}

// ✅ Mode Toggle
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: selected
                // ignore: deprecated_member_use
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
      ),
    );
  }
}

// ✅ Amount Field
class _AmountField extends StatefulWidget {
  final ValueChanged<double> onAmountChanged;
  const _AmountField({required this.onAmountChanged});

  @override
  State<_AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<_AmountField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '10.00');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        prefixText: '',
        labelText: 'Amount',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: (value) {
        final v = double.tryParse(value) ?? 0.0;
        widget.onAmountChanged(v);
      },
    );
  }
}
// -------------------------------------------------------------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:verzus/services/auth_service.dart';
// import 'package:verzus/services/wallet_service.dart';
// import 'package:verzus/services/payment_service.dart';
// import 'package:verzus/providers/firebase_providers.dart';
// import 'package:verzus/theme.dart';
// import 'package:verzus/widgets/verzus_button.dart';
// import 'package:verzus/models/wallet_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class WalletScreen extends ConsumerStatefulWidget {
//   const WalletScreen({super.key});

//   @override
//   ConsumerState<WalletScreen> createState() => _WalletScreenState();
// }

// class _WalletScreenState extends ConsumerState<WalletScreen> with TickerProviderStateMixin {
//   // ✅ BULLETPROOF: Use userId from auth (never null when signed in)
//   String get _userId {
//     final auth = ref.read(authStateProvider).value;
//     if (auth != null) return auth.uid;
//     final model = ref.read(currentUserProvider).value;
//     return model?.uid ?? '';
//   }

//   late TabController _tabController;
//   double _depositAmount = 10.0;
//   String _depositCurrency = 'USD';
//   String _withdrawCurrency = 'USD';
//   final List<String> _supportedCurrencies = ['USD', 'KES', 'NGN', 'GHS'];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     // ✅ BULLETPROOF: Auto-load on init
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_userId.isNotEmpty) {
//         ref.read(walletProvider.notifier).loadWallet(_userId);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isTablet = screenWidth > 600;
    
//     // ✅ BULLETPROOF: Watch STREAM PROVIDER (auto-syncs with Firestore)
//     final walletAsync = ref.watch(userWalletProvider);
//     final mode = ref.watch(walletModeProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Wallet'),
//         elevation: 0,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 12),
//             child: _ModeToggle(
//               mode: mode,
//               onChanged: (v) {
//                 ref.read(walletModeProvider.notifier).setMode(v);
//                 // ✅ BULLETPROOF: RELOAD on mode switch
//                 if (_userId.isNotEmpty) {
//                   ref.read(walletProvider.notifier).loadWallet(_userId);
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // ✅ BULLETPROOF WALLET CARD
//           Container(
//             margin: EdgeInsets.all(isTablet ? 20 : 16),
//             padding: EdgeInsets.all(isTablet ? 24 : 20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [VerzusColors.primaryPurple, VerzusColors.primaryPurpleLight],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: VerzusColors.primaryPurple.withValues(alpha: 0.15),
//                   blurRadius: 20,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//             ),
//             child: walletAsync.when(
//               // ✅ LOADING
//               loading: () => const Center(
//                 child: Padding(
//                   padding: EdgeInsets.all(40),
//                   child: CircularProgressIndicator(color: Colors.white),
//                 ),
//               ),
//               // ✅ ERROR
//               error: (error, _) => _buildErrorCard(error.toString()),
//               // ✅ SUCCESS - BULLETPROOF CALCULATIONS
//               data: (walletData) {
//                 if (walletData == null) {
//                   return _buildEmptyWalletCard();
//                 }
//                 final wallet = WalletModel.fromFirestore(
//                   // Mock document for fromFirestore
//                   (DocumentSnapshot()..id = _userId)..data = () => walletData,
//                 );
                
//                 final total = mode == WalletKind.live
//                     ? wallet.liveTotalFunds()
//                     : wallet.demoTotalFunds();
//                 final available = mode == WalletKind.live 
//                     ? wallet.liveAvailable 
//                     : wallet.demoAvailable;
//                 final pending = mode == WalletKind.live 
//                     ? wallet.pendingBalance 
//                     : wallet.demoPendingBalance;

//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Header
//                     Row(
//                       children: [
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withValues(alpha: 0.2),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             mode == WalletKind.live ? 'LIVE' : 'DEMO',
//                             style: Theme.of(context).textTheme.labelSmall?.copyWith(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w600,
//                               fontSize: 11,
//                             ),
//                           ),
//                         ),
//                         const Spacer(),
//                         GestureDetector(
//                           onTap: () => context.push('/profile'),
//                           child: Container(
//                             width: 36,
//                             height: 36,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withValues(alpha: 0.2),
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
//                             ),
//                             child: const Icon(
//                               Icons.person_outline_rounded,
//                               color: Colors.white,
//                               size: 20,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),

//                     // Total Balance
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Total Balance',
//                           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                             color: Colors.white.withValues(alpha: 0.8),
//                             fontSize: 13,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           _formatCurrency(total),
//                           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             height: 1.1,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),

//                     // Balance Chips
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildCompactBalanceChip(
//                             'Available',
//                             _formatCurrency(available),
//                             Icons.check_circle_outline,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: _buildCompactBalanceChip(
//                             'Pending',
//                             _formatCurrency(pending),
//                             Icons.schedule_outlined,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),

//                     // Action Buttons
//                     Row(
//                       children: [
//                         Expanded(
//                           child: VerzusButton(
//                             size: VerzusButtonSize.small,
//                             onPressed: mode == WalletKind.live 
//                                 ? _showDepositDialog 
//                                 : () async {
//                                     await ref.read(walletProvider.notifier).addDemoFunds(50);
//                                     if (!mounted) return;
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(content: Text('Added 50 demo coins')),
//                                     );
//                                   },
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(mode == WalletKind.live ? Icons.add : Icons.stars, size: 16),
//                                 const SizedBox(width: 4),
//                                 Text(mode == WalletKind.live ? 'Deposit' : 'Demo'),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: VerzusButton.outline(
//                             size: VerzusButtonSize.small,
//                             onPressed: mode == WalletKind.live 
//                                 ? _showWithdrawDialog 
//                                 : () async {
//                                     await ref.read(walletProvider.notifier).resetWallet();
//                                   },
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(mode == WalletKind.live ? Icons.remove : Icons.refresh, size: 16),
//                                 const SizedBox(width: 4),
//                                 Text(mode == WalletKind.live ? 'Withdraw' : 'Reset'),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),

//           // Tabs
//           Container(
//             margin: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.surfaceContainer,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: TabBar(
//               controller: _tabController,
//               labelColor: VerzusColors.primaryPurple,
//               unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
//               indicator: BoxDecoration(
//                 color: VerzusColors.primaryPurple.withValues(alpha: 0.12),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               dividerColor: Colors.transparent,
//               labelStyle: const TextStyle(fontWeight: FontWeight.w600),
//               tabs: const [
//                 Tab(icon: Icon(Icons.receipt_long, size: 20), text: 'Transactions'),
//                 Tab(icon: Icon(Icons.add_circle_outline, size: 20), text: 'Deposits'),
//                 Tab(icon: Icon(Icons.remove_circle_outline, size: 20), text: 'Withdrawals'),
//               ],
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Tab Content
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildTransactionsList(),
//                 _buildDepositsList(),
//                 _buildWithdrawalsList(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ BULLETPROOF: Error Card
//   Widget _buildErrorCard(String error) {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           Icon(Icons.error_outline, color: Colors.white.withValues(alpha: 0.7), size: 48),
//           const SizedBox(height: 16),
//           Text('Wallet Error', style: TextStyle(color: Colors.white, fontSize: 18)),
//           const SizedBox(height: 8),
//           Text(error, style: TextStyle(color: Colors.white.withValues(alpha: 0.7)), textAlign: TextAlign.center),
//           const SizedBox(height: 16),
//           VerzusButton(
//             onPressed: () => ref.read(walletProvider.notifier).loadWallet(_userId),
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ BULLETPROOF: Empty Wallet Card
//   Widget _buildEmptyWalletCard() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           Icon(Icons.wallet_outlined, color: Colors.white.withValues(alpha: 0.7), size: 48),
//           const SizedBox(height: 16),
//           Text('No Wallet', style: TextStyle(color: Colors.white, fontSize: 18)),
//           const SizedBox(height: 8),
//           Text('Create your first deposit', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
//         ],
//       ),
//     );
//   }

//   // ✅ Compact Balance Chip
//   Widget _buildCompactBalanceChip(String label, String value, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.2),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(icon, size: 16, color: Colors.white),
//               const SizedBox(width: 4),
//               Flexible(
//                 child: Text(
//                   value,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 2),
//           Text(
//             label,
//             style: TextStyle(
//               color: Colors.white.withValues(alpha: 0.8),
//               fontSize: 10,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ Formatting
//   String _formatCurrency(double value) => '\$${value.toStringAsFixed(2)}';

//   // ✅ Tab Lists
//   Widget _buildTransactionsList() => ListView(
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//     children: [
//       _buildEmptyState(
//         icon: Icons.receipt_long_rounded,
//         title: 'No Transactions',
//         subtitle: 'Your transaction history will appear here',
//       ),
//     ],
//   );

//   Widget _buildDepositsList() => ListView(
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//     children: [
//       _buildEmptyState(
//         icon: Icons.add_circle_outline_rounded,
//         title: 'No Deposits',
//         subtitle: 'Your deposit history will appear here',
//       ),
//     ],
//   );

//   Widget _buildWithdrawalsList() => ListView(
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//     children: [
//       _buildEmptyState(
//         icon: Icons.remove_circle_outline_rounded,
//         title: 'No Withdrawals',
//         subtitle: 'Your withdrawal history will appear here',
//       ),
//     ],
//   );

//   Widget _buildEmptyState({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.all(40),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.surfaceContainer,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             title,
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Text(
//               subtitle,
//               style: Theme.of(context).textTheme.bodyMedium,
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ Deposit Dialog
//   void _showDepositDialog() {
//     final mode = ref.read(walletModeProvider);
//     if (mode == WalletKind.demo) {
//       showDialog(
//         context: context,
//         builder: (ctx) => AlertDialog(
//           title: const Text('Add Demo Coins'),
//           content: const Text('Demo wallet is for practice only. Add coins to try the experience.'),
//           actions: [
//             TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.of(ctx).pop();
//                 await ref.read(walletProvider.notifier).addDemoFunds(50);
//                 if (!mounted) return;
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Added 50 demo coins')),
//                 );
//               },
//               child: const Text('Add 50'),
//             )
//           ],
//         ),
//       );
//       return;
//     }
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => _buildDepositSheet(),
//     );
//   }

//   // ✅ Withdraw Dialog
//   void _showWithdrawDialog() {
//     final mode = ref.read(walletModeProvider);
//     if (mode == WalletKind.demo) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Withdrawals are disabled in Demo mode')),
//       );
//       return;
//     }
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => _buildWithdrawSheet(),
//     );
//   }

//   // ✅ Deposit Sheet
//   Widget _buildDepositSheet() {
//     return Container(
//       padding: EdgeInsets.only(
//         left: 24,
//         right: 24,
//         top: 24,
//         bottom: MediaQuery.of(context).viewInsets.bottom + 24,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 'Deposit Funds',
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//               const Spacer(),
//               IconButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 icon: const Icon(Icons.close_rounded),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'Deposit Amount',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//           ),
//           const SizedBox(height: 12),
//           _AmountField(onAmountChanged: (v) => _depositAmount = v),
//           const SizedBox(height: 16),
//           Text(
//             'Currency',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//           ),
//           const SizedBox(height: 8),
//           DropdownButtonFormField<String>(
//             value: _depositCurrency,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//               contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             ),
//             items: _supportedCurrencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
//             onChanged: (v) => setState(() => _depositCurrency = v ?? 'USD'),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Choose Payment Method',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//           ),
//           const SizedBox(height: 16),
//           _buildPaymentMethodCard(
//             title: 'Paystack',
//             subtitle: 'Card, Bank Transfer, USSD',
//             icon: Icons.credit_card_rounded,
//             color: VerzusColors.accentGreen,
//             onTap: _onPaystackDeposit,
//           ),
//           const SizedBox(height: 12),
//           _buildPaymentMethodCard(
//             title: 'Flutterwave',
//             subtitle: 'Multiple payment options',
//             icon: Icons.payment_rounded,
//             color: VerzusColors.accentOrange,
//             onTap: _onFlutterwaveDeposit,
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ Withdraw Sheet
//   Widget _buildWithdrawSheet() {
//     final mode = ref.read(walletModeProvider);
//     final walletAsync = ref.read(userWalletProvider);
//     double available = 0.0;
    
//     walletAsync.whenData((walletData) {
//       if (walletData != null) {
//         available = mode == WalletKind.live 
//             ? (walletData['balance'] ?? 0.0).toDouble()
//             : (walletData['demo_balance'] ?? 0.0).toDouble();
//       }
//     });
    
//     double withdrawAmount = available > 0 ? (available >= 10 ? 10.0 : available) : 0.0;

//     return StatefulBuilder(
//       builder: (context, setState) {
//         return Container(
//           padding: EdgeInsets.only(
//             left: 24,
//             right: 24,
//             top: 24,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 24,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     'Withdraw Funds',
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     icon: const Icon(Icons.close_rounded),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Available: ${_formatCurrency(available)}',
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       color: Theme.of(context).colorScheme.onSurfaceVariant,
//                     ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Withdraw Amount',
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                 decoration: InputDecoration(
//                   prefixText: '',
//                   labelText: 'Amount',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onChanged: (value) {
//                   final v = double.tryParse(value) ?? 0.0;
//                   setState(() => withdrawAmount = v);
//                 },
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Currency',
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//               const SizedBox(height: 8),
//               DropdownButtonFormField<String>(
//                 value: _withdrawCurrency,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 ),
//                 items: _supportedCurrencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
//                 onChanged: (v) => setState(() => _withdrawCurrency = v ?? 'USD'),
//               ),
//               const SizedBox(height: 12),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.surfaceContainerHighest,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Summary',
//                       style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 8),
//                     Text('Amount: ${withdrawAmount.toStringAsFixed(2)} $_withdrawCurrency'),
//                     Text('Fee: ${(withdrawAmount * 0.015).toStringAsFixed(2)} $_withdrawCurrency'),
//                     Text('You receive: ${(withdrawAmount * 0.985).toStringAsFixed(2)} $_withdrawCurrency'),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Choose Payout Method',
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildPaymentMethodCard(
//                       title: 'Paystack',
//                       subtitle: 'Bank/account payout',
//                       icon: Icons.account_balance_rounded,
//                       color: VerzusColors.accentGreen,
//                       onTap: () => _onRequestWithdrawal(method: 'paystack', amount: withdrawAmount, currency: _withdrawCurrency),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _buildPaymentMethodCard(
//                       title: 'Flutterwave',
//                       subtitle: 'Bank/mobile money payout',
//                       icon: Icons.account_balance_wallet_rounded,
//                       color: VerzusColors.accentOrange,
//                       onTap: () => _onRequestWithdrawal(method: 'flutterwave', amount: withdrawAmount, currency: _withdrawCurrency),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // ✅ Payment Method Card
//   Widget _buildPaymentMethodCard({
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: color.withValues(alpha: 0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: color.withValues(alpha: 0.3),
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               color: color,
//               size: 24,
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: color,
//                         ),
//                   ),
//                   Text(
//                     subtitle,
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: Theme.of(context).colorScheme.onSurfaceVariant,
//                         ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               color: color,
//               size: 16,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ Withdrawal Request
//   Future<void> _onRequestWithdrawal({required String method, required double amount, required String currency}) async {
//     final userId = _userId;
//     if (userId.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Please sign in to continue'),
//           backgroundColor: VerzusColors.dangerRed,
//         ),
//       );
//       return;
//     }
//     if (amount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Enter a valid amount'),
//           backgroundColor: VerzusColors.dangerRed,
//         ),
//       );
//       return;
//     }

//     await showDialog(
//       context: context,
//       builder: (ctx) {
//         return AlertDialog(
//           title: const Text('Confirm Withdrawal'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Amount: ${amount.toStringAsFixed(2)} $currency'),
//               Text('Fee: ${(amount * 0.015).toStringAsFixed(2)} $currency'),
//               Text('You receive: ${(amount * 0.985).toStringAsFixed(2)} $currency'),
//             ],
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.of(ctx).pop();
//                 Navigator.of(context).pop();
//                 try {
//                   final payment = ref.read(paymentServiceProvider);
//                   await payment.requestWithdrawal(
//                     userId: userId,
//                     amount: amount,
//                     method: method,
//                     currency: currency,
//                     note: 'Standard withdrawal',
//                   );
//                   // ✅ BULLETPROOF: RELOAD WALLET
//                   await ref.read(walletProvider.notifier).loadWallet(userId);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Withdrawal requested: ${amount.toStringAsFixed(2)} $currency'),
//                       backgroundColor: VerzusColors.accentGreen,
//                     ),
//                   );
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Withdrawal failed: $e'),
//                       backgroundColor: VerzusColors.dangerRed,
//                     ),
//                   );
//                 }
//               },
//               child: const Text('Confirm'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ✅ Paystack Deposit
//   Future<void> _onPaystackDeposit() async {
//     final userId = _userId;
//     final email = ref.read(authStateProvider).value?.email ?? '';
//     if (userId.isEmpty || email.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Please sign in to continue'),
//           backgroundColor: VerzusColors.dangerRed,
//         ),
//       );
//       return;
//     }

//     final mode = ref.read(walletModeProvider);
//     if (mode == WalletKind.demo) {
//       await ref.read(walletProvider.notifier).addDemoFunds(_depositAmount);
//       if (mounted) {
//         Navigator.of(context).pop();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Added ${_depositAmount.toStringAsFixed(2)} demo coins'),
//             backgroundColor: VerzusColors.accentGreen,
//           ),
//         );
//       }
//       return;
//     }

//     Navigator.of(context).pop();
//     final payment = ref.read(paymentServiceProvider);
//     try {
//       await payment.depositWithPaystack(
//         context: context,
//         userId: userId,
//         email: email,
//         amount: _depositAmount,
//         currency: _depositCurrency,
//         channel: 'card',
//       );
//       // ✅ BULLETPROOF: RELOAD WALLET
//       await ref.read(walletProvider.notifier).loadWallet(userId);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Deposited ${_depositAmount.toStringAsFixed(2)} $_depositCurrency via Paystack'),
//           backgroundColor: VerzusColors.accentGreen,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Deposit failed: $e'),
//           backgroundColor: VerzusColors.dangerRed,
//         ),
//       );
//     }
//   }

//   // ✅ Flutterwave Deposit
//   Future<void> _onFlutterwaveDeposit() async {
//     final userId = _userId;
//     final email = ref.read(authStateProvider).value?.email ?? '';
//     final name = ref.read(currentUserProvider).value?.displayName ?? 'Verzus User';
//     if (userId.isEmpty || email.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Please sign in to continue'),
//           backgroundColor: VerzusColors.dangerRed,
//         ),
//       );
//       return;
//     }

//     final mode = ref.read(walletModeProvider);
//     if (mode == WalletKind.demo) {
//       await ref.read(walletProvider.notifier).addDemoFunds(_depositAmount);
//       if (mounted) {
//         Navigator.of(context).pop();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Added ${_depositAmount.toStringAsFixed(2)} demo coins'),
//             backgroundColor: VerzusColors.accentGreen,
//           ),
//         );
//       }
//       return;
//     }

//     Navigator.of(context).pop();
//     final payment = ref.read(paymentServiceProvider);
//     try {
//       await payment.depositWithFlutterwave(
//         context: context,
//         userId: userId,
//         email: email,
//         fullName: name,
//         amount: _depositAmount,
//         currency: _depositCurrency,
//         channel: 'card',
//       );
//       // ✅ BULLETPROOF: RELOAD WALLET
//       await ref.read(walletProvider.notifier).loadWallet(userId);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Deposited ${_depositAmount.toStringAsFixed(2)} $_depositCurrency via Flutterwave'),
//           backgroundColor: VerzusColors.accentGreen,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Deposit failed: $e'),
//           backgroundColor: VerzusColors.dangerRed,
//         ),
//       );
//     }
//   }
// }

// // ✅ Mode Toggle
// class _ModeToggle extends StatelessWidget {
//   final WalletKind mode;
//   final ValueChanged<WalletKind> onChanged;
//   const _ModeToggle({required this.mode, required this.onChanged});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surfaceContainerHighest,
//         borderRadius: BorderRadius.circular(999),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _pill(context, label: 'Live', selected: mode == WalletKind.live, onTap: () => onChanged(WalletKind.live)),
//           _pill(context, label: 'Demo', selected: mode == WalletKind.demo, onTap: () => onChanged(WalletKind.demo)),
//         ],
//       ),
//     );
//   }

//   Widget _pill(BuildContext context, {required String label, required bool selected, required VoidCallback onTap}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(999),
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: selected ? VerzusColors.primaryPurple.withValues(alpha: 0.15) : Colors.transparent,
//             borderRadius: BorderRadius.circular(999),
//           ),
//           child: Text(
//             label,
//             style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                   color: selected ? VerzusColors.primaryPurple : Theme.of(context).colorScheme.onSurfaceVariant,
//                   fontWeight: selected ? FontWeight.bold : FontWeight.normal,
//                 ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ✅ Amount Field
// class _AmountField extends StatefulWidget {
//   final ValueChanged<double> onAmountChanged;
//   const _AmountField({required this.onAmountChanged});

//   @override
//   State<_AmountField> createState() => _AmountFieldState();
// }

// class _AmountFieldState extends State<_AmountField> {
//   late final TextEditingController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController(text: '10.00');
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: _controller,
//       keyboardType: const TextInputType.numberWithOptions(decimal: true),
//       decoration: InputDecoration(
//         prefixText: '',
//         labelText: 'Amount',
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//       onChanged: (value) {
//         final v = double.tryParse(value) ?? 0.0;
//         widget.onAmountChanged(v);
//       },
//     );
//   }
// }