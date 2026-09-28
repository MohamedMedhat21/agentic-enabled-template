# Development environment setup

This guide covers the setup steps that depend on this repository.

<!-- slot:onboarding -->

Ask the team lead for access to the repository, the identity provider's test realm and the staging environment.

<!-- /slot:onboarding -->

Tool and framework versions are not repeated here; read them from `backend/build.gradle.kts`, the Gradle wrapper properties and `frontend/package.json`.

## 1. Prerequisites

- Docker with Compose, for the local database and for Testcontainers.
- Create branches from `main` (see [AGENTS.md](../AGENTS.md#git-workflow)).
<!-- slot:package-registry -->
- No registry credentials are needed; dependencies come from Maven Central and npmjs.
<!-- /slot:package-registry -->

## 2. Commit hooks

<!-- slot:secret-scanning -->

1. Install Python 3.8 or later, then `pip install pre-commit`.
2. From the repository root, run `pre-commit install`.
3. Optionally scan everything once: `pre-commit run --all-files`.

Never skip hooks with `git commit --no-verify`.

<!-- /slot:secret-scanning -->

## 3. Backend

- Install JDK 21. The Gradle wrapper downloads Gradle; do not install it separately.
- Start the database from the repository root: `docker compose -f compose.dev.yml up -d postgres`.
- Run `./gradlew bootRun --args='--spring.profiles.active=local'` in `backend/`. The `local` profile validates tokens against the identity provider's test realm, configured in `application-local.yml`.

## 4. Frontend

- Install Node.js 22, then in `frontend/` run `npm ci` and `npm start`.
- Open <http://localhost:4200>. The dev server proxies `/api` to `http://localhost:8080`.

## 5. Local environment

| File              | Purpose                                                              |
| ----------------- | -------------------------------------------------------------------- |
| `compose.dev.yml` | PostgreSQL for local development                                     |
| `compose.e2e.yml` | Backend, frontend and database images for the Playwright suite in CI |
