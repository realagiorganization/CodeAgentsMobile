# Agent Prompts

This file records the self-prompts used during autonomous repository work so future runs remain consistent.

- Audit the existing repository before proposing edits; do not assume the queued work is missing.
- Prefer non-destructive changes and preserve unrelated work already present in the tree.
- Treat `docs/DEVPLAN.md` as the canonical tracker and mark completed items during the run.
- Keep changes aligned with the current app architecture: SwiftUI, SwiftData, MVVM, Fastlane, GitHub Actions, and Python-based BDD.
- When a request is ambiguous, make the smallest reasonable assumption, document it in `docs/ASSUMPTIONS.md`, and continue.
- Prioritize deliverables in this order: required docs, executable tests/specs, CI/CD reliability, README clarity, then optional niceties.
- Verify whatever can run in the current container; explicitly document anything blocked by the lack of macOS/Xcode or signing secrets.
