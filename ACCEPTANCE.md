# ACCEPTANCE — VerzusXYZ QA Checklist

This checklist must pass before release. It maps directly to the SPEC/VERZUSXYZ.md requirements.

Payments
- Paystack deposit (test): create deposit → simulated webhook/credit → wallet balance increases by net (gross - fee) → transaction logged with fee line item.
- Flutterwave deposit (test): same as above.
- Withdraw request (mock): write withdrawals doc; (server-side flow documented) verify safe-withdrawable calculation and state flags.

Game addition
- Android/Web sample capture flow mock: submission written to games_user_submissions with defaultCropData and sample image URLs.
- Admin approves → games/{gameId} appears via promotion flow (template function).

Match flow
- Create match → wallet locks creator stake (pending/locked).
- Second user joins → wallet locks opponent stake.
- Client proof upload (mock endpoints) → verification pipeline (template) transitions to finalize.
- Finalize match (template): pending unlocked, winner credited with prize pool, transactions recorded, commission reflected in admin_financials.

Tournaments
- Auto tournament tiers visible ($5/$10/$25/$50) with correct 12-player payout math in UI.
- Join: participant lock recorded; when 12 join (simulate), next bracket spawns.
- Finalize tournament: payout splits exact per examples; transactions recorded.

Topics
- Create verified topic with link field; open topic without link.
- Stake (mock) → pools updated; finalize distributes per 20% cut.

Affiliate
- Sign up with referral; first used amount locks funds → affiliate payout = 1% of platform commission (once per referred user). Credited to affiliatePending; withdrawable after threshold (default $20).

UI/UX
- Responsive nav: sidebar collapsible on web/desktop; bottom nav on mobile/tablet.
- No layout overflow on small screens; all forms scroll with keyboard.
- Shimmer/loading placeholders shown on list loads; global loader for heavy ops (mocked or Lottie placeholder).

Security
- Financial writes (wallet balances, transactions, admin_financials) are server-authoritative (via Cloud Functions) in production. Client code here is test-mode only; rules should reject direct writes to financial fields outside functions.

Evidence & Same-room detection (board/web games)
- URL/externalId paste captured and stored; OCR room code extraction hook documented.
- Evidence scoring template computes evidenceScore; threshold policies enforced.

Deliverables present
- SPEC/VERZUSXYZ.md and this ACCEPTANCE.md
- Firestore schema constants in lib/firestore/firestore_data_schema.dart
- Cloud Functions manifest & templates (see docs folder if provided) for all required functions
- Admin UI scaffolding present in codebase (navigation hooks)

Reviewer Notes
- Live payment processing requires Firebase Functions with Paystack/Flutterwave secrets and webhook verification. Client is wired to call server in production; current app simulates deposits in test mode.
