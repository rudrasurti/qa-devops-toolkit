# QA DevOps Toolkit

![CI](https://github.com/rudrasurti/qa-devops-toolkit/actions/workflows/ci.yml/badge.svg)

DevOps building blocks for test teams: a **mock API with WireMock**, a **Docker Compose** test environment, and a **reusable GitHub Actions workflow** that any repo can call. Tests run in seconds, never depend on a shared server being up, and work offline.

## Why mock the API?

| Problem with a real test server | How the mock fixes it |
|---|---|
| Server down or slow, so tests fail for no reason | WireMock runs next to the tests in the same Compose network |
| Hard to force errors (404, 403, slow responses) | Each case is a small JSON stub in `wiremock/mappings/` |
| Shared data changes between runs | Responses are fixed, so every run is the same |

## What's inside

```
.
├── wiremock/mappings/          # 9 stubs: ping, auth ok/bad, create, get, 404, delete 201/403, slow
├── tests/booking_mock.robot    # 9 Robot Framework tests against the mock
├── docker-compose.yml          # mock-api (WireMock) + tests (Robot Framework)
├── Dockerfile.tests
└── .github/workflows/
    ├── robot-compose.yml       # reusable workflow (workflow_call)
    └── ci.yml                  # validates configs, then calls the reusable workflow
```

## Run locally

```bash
docker compose up --build --abort-on-container-exit --exit-code-from tests
# results in ./results (report.html, log.html, xunit.xml)
```

Only the mock:

```bash
docker compose up mock-api
curl http://localhost:8080/ping
```

## Use the reusable workflow in your repo

```yaml
jobs:
  api-tests:
    uses: rudrasurti/qa-devops-toolkit/.github/workflows/robot-compose.yml@main
    with:
      compose-file: docker-compose.yml
      test-service: tests
      report-title: API tests (mock)
```

It builds and starts the Compose stack, runs the tests, prints mock logs if something fails, posts a summary with [QA Report Bot](https://github.com/rudrasurti/qa-report-bot), uploads the results and cleans up.

## CI

| Job | What it checks |
|---|---|
| Validate | All WireMock stubs are valid JSON, Compose file is valid, Robot dry run passes |
| Tests | Calls the reusable workflow: full Compose run with a test summary |

---

**Rudra Surti** · Senior SDET · [Website](https://rudrasurti.github.io) · [LinkedIn](https://www.linkedin.com/in/rudra-surti/)
