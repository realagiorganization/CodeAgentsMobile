# BDD Suite

Executable specifications for principal CodeAgents Mobile journeys using `pytest-bdd`.

## Structure
- `features/core_journeys.feature` — Gherkin scenarios for auth, provisioning, subscriptions, and file safety.
- `app_simulation.py` — Lightweight domain simulator used by the steps.
- `test_core_journeys.py` — Step definitions binding Gherkin steps to the simulator.

## Running locally
```bash
python -m pip install -r bdd/requirements.txt
python -m pytest bdd -q
```

The suite runs headlessly and is suitable for CI (macOS or Linux runners). VHS recording in CI captures the console output of the suite.
