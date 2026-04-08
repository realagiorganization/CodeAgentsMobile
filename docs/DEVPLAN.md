# Development Plan

## Scope

This repository currently ships the core iOS client for remote Claude Code usage over SSH. The queue for this run adds four delivery tracks:

- Document the full development roadmap, including GitHub/Discord login UI and RevenueCat plan management.
- Establish executable BDD coverage for principal user journeys.
- Provide GitHub Actions and Fastlane automation for test, BDD, and TestFlight release flows.
- Keep the repository documentation operational for third-party developers and GitHub-hosted browsing.

## Status Summary

- [x] Audit the existing repository structure, app modules, workflows, BDD assets, and documentation gaps.
- [x] Move the canonical development plan into `docs/`.
- [x] Create the required repository documentation set: assumptions, agent prompts, environment variables, and usage instructions.
- [x] Expand the BDD suite to cover principal auth, provisioning, subscription, settings, and file-safety journeys.
- [x] Harden Fastlane and GitHub Actions for test, BDD/VHS, artifact upload, and TestFlight release flow.
- [x] Commit a shared Xcode scheme for CI-driven `scan` execution.
- [ ] Implement GitHub / Discord login UI and OAuth flows in the iOS app.
- [ ] Implement RevenueCat plan purchase and subscription management in the iOS app.
- [ ] Expand native Swift tests around chat, file browsing, provisioning, and auth adapters.
- [ ] Validate the TestFlight lane end-to-end on a macOS runner with signing secrets present.

## Workstreams

### 1. Documentation And Delivery Readiness

- [x] Document repo assumptions in [ASSUMPTIONS.md](./ASSUMPTIONS.md).
- [x] Document execution prompts used during autonomous runs in [AGENTS.md](./AGENTS.md).
- [x] Document mandatory and optional environment variables in [ENVS.md](./ENVS.md).
- [x] Document local setup and operational workflows in [USAGE.md](./USAGE.md).
- [x] Refresh the root `README.md` so it points readers to the canonical docs and CI entry points.
- [x] Add a GitHub Pages-friendly docs landing page in `docs/index.md`.

### 2. Authentication UX: GitHub And Discord

- [ ] Define the authentication information architecture.
  - [ ] Add a provider-first sign-in screen with GitHub, Discord, and existing token fallback.
  - [ ] Define copy for privacy, scopes, support, and cancellation/retry states.
  - [ ] Decide where linked identity management lives: onboarding, settings, or both.
- [ ] Implement provider coordinators.
  - [ ] GitHub OAuth flow with PKCE and callback handling.
  - [ ] Discord OAuth flow with PKCE and callback handling.
  - [ ] Shared token persistence, refresh, expiry, and revocation handling through Keychain-backed services.
- [ ] Integrate authenticated identity state into the existing app model.
  - [ ] Persist provider, user id, scopes, expiry, and refresh metadata.
  - [ ] Surface identity status in settings and any gated screens.
  - [ ] Update Claude Code auth selection so provider-linked sessions coexist cleanly with API key and auth token modes.
- [ ] Validate failure modes.
  - [ ] User cancellation.
  - [ ] Missing scopes.
  - [ ] Expired refresh token.
  - [ ] Redirect mismatch / callback failure.

### 3. RevenueCat Plans And Subscription Management

- [ ] Introduce dependencies and configuration.
  - [ ] Add the RevenueCat SDK through the project’s package manager choice.
  - [ ] Store the public SDK key and offering identifiers in a dedicated configuration layer.
  - [ ] Define App Store Connect products and entitlement names in shared documentation.
- [ ] Design the purchase and management flows.
  - [ ] Add a paywall screen that renders current offerings, pricing, and restore actions.
  - [ ] Add a plan management screen from settings or account context.
  - [ ] Define banners or gating points for locked functionality.
- [ ] Implement entitlement handling.
  - [ ] Sync current offering state on launch and foreground.
  - [ ] Cache entitlement state for transient offline use.
  - [ ] Add restore, retry, and billing-issue UX.
- [ ] Add verification and observability.
  - [ ] Record non-PII analytics for offering fetch, purchase success, restore success, and purchase failure.
  - [ ] Add stubs or mocks for deterministic CI coverage.

### 4. Core Product Journeys

- [x] Maintain a BDD description of principal user journeys under `bdd/`.
- [x] Expand the simulator-driven scenarios to cover provider chat, managed provisioning, subscription restore, and settings credential switching.
- [ ] Strengthen corresponding product implementation where gaps exist.
  - [ ] Provider-authenticated chat bootstrap.
  - [ ] Cloud provisioning health and Claude CLI readiness checks.
  - [ ] Project-root safety for file operations.
  - [ ] Subscription-aware access management.
  - [ ] Settings-driven credential management.
- [ ] Add or expand native Swift tests for critical services.
  - [ ] `ClaudeCodeService`
  - [ ] `ServerManager`
  - [ ] `ProjectService`
  - [ ] File-browser boundary enforcement

### 5. CI, VHS Recording, And Release Automation

- [x] Keep a dedicated BDD workflow in GitHub Actions.
- [x] Keep a dedicated iOS test and TestFlight workflow in GitHub Actions.
- [x] Keep Fastlane lanes for test, BDD, and beta deployment.
- [x] Expose action badges in the root `README.md`.
- [x] Store a VHS-generated GIF in-repo and surface it from the `README.md`.
- [x] Upload workflow artifacts for BDD output, GIFs, native test reports, and build logs.
- [ ] Add artifact upload for any future native UI recordings or screenshots generated in CI.
- [ ] Decide whether BDD/VHS artifacts should be committed back to the repository automatically or retained as workflow artifacts only.

## External Dependencies

### Runtime / Product

- GitHub OAuth application credentials and registered callback URL.
- Discord OAuth application credentials and registered callback URL.
- RevenueCat iOS SDK and RevenueCat project configuration.
- App Store Connect subscription products and entitlement mapping.
- Apple Keychain Services for credential storage.
- DigitalOcean and Hetzner cloud APIs for server provisioning.
- Anthropic / Claude Code credentials or tokens for chat execution.

### Build / CI / Release

- Xcode with iOS SDKs matching the deployment target.
- Ruby plus Fastlane for automation.
- Python plus `pytest` and `pytest-bdd` for executable specs.
- GitHub Actions macOS runners for native build/test and TestFlight upload.
- GitHub Actions Ubuntu runners for BDD execution and VHS capture.
- `charmbracelet/vhs-action` for CI GIF generation.
- App Store Connect API key or equivalent release credentials.

## Deliverables For This Run

- [x] Canonical planning and operational docs under `docs/`.
- [x] Existing CI and release automation reviewed against queued requirements.
- [x] README badges and BDD GIF surfaced for repository consumers.
- [ ] Remaining product implementation work for OAuth UI and RevenueCat stays planned but not yet built.

## Exit Criteria

- Documentation under `docs/` is complete and internally consistent.
- The BDD suite covers the principal journeys at the executable-spec level.
- CI definitions for iOS testing, BDD execution, VHS capture, and TestFlight deployment are present and documented.
- Remaining unimplemented product work is explicitly tracked with dependencies and risks.
