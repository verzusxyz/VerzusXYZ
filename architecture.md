# VerzusXYZ Architecture Plan

## Project Overview
VerzusXYZ is a comprehensive skill competition platform offering:
- **Matches**: 1v1 and multiplayer skill-based competitions
- **Tournaments**: Auto-generated brackets ($5, $10, $25, $50 tiers) and custom tournaments
- **Topics**: Verified and open prediction polls
- **Live Betting**: Spectator staking on ongoing events
- **Wallet System**: Deposits, withdrawals, escrow, affiliate payouts
- **Game Addition**: User-submitted games with OCR verification

## Core Technical Principles
1. **MVP Focus**: Essential features only for initial release
2. **Firebase Integration**: Auth, Firestore, Storage, Cloud Functions
3. **Server-Authoritative**: All financial operations via Cloud Functions
4. **Real-time Verification**: OCR-based proof validation with anti-cheat
5. **Platform Agnostic**: Cross-platform capture (Android, iOS, Web)

## System Architecture

### 1. Data Models (Firestore Collections)

#### Core Collections:
- `users/{uid}` - User profiles, KYC status
- `wallets/{uid}` - Balance, locked funds, affiliate earnings
- `games/{gameId}` - Approved games with OCR crop data
- `matches/{matchId}` - 1v1/multiplayer competitions
- `tournaments/{tournamentId}` - Tournament brackets
- `topics/{topicId}` - Prediction polls
- `pools/{eventId}` - Live betting pools
- `transactions/{txId}` - All financial movements
- `payments/{paymentId}` - Gateway deposit/withdrawal records

#### Admin Collections:
- `admin_financials/main` - Platform revenue tracking
- `verifications/{verificationId}` - Pending proof reviews
- `disputes/{disputeId}` - Contested matches
- `affiliates/{affiliateId}` - Referral tracking

### 2. Commission Structure
- **Matches**: 20% platform commission (configurable)
- **Tournaments**: 23% platform commission (configurable)
- **Live Betting**: 20% platform commission (configurable)
- **Topics**: 20% platform commission (configurable)
- **Affiliate Program**: 1% of platform commission on first usage

### 3. Core Modules Structure

```
lib/
├── main.dart
├── theme.dart
├── models/                 # Data models
│   ├── user.dart
│   ├── wallet.dart
│   ├── match.dart
│   ├── tournament.dart
│   └── transaction.dart
├── services/               # Business logic
│   ├── auth_service.dart
│   ├── wallet_service.dart
│   ├── match_service.dart
│   ├── ocr_service.dart
│   └── capture_service.dart
├── screens/                # UI screens
│   ├── auth/
│   ├── home/
│   ├── matches/
│   ├── tournaments/
│   ├── topics/
│   ├── wallet/
│   └── games/
├── widgets/                # Reusable components
└── utils/                  # Helpers and constants
```

### 4. Key Flows Implementation

#### Match Flow:
1. **Create Match** → User sets game, stake, visibility
2. **Join Match** → Atomic wallet lock via Cloud Function
3. **Play & Capture** → Real-time OCR during gameplay
4. **Proof Submission** → Final screenshots uploaded
5. **Verification** → Username matching + anti-cheat scoring
6. **Finalization** → Automated payout distribution

#### Tournament Flow:
1. **Auto-Generation** → Fixed tiers ($5-$50) with 12-player brackets
2. **Join Tournament** → Entry fee locked, ELO-based seeding
3. **Bracket Progression** → Individual matches with elimination
4. **Prize Distribution** → Top 3 payouts (60%/25%/15%)

#### Wallet System:
1. **Deposits** → Gateway integration (Paystack/Flutterwave)
2. **Escrow Management** → Server-side fund locking for active events
3. **Payout Calculation** → Commission deduction, affiliate distribution
4. **Safe Withdrawals** → Admin float validation

### 5. Game Addition & Verification System

#### Client-Side Capture:
- **Android**: MediaProjection API for screen capture
- **iOS**: ReplayKit for broadcast recording  
- **Web**: getDisplayMedia for screen sharing
- **OCR Processing**: On-device TFLite models for crop suggestion

#### Server-Side Validation:
- **Username Matching**: Jaro-Winkler + Levenshtein algorithm (s_final ≥ 0.92 auto-accept)
- **Anti-Cheat**: Risk scoring (< 0.10 auto-accept, ≥ 0.60 disputed)
- **Same-Room Detection**: URL matching, board-state fingerprinting, pHash similarity

### 6. Security & Financial Controls

#### Server-Authoritative Rules:
- All wallet operations via Cloud Functions only
- Firestore security rules block direct client writes to financial fields
- Atomic transactions for all fund movements

#### Verification Pipeline:
```
Evidence Score = 0.35*urlMatch + 0.25*boardState + 0.15*pHash + 0.15*username + 0.10*timeCorrelation
- ≥ 0.92: Auto-finalize
- 0.70-0.92: Client confirmation or admin review  
- < 0.70: Dispute resolution
```

### 7. Admin Dashboard Features
- Real-time financial monitoring
- Proof verification queue
- Game submission approvals
- Commission configuration
- Affiliate payout management
- Safe-withdrawable calculation

## Implementation Plan

### Phase 1: Core Foundation (Files 1-4)
1. **Authentication System** - Firebase Auth integration
2. **Basic Navigation** - Bottom tab navigation
3. **Wallet Implementation** - Balance display, transaction history
4. **Theme Enhancement** - Modern, non-Material design with VerzusXYZ branding

### Phase 2: Match System (Files 5-8)
1. **Game Management** - Add game flow with sample OCR data
2. **Match Creation** - Create/join match screens
3. **Basic Verification** - Simple proof upload system
4. **Transaction System** - Financial tracking

### Phase 3: Advanced Features (Files 9-12)
1. **Tournament System** - Auto-tournaments with bracket generation
2. **Topics (Polls)** - Verified and open prediction markets
3. **Live Betting** - Spectator staking pools
4. **Advanced OCR** - Username matching and anti-cheat

## Technical Considerations

### Dependencies Required:
- `firebase_core`, `firebase_auth`, `cloud_firestore`
- `flutter_riverpod` (state management)
- `go_router` (navigation)
- `image_picker`, `camera` (capture)
- Local storage for non-backend features initially

### Performance Optimizations:
- Shimmer loading for all lists
- Image caching and compression
- Efficient Firestore queries with proper indexing
- Real-time listeners only where necessary

### Compliance & Legal:
- Anti-gambling language (use "challenge", "contribution", "reward pool")
- KYC requirements for live mode
- Gateway fee transparency
- Audit logging for all admin actions

This architecture provides a solid foundation for building VerzusXYZ as a comprehensive skill competition platform while maintaining code quality and scalability.