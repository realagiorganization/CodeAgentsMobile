# Environment Variables

Environment variables are grouped by whether they are required for a specific workflow or optional overrides.

## Mandatory

### TestFlight Release

- `APP_STORE_KEY_ID`
  App Store Connect API key identifier used by Fastlane.
- `APP_STORE_ISSUER_ID`
  App Store Connect issuer identifier paired with the API key.
- `APP_STORE_KEY_CONTENT`
  Base64-encoded private key content consumed by `app_store_connect_api_key`.
- `APPLE_ID`
  Apple account identifier used during TestFlight upload.
- `TEAM_ID`
  Apple Developer team identifier.
- `APP_IDENTIFIER`
  Bundle identifier for the shipped iOS app.

## Optional

### Fastlane / iOS Build Overrides

- `ITC_TEAM_ID`
  App Store Connect team id. Defaults to `TEAM_ID` when unset.
- `TESTFLIGHT_GROUPS`
  Comma-separated TestFlight beta groups for distribution.
- `XCODE_PROJECT`
  Overrides the default Xcode project path. Defaults to `CodeAgentsMobile.xcodeproj`.
- `SCHEME`
  Overrides the default build scheme. Defaults to `CodeAgentsMobile`.
- `EXPORT_METHOD`
  Overrides the Fastlane export method. Defaults to `app-store`.
- `SIMULATOR_DEVICE`
  Simulator name for `fastlane tests`. Defaults to `iPhone 15`.

### Planned Product Integrations

- `GITHUB_CLIENT_ID`
  Planned GitHub OAuth client id for the future native login flow.
- `GITHUB_CALLBACK_URL`
  Planned GitHub OAuth redirect/callback URL.
- `DISCORD_CLIENT_ID`
  Planned Discord OAuth client id for the future native login flow.
- `DISCORD_CALLBACK_URL`
  Planned Discord OAuth redirect/callback URL.
- `REVENUECAT_API_KEY`
  Planned RevenueCat public SDK key for offerings and entitlement sync.
- `REVENUECAT_OFFERING_ID`
  Planned default offering identifier surfaced by the paywall.
- `DIGITALOCEAN_TOKEN`
  Optional local token for manual provisioning validation outside CI.
- `HETZNER_TOKEN`
  Optional local token for manual provisioning validation outside CI.
- `ANTHROPIC_API_KEY`
  Optional local credential for manual end-to-end app validation.

### Optional Live SSH Integration Tests

- `ENABLE_LIVE_SSH_TESTS`
  Set to `1` to opt into the live SSH-based Swift tests. Defaults to disabled in CI.
- `LIVE_SSH_HOST`
  Hostname or IP for the remote SSH smoke-test server.
- `LIVE_SSH_PORT`
  SSH port for the live smoke-test server. Defaults to `22`.
- `LIVE_SSH_USERNAME`
  SSH username for the live smoke-test server.
- `LIVE_SSH_PASSWORD`
  SSH password used by the current smoke tests.
- `LIVE_SSH_PROJECT_PATH`
  Remote project path used for Claude CLI commands.
- `LIVE_SSH_ANTHROPIC_API_KEY`
  Anthropic API key used by the live Claude smoke tests.

## Notes

- GitHub Actions should source secrets from repository or organization secrets rather than committing values anywhere in the repo.
- Planned product integration variables are documented now so the implementation can adopt a stable naming scheme later.
