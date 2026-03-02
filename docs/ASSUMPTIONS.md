# Assumptions

- Xcode schemes `CodeAgentsMobile` (app) and `CodeAgentsMobileTests` exist and are shared for CI; UI/BBD flows are simulated and do not require an iOS simulator.
- App Store Connect credentials (API key JSON or FASTLANE_SESSION), team ids, and bundle identifiers are provided via GitHub secrets for TestFlight uploads.
- GitHub and Discord OAuth apps are pre-configured with matching redirect URLs and stored client ids/secrets in CI secrets.
- RevenueCat project/products are already created; the app receives an API key via secrets and products are available in App Store Connect.
- DigitalOcean/Hetzner API tokens provided via secrets allow droplet creation/destruction; placeholder tokens in tests are stubs.
- VHS CLI is available in CI via the `charmbracelet/vhs-action` step; generated GIFs are committed/updated by the workflow.
