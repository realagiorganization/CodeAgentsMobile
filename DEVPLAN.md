# Development Plan

## Objectives
- Add GitHub and Discord login UI with OAuth-based authentication.
- Introduce RevenueCat-driven plan purchase and management screens.
- Maintain existing SSH/Claude Code functionality and provisioning flows (DigitalOcean/Hetzner).
- Ship a reliable release pipeline (tests + TestFlight) with observable quality gates.

## High-Level Milestones
1) **Foundation & Dependencies**
   - Add SDKs/clients: GitHub OAuth (device/web flow), Discord OAuth (Authorization Code with PKCE), RevenueCat iOS SDK.
   - Configure app identifiers, URL schemes, and Keychain sharing for OAuth tokens.
   - Create secure storage for auth/session tokens and subscription status.

2) **Authentication Experience (GitHub & Discord)**
   - Design combined entry screen: provider selection, CTA, privacy copy, fallback to API key.
   - Implement OAuth flow coordinators (per provider) with ASWebAuthenticationSession + PKCE.
   - Persist identities (provider, user id, scopes, expiry) in SwiftData; refresh tokens silently when possible.
   - Error states: cancelled, expired session, missing scopes; add retry guidance.
   - Hook authenticated identity into existing Claude Code request signing.

3) **RevenueCat Plans & Entitlements**
   - Add paywall screen (products, price, trial/intro offers) backed by RevenueCat offerings.
   - Implement purchase + restore + manage subscription actions.
   - Show entitlement-driven UI state: access gating, banners for expired/cancelled, offline caching of status.
   - Add telemetry hooks for conversion/failure (non-PII) and in-app receipt refresh.

4) **Server Provisioning & Onboarding**
   - Validate DigitalOcean/Hetzner credentials early; show quota/cost hints.
   - Stream provisioning progress (cloud-init, Claude Code install) with cancellable tasks.
   - Post-provision checks: SSH connectivity, Claude CLI presence, key sync.
   - Guardrails: retry with exponential backoff, clean-up on failure.

5) **Core App Hardening**
   - Chat reliability: reconnect logic, message persistence, tool-run visualisation.
   - File browser: optimistic UI for CRUD, conflict detection, UTF-8 filename handling.
   - Security: limit host key prompts, sanitize command inputs, enforce least-privilege keys.

6) **Testing & Quality**
   - Expand unit tests around SSH/service managers and chat state machines.
   - Add BDD coverage for primary user journeys (auth, provisioning, chat, paywall).
   - UI snapshot smoke tests for auth/paywall screens; record VHS demo for CI visibility.

7) **Delivery & Release**
   - Fastlane lanes for tests, BDD, and TestFlight deploy (using App Store Connect API key or session env vars).
   - GitHub Actions: unit/build/TestFlight pipeline, BDD/VHS pipeline, status badges in README.
   - Artifact retention: BDD reports, VHS GIF, TestFlight build logs.

## External Dependencies
- **OAuth**: GitHub OAuth app (client id/secret, callback URL), Discord application with redirect + PKCE enabled.
- **Subscriptions**: RevenueCat iOS SDK, project configured with products/entitlements in App Store Connect.
- **CI/CD**: Fastlane (bundler optional), App Store Connect API key or FASTLANE_SESSION, Match/automatic signing credentials.
- **BDD**: Python 3.11+, pytest, pytest-bdd for executable specs; optional VHS CLI for console recordings.
- **Provisioning**: DigitalOcean & Hetzner API tokens with create/destroy droplet permissions; SSH keypair management.

## Risks & Mitigations
- OAuth callback misconfigurations → verify URL schemes per provider and add automated checks in CI.
- RevenueCat product drift → load offerings dynamically and display fallback copy when unavailable.
- TestFlight signing failures → keep API key/team ids in CI secrets; run `fastlane match` before builds if used.
- Network latency during provisioning → add timeouts/backoff and clear user messaging.
- BDD brittleness → isolate specs with mock contexts; keep fixtures deterministic.

## Acceptance Criteria
- Users can complete GitHub or Discord login and see their linked identity in settings.
- RevenueCat paywall shows available products and completes purchase/restore; entitlement state updates app sections.
- Provisioned servers report ready status with Claude Code installed; chat and file flows operate post-auth.
- CI passes unit, BDD, and VHS checks; TestFlight lane produces an installable build.
