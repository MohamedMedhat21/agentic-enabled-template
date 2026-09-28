# Development environment setup

This guide covers the setup steps that depend on this repository.

<!-- slot:onboarding -->

Accounts, access requests, licenses and other company onboarding are covered by {{ONBOARDING DOCUMENT OR CONTACT}}.

<!-- /slot:onboarding -->

Tool and framework versions are not repeated here because copies drift. Read them from {{FILES THAT DEFINE VERSIONS}}.

## 1. Prerequisites

- {{NETWORK: VPN or network access needed for registries and services, or "No special network access is needed".}}
- Clone the repository and create branches from `{{BASE BRANCH}}` (see [AGENTS.md](../AGENTS.md#git-workflow)).
<!-- slot:package-registry -->
- {{REGISTRY CREDENTIALS: how to obtain a token and which environment variables hold it. Never commit, share or log a token.}}
<!-- /slot:package-registry -->

## 2. Commit hooks

<!-- slot:secret-scanning -->

{{SECRET SCANNER SETUP: install and enable the pre-commit hook, or state that none is configured.}} Never skip hooks with `git commit --no-verify`.

<!-- /slot:secret-scanning -->

## 3. {{PROJECT OR AREA, for example Backend}}

- {{TOOLCHAIN: runtime and build tool, and whether a wrapper removes the need to install it.}}
- {{CREDENTIALS FOR THIS PROJECT, by variable name, and how the build reads them.}}
- {{HOW TO START AND TEST, or a link to the project README.}}

## 4. {{PROJECT OR AREA, for example Frontend}}

- {{TOOLCHAIN, INSTALL COMMAND (prefer the lockfile-respecting one), START COMMAND AND URL.}}

## 5. Local environment

{{CONTAINERS OR SERVICES: what each compose or environment file does and which one to use for local development.}}
