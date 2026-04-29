# Domain Model Notes

This file explains the working intent of each model in the Flutter rebuild.

## User
- Canonical identity for buyer, vendor, or admin.
- Owns trust score, COD strike count, and private location data.
- Exact coordinates never appear in discovery payloads.

## VendorProfile
- Operational seller profile layered on top of `User`.
- Controls public storefront state, manual payment methods, packaging cost, and plan enforcement.
- Discovery only shows vendors in an orderable state.

## TrustRelationship
- Explicit access gate between a buyer and a vendor.
- Buyers cannot place a first order until the relationship becomes `APPROVED`.
- `BLOCKED` suppresses future ordering and safety-sensitive notifications.

## InventoryItem
- Reusable menu template.
- Mutable for future selling windows only.
- Historical orders must not recalculate against item edits.

## Batch
- Time-bound stock bucket that turns inventory into a sellable micro-batch.
- All order acceptance rules are evaluated against the batch.
- Stock decrement must be atomic on the backend.

## Order
- Source of truth for payment, fulfillment, logistics mode, and final pricing snapshots.
- Lifecycle:
  - `PENDING_PAYMENT`: created, waiting for buyer action
  - `VERIFICATION`: proof uploaded, vendor must verify
  - `CONFIRMED`: payment accepted or COD policy accepted
  - `READY`: vendor marked meal as prepared
  - `COMPLETED`: buyer handoff complete
  - side states: `CANCELLED`, `NO_SHOW`, `BARAKAT`

## ChatRoom and Message
- Order-scoped private chat.
- Messages may carry text, media, offers, or system events.
- System messages describe workflow events but do not impersonate buyer or vendor.

## PaymentMethod
- Structured vendor payout metadata.
- Supports wallet and bank detail expansion without schema rewrites.

## SubscriptionPlan
- Client-visible plan capabilities for UI messaging.
- Backend remains the source of enforcement truth.

## ModerationReport
- Needed for harassment, report, and review flows.
- Kept in the initial schema so moderation is designed in, not bolted on.

## BarakatMeal, GiftMeal, CODStrike
- Roadmap models already reflected in the new domain.
- They should be introduced as first-class entities instead of squeezed into generic order metadata later.
