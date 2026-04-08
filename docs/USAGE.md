# Usage

## Prerequisites

- macOS with Xcode 15 or newer for native iOS build and simulator work.
- Ruby 3.x for Fastlane.
- Python 3.11 or newer for the BDD suite.
- iOS signing credentials only if you intend to produce a release build or upload to TestFlight.

## Local Setup

```bash
bundle install
python -m pip install -r bdd/requirements.txt
open CodeAgentsMobile.xcodeproj
```

If Bundler is not available yet:

```bash
gem install bundler
bundle install
```

## Running The App

1. Open `CodeAgentsMobile.xcodeproj` in Xcode.
2. Select the `CodeAgentsMobile` scheme.
3. Choose an iOS 17+ simulator or a physical device.
4. Run the app with `Cmd+R`.

## Running Tests

### BDD Suite

```bash
python -m pytest bdd -q
```

### Fastlane BDD Lane

```bash
bundle exec fastlane bdd
```

### Native iOS Tests

```bash
bundle exec fastlane tests
```

This must run on macOS with Xcode installed.

### Optional Live SSH Smoke Tests

The committed Swift tests now default to CI-safe behavior. To opt into the live SSH integration paths, export the variables documented in [ENVS.md](./ENVS.md) and set:

```bash
export ENABLE_LIVE_SSH_TESTS=1
bundle exec fastlane tests
```

## Release Workflow

### Local TestFlight Upload

Set the release environment variables described in [ENVS.md](./ENVS.md), then run:

```bash
bundle exec fastlane beta
```

### GitHub Actions

- `.github/workflows/ios-ci.yml`
  Runs native tests on macOS and uploads a TestFlight build from `main` or manual dispatch when secrets are present.
- `.github/workflows/bdd.yml`
  Runs the BDD suite on Ubuntu and renders the GIF demo from `vhs/bdd-console.tape`.

## Repository Docs

- [DEVPLAN.md](./DEVPLAN.md)
  Canonical roadmap and task tracker.
- [ASSUMPTIONS.md](./ASSUMPTIONS.md)
  Explicit assumptions used for autonomous execution.
- [AGENTS.md](./AGENTS.md)
  Self-prompts and execution guardrails for future runs.
- [ENVS.md](./ENVS.md)
  Environment variable reference.
