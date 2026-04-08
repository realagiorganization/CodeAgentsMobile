# Assumptions

- The app scheme used in CI and Fastlane is `CodeAgentsMobile`; the repository’s current native test configuration is assumed to remain compatible with that shared scheme.
- The current container is Linux-based, so BDD checks can be executed here but native iOS build/test and TestFlight validation require GitHub macOS runners or a local macOS machine.
- Native Swift tests that hit a real SSH host are treated as opt-in smoke tests and remain disabled in default CI unless `ENABLE_LIVE_SSH_TESTS=1` is supplied explicitly.
- App Store Connect credentials, team ids, and bundle identifiers are supplied through GitHub secrets for any workflow that uploads to TestFlight.
- GitHub and Discord OAuth apps will be provisioned before the native sign-in implementation begins; this run documents the integration plan but does not invent placeholder secrets in code.
- RevenueCat products, offerings, and entitlements will be defined in App Store Connect and RevenueCat before the paywall implementation lands.
- DigitalOcean and Hetzner tokens used by real provisioning flows are external secrets; the BDD suite uses deterministic simulator data instead of calling live APIs.
- VHS generation happens in CI through `charmbracelet/vhs-action`; the in-repo GIF is treated as a consumable artifact for README rendering.
- The queued “GitHub Pages website” note is interpreted conservatively for this run: documentation is kept GitHub-hostable from `docs/`, but no separate static site or Pages deployment workflow is introduced without a stronger repository signal.
