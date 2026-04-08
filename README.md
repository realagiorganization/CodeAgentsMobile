# CodeAgents Mobile

[![iOS Build & TestFlight](https://github.com/realagiorganization/CodeAgentsMobile/actions/workflows/ios-ci.yml/badge.svg)](https://github.com/realagiorganization/CodeAgentsMobile/actions/workflows/ios-ci.yml)
[![BDD Suite](https://github.com/realagiorganization/CodeAgentsMobile/actions/workflows/bdd.yml/badge.svg)](https://github.com/realagiorganization/CodeAgentsMobile/actions/workflows/bdd.yml)

A mobile client to Claude Code for iOS.
It lets you run Claude Code on any Linux SSH server from a native iPhone interface.

**TestFlight Beta**

https://testflight.apple.com/join/eUpweBZV

**AppStore**

https://apps.apple.com/app/codeagents-mobile/id6748273716

## Screenshots

<img src="screenshots/screenshot_1.png" width="250" alt="Screenshot 1" /> <img src="screenshots/screenshot_2.png" width="250" alt="Screenshot 2" /> <img src="screenshots/screenshot_3.png" width="250" alt="Screenshot 3" /> <img src="screenshots/screenshot_4.png" width="250" alt="Screenshot 4" />
<img src="screenshots/screenshot_5.png" width="250" alt="Screenshot 5" />
<img src="screenshots/screenshot_6.png" width="250" alt="Screenshot 6" />
<img src="screenshots/screenshot_7.png" width="250" alt="Screenshot 7" />
<img src="screenshots/screenshot_8.png" width="250" alt="Screenshot 8" />

## Features
- **NEW** Provision servers with Digital Ocean / Hetzner 
- **NEW** Auto install Claude Code for provisioned servers
- **NEW** Auto create SSH keys
- MCP servers support 
- Connect to remote servers via SSH
- Interact with Claude Code through a native iOS interface
- Supports both API key and subscription-based authentication (OAuth tokens)
- Browse files on remote servers
- Real-time chat with Claude Code

## Requirements

- iOS 17.0+
- Xcode 15+
- Swift 5.9+

## CI & Quality
- `bundle exec fastlane tests` runs native tests on macOS runners via the **iOS Build & TestFlight** workflow.
- `bundle exec fastlane beta` builds and uploads to TestFlight and requires App Store Connect secrets in GitHub Actions.
- `bundle exec fastlane bdd` executes executable specs and the **BDD Suite** workflow renders the VHS recording below.
- BDD console demo (auto-regenerated in CI):

![BDD console demo](assets/bdd-console.gif)

Run locally:
```bash
bundle install
python -m pip install -r bdd/requirements.txt
python -m pytest bdd -q
```

## Documentation

- [docs/DEVPLAN.md](docs/DEVPLAN.md) tracks roadmap work, including planned GitHub/Discord login UI and RevenueCat subscription flows.
- [docs/USAGE.md](docs/USAGE.md) covers local setup, Fastlane usage, and CI entry points.
- [docs/ENVS.md](docs/ENVS.md) lists required and optional environment variables.
- [docs/ASSUMPTIONS.md](docs/ASSUMPTIONS.md) records execution assumptions used for autonomous runs.
- [docs/AGENTS.md](docs/AGENTS.md) documents the self-prompts and guardrails used while modifying the repo.

## Getting Started

```bash
# Clone the repository
git clone [repository-url]

# Open in Xcode
open CodeAgentsMobile.xcodeproj

# Build and run
# Select your target device/simulator and press Cmd+R
```


## Architecture

Built with SwiftUI and SwiftData following MVVM pattern.
Icon - https://tabler.io/icons/icon/brain, edited here https://icon.kitchen

## License

This project is licensed under the Apache License, Version 2.0 - see the [LICENSE](LICENSE) file for details.
