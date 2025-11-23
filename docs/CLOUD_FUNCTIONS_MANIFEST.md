# Cloud Functions Manifest — VerzusXYZ

All functions are idempotent and server-authoritative. Implement in TypeScript with Firebase Admin SDK. Wire HTTPS callable or HTTP endpoints as needed.

Payments
- createPayment(user, amount, gateway, purpose)
- onGatewayWebhook(gateway)
- reconcilePayments()

Matches
- createMatch(matchTempId)
- joinMatch(matchId, userId)
- verifyMatchProof(matchId)
- finalizeMatch(matchId)

Pools & Topics
- placeStake(eventId, optionId, amount)
- finalizePool(eventId)

Tournaments
- joinTournament(tid, userId)
- startTournament(tid)
- finalizeTournament(tid)
- generateAutoTournaments() (scheduled)

Affiliate & Admin
- affiliateCreditOnFirstUsed(userId, usedAmount)
- applyOffer(offerId, userId)
- computeSafeWithdrawable() (scheduled)
- massPayoutJob()

Games
- promoteGameSubmission(submissionId)

Same-room helpers
- parseExternalIdFromUrl(url)
- extractRoomIdFromOCR(ocrText)
- computeBoardFENFromImage(image)
- computeEvidenceScore(matchId)

Notes
- Store all ledger-affecting writes (wallets, transactions, admin_financials) behind these functions. Add comprehensive logging and audit_logs entries for manual overrides.
- Keep gateway secrets (Paystack, Flutterwave) only in function configs; never in client.
