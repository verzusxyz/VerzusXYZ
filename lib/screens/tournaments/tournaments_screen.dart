// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:verzus/widgets/app_loading.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:verzus/firestore/firestore_data_schema.dart';
// import 'package:verzus/services/auth_service.dart';
// import 'package:verzus/services/games_service.dart';
// import 'package:verzus/services/wallet_service.dart';
// import 'package:verzus/models/wallet_model.dart';
// import 'package:verzus/theme.dart';
// import 'package:verzus/widgets/verzus_button.dart';
// import 'package:verzus/services/tournament_manager.dart';

// class TournamentsScreen extends ConsumerStatefulWidget {
//   const TournamentsScreen({super.key});

//   @override
//   ConsumerState<TournamentsScreen> createState() => _TournamentsScreenState();
// }

// class _TournamentsScreenState extends ConsumerState<TournamentsScreen>
//     with TickerProviderStateMixin {
//   late TabController _tabController;

//   // Auto-tournament tiers (12 players, 20% platform cut)
//   final List<Map<String, dynamic>> tournamentTiers = [
//     {
//       'entry': '\$2',
//       'players': 12,
//       'prize': '\$19.20',
//       'color': VerzusColors.accentGreen,
//     },
//     {
//       'entry': '\$5',
//       'players': 12,
//       'prize': '\$48.00',
//       'color': VerzusColors.primaryPurple,
//     },
//     {
//       'entry': '\$10',
//       'players': 12,
//       'prize': '\$96.00',
//       'color': VerzusColors.accentOrange,
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Widget _buildErrorNotice(BuildContext context, Object error, {bool compact = false}) {
//     final theme = Theme.of(context);
//     final message = error.toString().trim().isEmpty
//         ? 'Unable to load data. Please try again.'
//         : error.toString();
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(compact ? 8 : 16),
//         child: Text(
//           message,
//           textAlign: TextAlign.center,
//           style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Tournaments'),
//         actions: [
//           Consumer(builder: (context, ref, _) {
//             final mode = ref.watch(walletModeProvider);
//             return Padding(
//               padding: const EdgeInsets.only(right: 12),
//               child: _ModeToggleChip(
//                 mode: mode,
//                 onChanged: (v) => ref.read(walletModeProvider.notifier).setMode(v),
//               ),
//             );
//           })
//         ],
//       ),
//       body: Column(
//         children: [
//           // Tab Bar
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 16),
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.surfaceContainerHighest,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: TabBar(
//               controller: _tabController,
//               tabs: const [
//                 Tab(text: 'Auto-Tournaments'),
//                 Tab(text: 'Create Tournament'),
//                 Tab(text: 'Join Tournament'),
//                 Tab(text: 'Live Tournaments'),
//               ],
//               labelColor: VerzusColors.primaryPurple,
//               unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
//               indicator: BoxDecoration(
//                 color: VerzusColors.primaryPurple.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               dividerColor: Colors.transparent,
//             ),
//           ),
//           const SizedBox(height: 20),
//           // Tab Views
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildAutoTournaments(),
//                 _buildCreateTournament(),
//                 _buildJoinTournament(),
//                 _buildLiveTournaments(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAutoTournaments() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Auto Tournament Info
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   VerzusColors.accentOrange.withValues(alpha: 0.1),
//                   VerzusColors.accentOrange.withValues(alpha: 0.05),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: VerzusColors.accentOrange.withValues(alpha: 0.2),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.emoji_events_rounded,
//                       color: VerzusColors.accentOrange,
//                       size: 24,
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       'Auto Tournaments',
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                             color: VerzusColors.accentOrange,
//                             fontWeight: FontWeight.bold,
//                           ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Fixed entry tiers • 12-player brackets • Auto-generated when full',
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         color: Theme.of(context).colorScheme.onSurfaceVariant,
//                       ),
//                 ),
//                 const SizedBox(height: 12),
//                 _buildPayoutStructure(),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'Available Tiers',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//           ),
//           const SizedBox(height: 16),
//           // Tournament Tier Cards
//           ...tournamentTiers.map((tier) => _buildTournamentTierCard(tier)).toList(),
//           const SizedBox(height: 100), // Bottom padding
//         ],
//       ),
//     );
//   }

//   Widget _buildPayoutStructure() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.black.withValues(alpha: 0.05),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Prize Distribution (after 20% platform cut)',
//             style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               _buildPayoutItem('1st', '50%', VerzusColors.accentOrange),
//               const SizedBox(width: 16),
//               _buildPayoutItem('2nd', '30%', VerzusColors.primaryPurple),
//               const SizedBox(width: 16),
//               _buildPayoutItem('3rd', '20%', VerzusColors.accentGreen),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPayoutItem(String position, String percentage, Color color) {
//     return Row(
//       children: [
//         Container(
//           width: 8,
//           height: 8,
//           decoration: BoxDecoration(
//             color: color,
//             shape: BoxShape.circle,
//           ),
//         ),
//         const SizedBox(width: 6),
//         Text(
//           '$position: $percentage',
//           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTournamentTierCard(Map<String, dynamic> tier) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: (tier['color'] as Color).withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: (tier['color'] as Color).withValues(alpha: 0.3),
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: tier['color'],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   tier['entry'] as String,
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '${tier['players']} Players',
//                       style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                     ),
//                     Text(
//                       'Prize Pool: ${tier['prize']}',
//                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                             color: Theme.of(context).colorScheme.onSurfaceVariant,
//                           ),
//                     ),
//                   ],
//                 ),
//               ),
//               VerzusButton(
//                 onPressed: () => _showJoinTournamentDialog(tier),
//                 size: VerzusButtonSize.medium,
//                 child: const Text('Join'),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           _buildTournamentStatus(),
//         ],
//       ),
//     );
//   }

//   Widget _buildTournamentStatus() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.black.withValues(alpha: 0.05),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             Icons.people_rounded,
//             size: 16,
//             color: Theme.of(context).colorScheme.onSurfaceVariant,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             'Waiting for players • 0/12 joined',
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: Theme.of(context).colorScheme.onSurfaceVariant,
//                 ),
//           ),
//           const Spacer(),
//           Container(
//             width: 8,
//             height: 8,
//             decoration: const BoxDecoration(
//               color: VerzusColors.accentGreen,
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Text(
//             'Open',
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: VerzusColors.accentGreen,
//                   fontWeight: FontWeight.w600,
//                 ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCreateTournament() {
//     // Inline advanced creation form (no more bottom sheet) to make all options visible
//     final mode = ref.watch(walletModeProvider);
//     final titleCtrl = TextEditingController();
//     final entryCtrl = TextEditingController(text: '5.00');
//     String bracketType = 'single_elim';
//     final maxCtrl = TextEditingController(text: '12');
//     bool startNow = true;
//     DateTime? scheduledAt;
//     String payoutMode = 'top3';
//     final customPayoutCtrl = TextEditingController(text: '50,30,20');
//     String visibility = 'public';
//     int bestOf = 1;
//     final checkinCtrl = TextEditingController(text: '15');
//     final deadlineCtrl = TextEditingController(text: '60');
//     String? selectedGameId;

//     Future<void> pickDateTime(StateSetter setStateLocal) async {
//       final now = DateTime.now();
//       final date = await showDatePicker(
//         context: context,
//         initialDate: now,
//         firstDate: now,
//         lastDate: DateTime(now.year + 2),
//       );
//       if (date == null) return;
//       final time = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//       );
//       if (time == null) return;
//       final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
//       setStateLocal(() => scheduledAt = dt);
//     }

//    return StatefulBuilder(
//       builder: (context, setStateLocal) {
//         return SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Text('Create Tournament',
//                       style: Theme.of(context)
//                           .textTheme
//                           .titleMedium
//                           ?.copyWith(fontWeight: FontWeight.bold)),
//                   const Spacer(),
//                   _ModeToggleChip(
//                     mode: mode,
//                     onChanged: (v) => ref.read(walletModeProvider.notifier).setMode(v),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               // Game selection
//               Consumer(builder: (context, ref, _) {
//                 final gamesAsync = ref.watch(gamesStreamProvider);
//                 return gamesAsync.when(
//                   data: (games) => DropdownButtonFormField<String>(
//                     value: selectedGameId,
//                     items: games
//                         .map((g) => DropdownMenuItem<String>(
//                               value: g.gameId,
//                               child: Text(g.title, overflow: TextOverflow.ellipsis),
//                             ))
//                         .toList(),
//                     onChanged: (v) => setStateLocal(() => selectedGameId = v),
//                     decoration: InputDecoration(
//                       labelText: 'Game',
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                     ),
//                   ),
//                   loading: () => const LinearProgressIndicator(minHeight: 2),
//                   error: (e, _) => _buildErrorNotice(context, e, compact: true),
//                 );
//               }),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: titleCtrl,
//                 decoration: InputDecoration(
//                   labelText: 'Title',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: entryCtrl,
//                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                 decoration: InputDecoration(
//                   labelText: 'Entry Fee (USD)',
//                   prefixText: '\$',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               // Type
//               DropdownButtonFormField<String>(
//                 value: bracketType,
//                 items: const [
//                   DropdownMenuItem(value: 'single_elim', child: Text('Single Elimination')),
//                   DropdownMenuItem(value: 'double_elim', child: Text('Double Elimination')),
//                   DropdownMenuItem(value: 'round_robin', child: Text('Round Robin')),
//                   DropdownMenuItem(value: 'pools_knockout', child: Text('Pools + Knockouts')),
//                 ],
//                 onChanged: (v) => setStateLocal(() => bracketType = v ?? 'single_elim'),
//                 decoration: InputDecoration(
//                   labelText: 'Tournament type',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               // Visibility
//               DropdownButtonFormField<String>(
//                 value: visibility,
//                 items: const [
//                   DropdownMenuItem(value: 'public', child: Text('Public')),
//                   DropdownMenuItem(value: 'private', child: Text('Private')),
//                 ],
//                 onChanged: (v) => setStateLocal(() => visibility = v ?? 'public'),
//                 decoration: InputDecoration(
//                   labelText: 'Visibility',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               // Max participants
//               TextField(
//                 controller: maxCtrl,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   labelText: 'Bracket size (participants)',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               // Best of
//               DropdownButtonFormField<int>(
//                 value: bestOf,
//                 items: const [
//                   DropdownMenuItem(value: 1, child: Text('Single game')),
//                   DropdownMenuItem(value: 3, child: Text('Best of 3')),
//                   DropdownMenuItem(value: 5, child: Text('Best of 5')),
//                 ],
//                 onChanged: (v) => setStateLocal(() => bestOf = v ?? 1),
//                 decoration: InputDecoration(
//                   labelText: 'Match format',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               // Deadlines
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: checkinCtrl,
//                       keyboardType: TextInputType.number,
//                       decoration: InputDecoration(
//                         labelText: 'Check-in deadline (mins)',
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: TextField(
//                       controller: deadlineCtrl,
//                       keyboardType: TextInputType.number,
//                       decoration: InputDecoration(
//                         labelText: 'Match deadline (mins)',
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               // Payout mode
//               DropdownButtonFormField<String>(
//                 value: payoutMode,
//                 items: const [
//                   DropdownMenuItem(value: 'winner_takes_all', child: Text('Winner takes all')),
//                   DropdownMenuItem(value: 'top3', child: Text('Top 3 (50/30/20)')),
//                   DropdownMenuItem(value: 'custom', child: Text('Custom ratios')),
//                 ],
//                 onChanged: (v) => setStateLocal(() => payoutMode = v ?? 'top3'),
//                 decoration: InputDecoration(
//                   labelText: 'Payout mode',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               if (payoutMode == 'custom') ...[
//                 const SizedBox(height: 8),
//                 TextField(
//                   controller: customPayoutCtrl,
//                   decoration: InputDecoration(
//                     labelText: 'Custom ratios (comma-separated, e.g., 60,25,15)',
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                 ),
//               ],
//               const SizedBox(height: 12),
//               // Start time
//               Row(
//                 children: [
//                   Switch(
//                     value: startNow,
//                     onChanged: (v) => setStateLocal(() => startNow = v),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(startNow ? 'Start now' : 'Scheduled start'),
//                   const Spacer(),
//                   if (!startNow)
//                     TextButton.icon(
//                       onPressed: () => pickDateTime(setStateLocal),
//                       icon: const Icon(Icons.calendar_today_rounded),
//                       label: Text(
//                         scheduledAt != null ? '${scheduledAt!.toLocal()}' : 'Pick date & time',
//                       ),
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 width: double.infinity,
//                 child: VerzusButton(
//                   onPressed: () async {
//                     final title = titleCtrl.text.trim();
//                     final entry = double.tryParse(entryCtrl.text) ?? 0.0; // Optional entry
//                     final auth = ref.read(authStateProvider).value;
//                     if (title.isEmpty || auth == null || selectedGameId == null) return;
//                     final maxP = int.tryParse(maxCtrl.text) ?? 12;
//                     try {
//                       Map<String, num>? ratios;
//                       if (payoutMode == 'custom') {
//                         final parts = customPayoutCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
//                         if (parts.isNotEmpty) {
//                           ratios = {};
//                           for (int i = 0; i < parts.length; i++) {
//                             final val = num.tryParse(parts[i]);
//                             if (val == null) continue;
//                             ratios!['${i + 1}'] = val;
//                           }
//                         }
//                       }
//                       await ref.read(tournamentManagerProvider).createTournament(
//                         creatorId: auth.uid,
//                         title: title,
//                         entryFee: entry,
//                         walletKind: mode == WalletKind.demo ? 'demo' : 'live',
//                         gameId: selectedGameId!,
//                         skillTopic: 'general',
//                         maxParticipants: maxP,
//                         tournamentType: bracketType,
//                         visibility: visibility,
//                         payoutMode: payoutMode,
//                         payoutRatios: ratios,
//                         matchBestOf: bestOf,
//                         checkinDeadlineMins: int.tryParse(checkinCtrl.text) ?? 15,
//                         matchDeadlineMins: int.tryParse(deadlineCtrl.text) ?? 60,
//                         startDate: startNow ? DateTime.now() : scheduledAt,
//                       );
//                       if (mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text("Tournament created (${mode == WalletKind.demo ? 'Demo' : 'Live'})")),
//                         );
//                         // Optionally switch to Join tab
//                         _tabController.animateTo(2);
//                       }
//                     } catch (e) {
//                       if (mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text('Failed: $e'),
//                             backgroundColor: VerzusColors.dangerRed,
//                           ),
//                         );
//                       }
//                     }
//                   },
//                   child: const Text('Create'),
//                 ),
//               ),
//               const SizedBox(height: 100),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildJoinTournament() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//         stream: FirebaseFirestore.instance
//             .collection(FirestoreSchema.tournaments)
//             .where(TournamentDocument.status, isEqualTo: FirestoreConstants.tournamentStatusOpen)
//             .orderBy(TournamentDocument.startDate)
//             .limit(50)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: AppLoading(label: 'Loading tournaments...'));
//           }
//           final docs = snapshot.data!.docs;
//           if (docs.isEmpty) {
//             return _buildEmptyState(
//               icon: Icons.how_to_reg_rounded,
//               title: 'Join Tournament',
//               subtitle: 'Open tournaments from the community will appear here',
//             );
//           }
//           return ListView.separated(
//             itemCount: docs.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 12),
//             itemBuilder: (context, index) {
//               final t = docs[index].data();
//               final joined = (t[TournamentDocument.currentParticipants] ?? 0) as int;
//               final maxP = (t[TournamentDocument.maxParticipants] ?? 0) as int;
//               final entry = (t[TournamentDocument.entryFee] ?? 0.0).toDouble();
//               final walletKind = (t[TournamentDocument.walletKind] ?? 'live') as String;
//               return Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.surfaceContainerHighest,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             t[TournamentDocument.title] ?? 'Tournament',
//                             style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             'Entry: ${entry > 0 ? '\$' + entry.toStringAsFixed(2) : 'Free'} • ${t[TournamentDocument.tournamentType]} • $joined/$maxP',
//                             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                                   color: Theme.of(context).colorScheme.onSurfaceVariant,
//                                 ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     VerzusButton(
//                       onPressed: () async {
//                         final auth = ref.read(authStateProvider).value;
//                         if (auth == null) return;
//                         try {
//                           await ref.read(tournamentManagerProvider).joinTournament(
//                             tournamentId: t[TournamentDocument.id] as String,
//                             userId: auth.uid,
//                           );
//                           if (mounted) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text("Joined ${t[TournamentDocument.title]} (${walletKind == 'demo' ? 'Demo' : 'Live'})")),
//                             );
//                           }
//                         } catch (e) {
//                           if (mounted) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text('Failed to join: $e'),
//                                 backgroundColor: VerzusColors.dangerRed,
//                               ),
//                             );
//                           }
//                         }
//                       },
//                       size: VerzusButtonSize.small,
//                       child: const Text('Join'),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildLiveTournaments() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: _buildEmptyState(
//         icon: Icons.live_tv_rounded,
//         title: 'Live Tournaments',
//         subtitle:
//             'Ongoing tournaments will appear here. Staking is supported similar to matches.',
//       ),
//     );
//   }

//   Widget _buildEmptyState({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     String? buttonText,
//     VoidCallback? onButtonPressed,
//   }) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon,
//             size: 64,
//             color: Theme.of(context)
//                 .colorScheme
//                 .onSurfaceVariant
//                 .withValues(alpha: 0.5),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             title,
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   color: Theme.of(context).colorScheme.onSurfaceVariant,
//                   fontWeight: FontWeight.w600,
//                 ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             subtitle,
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: Theme.of(context)
//                       .colorScheme
//                       .onSurfaceVariant
//                       .withValues(alpha: 0.7),
//                 ),
//             textAlign: TextAlign.center,
//           ),
//           if (buttonText != null && onButtonPressed != null) ...[
//             const SizedBox(height: 24),
//             VerzusButton.outline(
//               onPressed: onButtonPressed,
//               child: Text(buttonText),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   void _showJoinTournamentDialog(Map<String, dynamic> tier) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Join ${tier['entry']} Tournament'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Entry Fee: ${tier['entry']}'),
//             Text('Players: ${tier['players']}'),
//             Text('Prize Pool: ${tier['prize']}'),
//             const SizedBox(height: 12),
//             Text(
//               'Auto brackets fill at 12 players. You can join now; we\'ll place you in the next bracket for this tier.',
//               style: Theme.of(context).textTheme.bodySmall,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.of(context).pop();
//               final auth = ref.read(authStateProvider).value;
//               if (auth == null) return;
//               final s = (tier['entry'] as String);
//               final entry = double.tryParse(s.startsWith('\$') ? s.substring(1) : s) ?? 0.0;
//               final mode = ref.read(walletModeProvider);
//               try {
//                 if (entry > 0) {
//                   await ref.read(walletServiceProvider).lockFunds(auth.uid, entry, kind: mode);
//                 }
//                 final refCol = FirebaseFirestore.instance.collection('tournament_waitlist');
//                 await refCol.add({
//                   'user_id': auth.uid,
//                   'tier': tier['entry'],
//                   'entry_fee': entry,
//                   'wallet_kind': mode == WalletKind.demo ? 'demo' : 'live',
//                   'created_at': FieldValue.serverTimestamp(),
//                 });
//                 if (mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Joined waitlist for ${tier['entry']} tier (${mode == WalletKind.demo ? 'Demo' : 'Live'})'),
//                       backgroundColor: VerzusColors.accentGreen,
//                     ),
//                   );
//                 }
//               } catch (e) {
//                 if (mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Failed to join: $e'),
//                       backgroundColor: VerzusColors.dangerRed,
//                     ),
//                   );
//                 }
//               }
//             },
//             child: const Text('Join'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showCreateTournamentSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         final titleCtrl = TextEditingController();
//         final entryCtrl = TextEditingController(text: '5.00');
//         String bracketType = 'single_elim';
//         final maxCtrl = TextEditingController(text: '12');
//         bool startNow = true;
//         DateTime? scheduledAt;
//         String payoutMode = 'top3';
//         final customPayoutCtrl = TextEditingController(text: '50,30,20');
//         String visibility = 'public';
//         int bestOf = 1;
//         final checkinCtrl = TextEditingController(text: '15');
//         final deadlineCtrl = TextEditingController(text: '60');
//         String? selectedGameId;

//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             Future<void> pickDateTime() async {
//               final now = DateTime.now();
//               final date = await showDatePicker(
//                 context: context,
//                 initialDate: now,
//                 firstDate: now,
//                 lastDate: DateTime(now.year + 2),
//               );
//               if (date == null) return;
//               final time = await showTimePicker(
//                 context: context,
//                 initialTime: TimeOfDay.now(),
//               );
//               if (time == null) return;
//               final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
//               setModalState(() => scheduledAt = dt);
//             }

//             final mode = ref.read(walletModeProvider);

//             return Padding(
//               padding: EdgeInsets.only(
//                 left: 24,
//                 right: 24,
//                 top: 24,
//                 bottom: MediaQuery.of(context).viewInsets.bottom + 24,
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           'Create Tournament',
//                           style: Theme.of(context)
//                               .textTheme
//                               .titleLarge
//                               ?.copyWith(fontWeight: FontWeight.bold),
//                         ),
//                         const Spacer(),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: Theme.of(context).colorScheme.surfaceContainerHighest,
//                             borderRadius: BorderRadius.circular(999),
//                           ),
//                           child: Text(
//                             mode == WalletKind.live ? 'Live' : 'Demo',
//                             style: Theme.of(context).textTheme.labelSmall,
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: () => Navigator.of(context).pop(),
//                           icon: const Icon(Icons.close_rounded),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     // Game selection
//                     Consumer(builder: (context, ref, _) {
//                       final gamesAsync = ref.watch(gamesStreamProvider);
//                       return gamesAsync.when(
//                         data: (games) => DropdownButtonFormField<String>(
//                           value: selectedGameId,
//                           items: games
//                               .map((g) => DropdownMenuItem<String>(
//                                     value: g.gameId,
//                                     child: Text(g.title, overflow: TextOverflow.ellipsis),
//                                   ))
//                               .toList(),
//                           onChanged: (v) => setModalState(() => selectedGameId = v),
//                           decoration: InputDecoration(
//                             labelText: 'Game',
//                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                           ),
//                         ),
//                         loading: () => const LinearProgressIndicator(minHeight: 2),
//                         error: (e, _) => _buildErrorNotice(context, e, compact: true),
//                       );
//                     }),
//                     const SizedBox(height: 12),
//                     TextField(
//                       controller: titleCtrl,
//                       decoration: InputDecoration(
//                         labelText: 'Title',
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     TextField(
//                       controller: entryCtrl,
//                       keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                       decoration: InputDecoration(
//                         labelText: 'Entry Fee (USD)',
//                         prefixText: '\$',
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     // Type
//                     DropdownButtonFormField<String>(
//                       value: bracketType,
//                       items: const [
//                         DropdownMenuItem(value: 'single_elim', child: Text('Single Elimination')),
//                         DropdownMenuItem(value: 'double_elim', child: Text('Double Elimination')),
//                         DropdownMenuItem(value: 'round_robin', child: Text('Round Robin')),
//                         DropdownMenuItem(value: 'pools_knockout', child: Text('Pools + Knockouts')),
//                       ],
//                       onChanged: (v) => setModalState(() => bracketType = v ?? 'single_elim'),
//                       decoration: InputDecoration(
//                         labelText: 'Tournament type',
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     // Visibility
//                     DropdownButtonFormField<String>(
//                       value: visibility,
//                       items: const [
//                         DropdownMenuItem(value: 'public', child: Text('Public')),
//                         DropdownMenuItem(value: 'private', child: Text('Private')),
//                       ],
//                       onChanged: (v) => setModalState(() => visibility = v ?? 'public'),
//                       decoration: InputDecoration(
//                         labelText: 'Visibility',
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     // Max participants
//                     TextField(
//                       controller: maxCtrl,
//                       keyboardType: TextInputType.number,
//                       decoration: InputDecoration(
//                         labelText: 'Bracket size (participants)',
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     // Best of
//                     DropdownButtonFormField<int>(
//                       value: bestOf,
//                       items: const [
//                         DropdownMenuItem(value: 1, child: Text('Single game')),
//                         DropdownMenuItem(value: 3, child: Text('Best of 3')),
//                         DropdownMenuItem(value: 5, child: Text('Best of 5')),
//                       ],
//                       onChanged: (v) => setModalState(() => bestOf = v ?? 1),
//                       decoration: InputDecoration(
//                         labelText: 'Match format',
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     // Deadlines
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextField(
//                             controller: checkinCtrl,
//                             keyboardType: TextInputType.number,
//                             decoration: InputDecoration(
//                               labelText: 'Check-in deadline (mins)',
//                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: TextField(
//                             controller: deadlineCtrl,
//                             keyboardType: TextInputType.number,
//                             decoration: InputDecoration(
//                               labelText: 'Match deadline (mins)',
//                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     // Payout mode
//                     DropdownButtonFormField<String>(
//                       value: payoutMode,
//                       items: const [
//                         DropdownMenuItem(value: 'winner_takes_all', child: Text('Winner takes all')),
//                         DropdownMenuItem(value: 'top3', child: Text('Top 3 (50/30/20)')),
//                         DropdownMenuItem(value: 'custom', child: Text('Custom ratios')),
//                       ],
//                       onChanged: (v) => setModalState(() => payoutMode = v ?? 'top3'),
//                       decoration: InputDecoration(
//                         labelText: 'Payout mode',
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                     if (payoutMode == 'custom') ...[
//                       const SizedBox(height: 8),
//                       TextField(
//                         controller: customPayoutCtrl,
//                         decoration: InputDecoration(
//                           labelText: 'Custom ratios (comma-separated, e.g., 60,25,15)',
//                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                       ),
//                     ],
//                     const SizedBox(height: 12),
//                     // Start time
//                     Row(
//                       children: [
//                         Switch(
//                           value: startNow,
//                           onChanged: (v) => setModalState(() => startNow = v),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(startNow ? 'Start now' : 'Scheduled start'),
//                         const Spacer(),
//                         if (!startNow)
//                           TextButton.icon(
//                             onPressed: pickDateTime,
//                             icon: const Icon(Icons.calendar_today_rounded),
//                             label: Text(
//                               scheduledAt != null ? '${scheduledAt!.toLocal()}' : 'Pick date & time',
//                             ),
//                           ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     SizedBox(
//                       width: double.infinity,
//                       child: VerzusButton(
//                         onPressed: () async {
//                           final title = titleCtrl.text.trim();
//                           final entry = double.tryParse(entryCtrl.text) ?? 0.0; // Optional entry
//                           final auth = ref.read(authStateProvider).value;
//                           if (title.isEmpty || auth == null || selectedGameId == null) return;
//                           final maxP = int.tryParse(maxCtrl.text) ?? 12;
//                           try {
//                             Map<String, num>? ratios;
//                             if (payoutMode == 'custom') {
//                               final parts = customPayoutCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
//                               if (parts.isNotEmpty) {
//                                 ratios = {};
//                                 for (int i = 0; i < parts.length; i++) {
//                                   final val = num.tryParse(parts[i]);
//                                   if (val == null) continue;
//                                   ratios!['${i + 1}'] = val;
//                                 }
//                               }
//                             }
//                             await ref.read(tournamentManagerProvider).createTournament(
//                               creatorId: auth.uid,
//                               title: title,
//                               entryFee: entry,
//                               walletKind: mode == WalletKind.demo ? 'demo' : 'live',
//                               gameId: selectedGameId!,
//                               skillTopic: 'general',
//                               maxParticipants: maxP,
//                               tournamentType: bracketType,
//                               visibility: visibility,
//                               payoutMode: payoutMode,
//                               payoutRatios: ratios,
//                               matchBestOf: bestOf,
//                               checkinDeadlineMins: int.tryParse(checkinCtrl.text) ?? 15,
//                               matchDeadlineMins: int.tryParse(deadlineCtrl.text) ?? 60,
//                               startDate: startNow ? DateTime.now() : scheduledAt,
//                             );
//                             if (mounted) {
//                               Navigator.of(context).pop();
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text("Tournament created (${mode == WalletKind.demo ? 'Demo' : 'Live'})")),
//                               );
//                             }
//                           } catch (e) {
//                             if (mounted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text('Failed: $e'),
//                                   backgroundColor: VerzusColors.dangerRed,
//                                 ),
//                               );
//                             }
//                           }
//                         },
//                         child: const Text('Create'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

// class _ModeToggleChip extends StatelessWidget {
//   final WalletKind mode;
//   final ValueChanged<WalletKind> onChanged;
//   const _ModeToggleChip({required this.mode, required this.onChanged});

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

// class _CreateTournamentForm extends ConsumerWidget {
//   final VoidCallback onSubmit;
//   const _CreateTournamentForm({required this.onSubmit});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final titleCtrl = TextEditingController();
//     final entryCtrl = TextEditingController(text: '5.00');
//     final rulesCtrl = TextEditingController();
//     String? selectedGameId;

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surfaceContainerHighest,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Consumer(builder: (context, ref, _) {
//             final gamesAsync = ref.watch(gamesStreamProvider);
//             return gamesAsync.when(
//               data: (games) => DropdownButtonFormField<String>(
//                 value: selectedGameId,
//                 items: games
//                     .map((g) => DropdownMenuItem<String>(
//                           value: g.gameId,
//                           child: Text(
//                             g.title,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ))
//                     .toList(),
//                 onChanged: (v) {
//                   selectedGameId = v;
//                   (context as Element).markNeedsBuild();
//                 },
//                 decoration: InputDecoration(
//                   labelText: 'Game',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//               loading: () => const LinearProgressIndicator(minHeight: 2),
//               error: (e, _) => Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8),
//                   child: Text(
//                     e.toString().trim().isEmpty ? 'Unable to load games.' : e.toString(),
//                     textAlign: TextAlign.center,
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                           color: Theme.of(context).colorScheme.error,
//                         ),
//                   ),
//                 ),
//               ),
//             );
//           }),
//           const SizedBox(height: 12),
//           TextField(
//             controller: titleCtrl,
//             decoration: InputDecoration(
//               labelText: 'Title',
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//           ),
//           const SizedBox(height: 12),
//           TextField(
//             controller: entryCtrl,
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             decoration: InputDecoration(
//               labelText: 'Entry Fee (USD)',
//               prefixText: '\$',
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//           ),
//           const SizedBox(height: 12),
//           TextField(
//             controller: rulesCtrl,
//             decoration: InputDecoration(
//               labelText: 'Rules (points, rounds, winners)',
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             minLines: 2,
//             maxLines: 4,
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             width: double.infinity,
//             child: VerzusButton(
//               onPressed: () {
//                 onSubmit();
//               },
//               child: const Text('Create Tournament'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:verzus/widgets/app_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';
import 'package:verzus/services/auth_service.dart';
import 'package:verzus/services/games_service.dart';
import 'package:verzus/services/wallet_service.dart';
import 'package:verzus/models/wallet_model.dart';
import 'package:verzus/theme.dart';
import 'package:verzus/widgets/verzus_button.dart';
import 'package:verzus/services/tournament_manager.dart';

class TournamentsScreen extends ConsumerStatefulWidget {
  const TournamentsScreen({super.key});

  @override
  ConsumerState<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends ConsumerState<TournamentsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Auto-tournament tiers (12 players, 20% platform cut)
  final List<Map<String, dynamic>> tournamentTiers = [
    {
      'entry': '\$2',
      'players': 12,
      'prize': '\$19.20',
      'color': VerzusColors.accentGreen,
    },
    {
      'entry': '\$5',
      'players': 12,
      'prize': '\$48.00',
      'color': VerzusColors.primaryPurple,
    },
    {
      'entry': '\$10',
      'players': 12,
      'prize': '\$96.00',
      'color': VerzusColors.accentOrange,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Reduced tabs to 3 (removed Create Tournament tab)
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildErrorNotice(BuildContext context, Object error,
      {bool compact = false}) {
    final theme = Theme.of(context);
    final message = error.toString().trim().isEmpty
        ? 'Oops! Something went wrong. Please try again.'
        : error.toString();
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 8 : 16),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
            fontSize: compact ? 14 : 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournaments'),
        actions: [
          Consumer(builder: (context, ref, _) {
            final mode = ref.watch(walletModeProvider);
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  _ModeToggleChip(
                    mode: mode,
                    onChanged: (v) =>
                        ref.read(walletModeProvider.notifier).setMode(v),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: VerzusColors.primaryPurple),
                    onPressed: _showCreateTournamentDialog,
                    tooltip: 'Create Tournament',
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Tab Bar
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: isWideScreen ? constraints.maxWidth * 0.1 : 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Auto-Tournaments'),
                    Tab(text: 'Join Tournament'),
                    Tab(text: 'Live Tournaments'),
                  ],
                  labelColor: VerzusColors.primaryPurple,
                  unselectedLabelColor:
                      Theme.of(context).colorScheme.onSurfaceVariant,
                  indicator: BoxDecoration(
                    color: VerzusColors.primaryPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  dividerColor: Colors.transparent,
                  padding: const EdgeInsets.all(4),
                  labelStyle: TextStyle(
                    fontSize: isWideScreen ? 16 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAutoTournaments(),
                    _buildJoinTournament(),
                    _buildLiveTournaments(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAutoTournaments() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isWideScreen = screenWidth > 600;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWideScreen ? screenWidth * 0.1 : 16,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Auto Tournament Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      VerzusColors.accentOrange.withValues(alpha: 0.1),
                      VerzusColors.accentOrange.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: VerzusColors.accentOrange.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events_rounded,
                          color: VerzusColors.accentOrange,
                          size: isWideScreen ? 28 : 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Auto Tournaments',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: VerzusColors.accentOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isWideScreen ? 20 : 18,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fixed entry tiers • 12-player brackets • Auto-generated when full',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: isWideScreen ? 16 : 14,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildPayoutStructure(isWideScreen: isWideScreen),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Available Tiers',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isWideScreen ? 20 : 18,
                    ),
              ),
              const SizedBox(height: 16),
              // Tournament Tier Cards
              ...tournamentTiers
                  .asMap()
                  .entries
                  .map(
                    (entry) => _buildTournamentTierCard(
                      entry.value,
                      index: entry.key,
                      isWideScreen: isWideScreen,
                    ),
                  )
                  // ignore: unnecessary_to_list_in_spreads
                  .toList(),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPayoutStructure({required bool isWideScreen}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prize Distribution (after 20% platform cut)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isWideScreen ? 16 : 14,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPayoutItem(
                '1st',
                '50%',
                VerzusColors.accentOrange,
                isWideScreen: isWideScreen,
              ),
              _buildPayoutItem(
                '2nd',
                '30%',
                VerzusColors.primaryPurple,
                isWideScreen: isWideScreen,
              ),
              _buildPayoutItem(
                '3rd',
                '20%',
                VerzusColors.accentGreen,
                isWideScreen: isWideScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutItem(
    String position,
    String percentage,
    Color color, {
    required bool isWideScreen,
  }) {
    return Row(
      children: [
        Container(
          width: isWideScreen ? 10 : 8,
          height: isWideScreen ? 10 : 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$position: $percentage',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: isWideScreen ? 14 : 12,
              ),
        ),
      ],
    );
  }

  Widget _buildTournamentTierCard(
    Map<String, dynamic> tier, {
    required int index,
    required bool isWideScreen,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isWideScreen ? 24 : 20),
      decoration: BoxDecoration(
        color: (tier['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (tier['color'] as Color).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isWideScreen ? 16 : 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: tier['color'],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tier['entry'] as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isWideScreen ? 18 : 16,
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${tier['players']} Players',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isWideScreen ? 16 : 14,
                          ),
                    ),
                    Text(
                      'Prize Pool: ${tier['prize']}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: isWideScreen ? 14 : 12,
                          ),
                    ),
                  ],
                ),
              ),
              VerzusButton(
                onPressed: () => _showJoinTournamentDialog(tier),
                size: isWideScreen
                    ? VerzusButtonSize.large
                    : VerzusButtonSize.medium,
                child: const Text('Join'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTournamentStatus(isWideScreen: isWideScreen),
        ],
      ),
    );
  }

  Widget _buildTournamentStatus({required bool isWideScreen}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.people_rounded,
            size: isWideScreen ? 18 : 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Waiting for players • 0/12 joined',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: isWideScreen ? 14 : 12,
                  ),
            ),
          ),
          Container(
            width: isWideScreen ? 10 : 8,
            height: isWideScreen ? 10 : 8,
            decoration: const BoxDecoration(
              color: VerzusColors.accentGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Open',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: VerzusColors.accentGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: isWideScreen ? 14 : 12,
                ),
          ),
        ],
      ),
    );
  }

  void _showCreateTournamentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final mode = ref.watch(walletModeProvider);
        final titleCtrl = TextEditingController();
        final entryCtrl = TextEditingController(text: '5.00');
        String bracketType = 'single_elim';
        final maxCtrl = TextEditingController(text: '12');
        bool startNow = true;
        DateTime? scheduledAt;
        String payoutMode = 'top3';
        final customPayoutCtrl = TextEditingController(text: '50,30,20');
        String visibility = 'public';
        int bestOf = 1;
        final checkinCtrl = TextEditingController(text: '15');
        final deadlineCtrl = TextEditingController(text: '60');
        String? selectedGameId;

        Future<void> pickDateTime(StateSetter setStateLocal) async {
          final now = DateTime.now();
          final date = await showDatePicker(
            context: context,
            initialDate: now,
            firstDate: now,
            lastDate: DateTime(now.year + 2),
          );
          if (date == null) return;
          final time = await showTimePicker(
            // ignore: use_build_context_synchronously
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (time == null) return;
          final dt =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
          setStateLocal(() => scheduledAt = dt);
        }

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Text(
                'Create Tournament',
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
          content: StatefulBuilder(
            builder: (context, setStateLocal) {
              return SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Game selection
                      Consumer(builder: (context, ref, _) {
                        final gamesAsync = ref.watch(gamesStreamProvider);
                        return gamesAsync.when(
                          data: (games) {
                            if (games.isEmpty) {
                              return _buildErrorNotice(
                                context,
                                'No games available. Please try again later.',
                                compact: true,
                              );
                            }
                            return DropdownButtonFormField<String>(
                              value: selectedGameId,
                              items: games
                                  .map((g) => DropdownMenuItem<String>(
                                        value: g.gameId,
                                        child: Text(
                                          g.title,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setStateLocal(() => selectedGameId = v),
                              decoration: InputDecoration(
                                labelText: 'Game',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                          loading: () =>
                              const LinearProgressIndicator(minHeight: 2),
                          error: (e, _) =>
                              _buildErrorNotice(context, e, compact: true),
                        );
                      }),
                      const SizedBox(height: 12),
                      TextField(
                        controller: titleCtrl,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: entryCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Entry Fee (USD)',
                          prefixText: '\$',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Type
                      DropdownButtonFormField<String>(
                        value: bracketType,
                        items: const [
                          DropdownMenuItem(
                              value: 'single_elim',
                              child: Text('Single Elimination')),
                          DropdownMenuItem(
                              value: 'double_elim',
                              child: Text('Double Elimination')),
                          DropdownMenuItem(
                              value: 'round_robin', child: Text('Round Robin')),
                          DropdownMenuItem(
                              value: 'pools_knockout',
                              child: Text('Pools + Knockouts')),
                        ],
                        onChanged: (v) => setStateLocal(
                            () => bracketType = v ?? 'single_elim'),
                        decoration: InputDecoration(
                          labelText: 'Tournament type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Visibility
                      DropdownButtonFormField<String>(
                        value: visibility,
                        items: const [
                          DropdownMenuItem(
                              value: 'public', child: Text('Public')),
                          DropdownMenuItem(
                              value: 'private', child: Text('Private')),
                        ],
                        onChanged: (v) =>
                            setStateLocal(() => visibility = v ?? 'public'),
                        decoration: InputDecoration(
                          labelText: 'Visibility',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Max participants
                      TextField(
                        controller: maxCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Bracket size (participants)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Best of
                      DropdownButtonFormField<int>(
                        value: bestOf,
                        items: const [
                          DropdownMenuItem(
                              value: 1, child: Text('Single game')),
                          DropdownMenuItem(value: 3, child: Text('Best of 3')),
                          DropdownMenuItem(value: 5, child: Text('Best of 5')),
                        ],
                        onChanged: (v) => setStateLocal(() => bestOf = v ?? 1),
                        decoration: InputDecoration(
                          labelText: 'Match format',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Deadlines
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: checkinCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Check-in deadline (mins)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: deadlineCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Match deadline (mins)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Payout mode
                      DropdownButtonFormField<String>(
                        value: payoutMode,
                        items: const [
                          DropdownMenuItem(
                              value: 'winner_takes_all',
                              child: Text('Winner takes all')),
                          DropdownMenuItem(
                              value: 'top3', child: Text('Top 3 (50/30/20)')),
                          DropdownMenuItem(
                              value: 'custom', child: Text('Custom ratios')),
                        ],
                        onChanged: (v) =>
                            setStateLocal(() => payoutMode = v ?? 'top3'),
                        decoration: InputDecoration(
                          labelText: 'Payout mode',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      if (payoutMode == 'custom') ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: customPayoutCtrl,
                          decoration: InputDecoration(
                            labelText:
                                'Custom ratios (comma-separated, e.g., 60,25,15)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      // Start time
                      Row(
                        children: [
                          Switch(
                            value: startNow,
                            onChanged: (v) => setStateLocal(() => startNow = v),
                          ),
                          const SizedBox(width: 8),
                          Text(startNow ? 'Start now' : 'Scheduled start'),
                          const Spacer(),
                          if (!startNow)
                            TextButton.icon(
                              onPressed: () => pickDateTime(setStateLocal),
                              icon: const Icon(Icons.calendar_today_rounded),
                              label: Text(
                                scheduledAt != null
                                    ? '${scheduledAt!.toLocal()}'
                                    : 'Pick date & time',
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            VerzusButton(
              onPressed: () async {
                final title = titleCtrl.text.trim();
                final entry = double.tryParse(entryCtrl.text) ?? 0.0;
                final auth = ref.read(authStateProvider).value;
                if (title.isEmpty || auth == null || selectedGameId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields.'),
                      backgroundColor: VerzusColors.dangerRed,
                    ),
                  );
                  return;
                }
                final maxP = int.tryParse(maxCtrl.text) ?? 12;
                try {
                  Map<String, num>? ratios;
                  if (payoutMode == 'custom') {
                    final parts = customPayoutCtrl.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
                    if (parts.isNotEmpty) {
                      ratios = {};
                      for (int i = 0; i < parts.length; i++) {
                        final val = num.tryParse(parts[i]);
                        if (val == null) continue;
                        ratios['${i + 1}'] = val;
                      }
                    }
                  }
                  await ref.read(tournamentManagerProvider).createTournament(
                        creatorId: auth.uid,
                        title: title,
                        entryFee: entry,
                        walletKind: mode == WalletKind.demo ? 'demo' : 'live',
                        gameId: selectedGameId!,
                        skillTopic: 'general',
                        maxParticipants: maxP,
                        tournamentType: bracketType,
                        visibility: visibility,
                        payoutMode: payoutMode,
                        payoutRatios: ratios,
                        matchBestOf: bestOf,
                        checkinDeadlineMins:
                            int.tryParse(checkinCtrl.text) ?? 15,
                        matchDeadlineMins:
                            int.tryParse(deadlineCtrl.text) ?? 60,
                        startDate: startNow ? DateTime.now() : scheduledAt,
                      );
                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Tournament '$title' created (${mode == WalletKind.demo ? 'Demo' : 'Live'})",
                        ),
                        backgroundColor: VerzusColors.accentGreen,
                      ),
                    );
                    _tabController.animateTo(1); // Switch to Join tab
                  }
                } catch (e) {
                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to create tournament: $e'),
                        backgroundColor: VerzusColors.dangerRed,
                      ),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildJoinTournament() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWideScreen ? constraints.maxWidth * 0.1 : 16,
            vertical: 16,
          ),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection(FirestoreSchema.tournaments)
                .where(TournamentDocument.status,
                    isEqualTo: FirestoreConstants.tournamentStatusOpen)
                .orderBy(TournamentDocument.startDate)
                .limit(50)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: AppLoading(label: 'Loading tournaments...'));
              }
              if (snapshot.hasError) {
                return _buildErrorNotice(
                    context, snapshot.error ?? 'Unknown error');
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.how_to_reg_rounded,
                  title: 'No Open Tournaments',
                  subtitle:
                      'No battles to join yet! Create your own or check back soon for epic showdowns.',
                  buttonText: 'Create One Now',
                  onButtonPressed: _showCreateTournamentDialog,
                );
              }
              final docs = snapshot.data!.docs;
              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final t = docs[index].data();
                  final joined =
                      (t[TournamentDocument.currentParticipants] ?? 0) as int;
                  final maxP =
                      (t[TournamentDocument.maxParticipants] ?? 0) as int;
                  final entry =
                      (t[TournamentDocument.entryFee] ?? 0.0).toDouble();
                  final walletKind =
                      (t[TournamentDocument.walletKind] ?? 'live') as String;
                  final title =
                      t[TournamentDocument.title] as String? ?? 'Tournament';
                  final type =
                      t[TournamentDocument.tournamentType] as String? ??
                          'Unknown';

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isWideScreen ? 18 : 16,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Entry: ${entry > 0 ? '\$${entry.toStringAsFixed(2)}' : 'Free'} • $type • $joined/$maxP',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontSize: isWideScreen ? 14 : 12,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        VerzusButton(
                          onPressed: () async {
                            final auth = ref.read(authStateProvider).value;
                            if (auth == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please sign in to join.'),
                                  backgroundColor: VerzusColors.dangerRed,
                                ),
                              );
                              return;
                            }
                            try {
                              await ref
                                  .read(tournamentManagerProvider)
                                  .joinTournament(
                                    tournamentId:
                                        t[TournamentDocument.id] as String,
                                    userId: auth.uid,
                                  );
                              if (mounted) {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Joined '$title' (${walletKind == 'demo' ? 'Demo' : 'Live'})",
                                    ),
                                    backgroundColor: VerzusColors.accentGreen,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to join: $e'),
                                    backgroundColor: VerzusColors.dangerRed,
                                  ),
                                );
                              }
                            }
                          },
                          size: isWideScreen
                              ? VerzusButtonSize.medium
                              : VerzusButtonSize.small,
                          child: const Text('Join'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLiveTournaments() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWideScreen ? constraints.maxWidth * 0.1 : 16,
            vertical: 16,
          ),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection(FirestoreSchema.tournaments)
                .where(TournamentDocument.status, isEqualTo: 'live')
                .orderBy(TournamentDocument.startDate)
                .limit(50)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: AppLoading(label: 'Loading live tournaments...'));
              }
              if (snapshot.hasError) {
                return _buildErrorNotice(
                    context, snapshot.error ?? 'Unknown error');
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.live_tv_rounded,
                  title: 'No Live Action',
                  subtitle:
                      'The arena is quiet... for now! Join or create a tournament to ignite the competition!',
                  buttonText: 'Start a Tournament',
                  onButtonPressed: _showCreateTournamentDialog,
                );
              }
              final docs = snapshot.data!.docs;
              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final t = docs[index].data();
                  final title =
                      t[TournamentDocument.title] as String? ?? 'Tournament';
                  final joined =
                      (t[TournamentDocument.currentParticipants] ?? 0) as int;
                  final maxP =
                      (t[TournamentDocument.maxParticipants] ?? 0) as int;
                  final type =
                      t[TournamentDocument.tournamentType] as String? ??
                          'Unknown';
                  final walletKind =
                      (t[TournamentDocument.walletKind] ?? 'live') as String;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isWideScreen ? 18 : 16,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$type • $joined/$maxP players • ${walletKind == 'demo' ? 'Demo' : 'Live'}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontSize: isWideScreen ? 14 : 12,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: isWideScreen ? 80 : 64,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: isWideScreen ? 20 : 18,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.7),
                    fontSize: isWideScreen ? 16 : 14,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          if (buttonText != null && onButtonPressed != null) ...[
            const SizedBox(height: 24),
            VerzusButton.outline(
              onPressed: onButtonPressed,
              child: Text(
                buttonText,
                style: TextStyle(fontSize: isWideScreen ? 16 : 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showJoinTournamentDialog(Map<String, dynamic> tier) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Join ${tier['entry']} Tournament',
          style: TextStyle(fontSize: isWideScreen ? 20 : 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entry Fee: ${tier['entry']}',
              style: TextStyle(fontSize: isWideScreen ? 16 : 14),
            ),
            Text(
              'Players: ${tier['players']}',
              style: TextStyle(fontSize: isWideScreen ? 16 : 14),
            ),
            Text(
              'Prize Pool: ${tier['prize']}',
              style: TextStyle(fontSize: isWideScreen ? 16 : 14),
            ),
            const SizedBox(height: 12),
            Text(
              'Auto brackets fill at 12 players. You can join now; we\'ll place you in the next bracket for this tier.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: isWideScreen ? 14 : 12,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: isWideScreen ? 16 : 14),
            ),
          ),
          VerzusButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final auth = ref.read(authStateProvider).value;
              if (auth == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please sign in to join.'),
                    backgroundColor: VerzusColors.dangerRed,
                  ),
                );
                return;
              }
              final s = (tier['entry'] as String);
              final entry =
                  double.tryParse(s.startsWith('\$') ? s.substring(1) : s) ??
                      0.0;
              final mode = ref.read(walletModeProvider);
              try {
                if (entry > 0) {
                  await ref.read(walletServiceProvider).lockFunds(
                        auth.uid,
                        entry,
                        kind: mode,
                      );
                }
                final refCol = FirebaseFirestore.instance
                    .collection('tournament_waitlist');
                await refCol.add({
                  'user_id': auth.uid,
                  'tier': tier['entry'],
                  'entry_fee': entry,
                  'wallet_kind': mode == WalletKind.demo ? 'demo' : 'live',
                  'created_at': FieldValue.serverTimestamp(),
                });
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Joined waitlist for ${tier['entry']} tier (${mode == WalletKind.demo ? 'Demo' : 'Live'})',
                      ),
                      backgroundColor: VerzusColors.accentGreen,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to join: $e'),
                      backgroundColor: VerzusColors.dangerRed,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Join',
              style: TextStyle(fontSize: isWideScreen ? 16 : 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggleChip extends StatelessWidget {
  final WalletKind mode;
  final ValueChanged<WalletKind> onChanged;
  const _ModeToggleChip({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pill(
            context,
            label: 'Live',
            selected: mode == WalletKind.live,
            onTap: () => onChanged(WalletKind.live),
            isWideScreen: isWideScreen,
          ),
          _pill(
            context,
            label: 'Demo',
            selected: mode == WalletKind.demo,
            onTap: () => onChanged(WalletKind.demo),
            isWideScreen: isWideScreen,
          ),
        ],
      ),
    );
  }

  Widget _pill(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required bool isWideScreen,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isWideScreen ? 16 : 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: selected
                ? VerzusColors.primaryPurple.withValues(alpha: 0.15)
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
                  fontSize: isWideScreen ? 14 : 12,
                ),
          ),
        ),
      ),
    );
  }
}
