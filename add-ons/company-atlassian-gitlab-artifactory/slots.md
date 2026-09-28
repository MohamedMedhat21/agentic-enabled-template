# Slot content: Atlassian + GitLab + Artifactory

Replace the content between each slot's markers with the text below, then fill the placeholders from the bootstrap audit.

## work-items

```markdown
- If you are given a Jira key (`{{JIRA PROJECT KEY}}-####`), read the issue through the Atlassian MCP: description, acceptance criteria, linked issues, tasks, sub-tasks and comments. Otherwise, use the story as pasted in chat.
- Jira is read-only by default. Post a comment only after asking, and never transition, assign or create issues.
```

## design-docs

```markdown
Confluence space `{{SPACE KEY}}`. Treat these pages as design intent; the code wins where they differ. Read them through the Atlassian MCP.

| Page                           | Use for            | Known drift from code                  |
| ------------------------------ | ------------------ | -------------------------------------- |
| [{{PAGE TITLE}}]({{PAGE URL}}) | {{WHAT IT IS FOR}} | {{DRIFT FOUND DURING THE AUDIT, or —}} |
```

## vcs-flow

```markdown
- Branch off `{{BASE BRANCH}}` and merge back into it. Other integration branches are used only when the user explicitly names them.
- Branch names start with the Jira key (for example `{{JIRA PROJECT KEY}}-1234-short-slug`). Commit subjects use `[{{JIRA PROJECT KEY}}-####]: Imperative summary`, optionally with a conventional type, as in `[{{JIRA PROJECT KEY}}-1234] feat(api): ...`.
- Changes go through a GitLab merge request. {{RELEASE TRIGGER, for example: numeric x.y.z tags trigger release pipelines.}}
```

## package-registry

For `AGENTS.md`, Scope and setup:

```markdown
- Dependencies come from the company Artifactory, reachable only on the company network or VPN. npm reads `{{NPM TOKEN VARIABLE}}` through the committed `.npmrc`; Gradle or Maven reads `{{REGISTRY USER VARIABLE}}` and `{{REGISTRY PASSWORD VARIABLE}}` (or the equivalent `-P` properties). Never write credentials into files, logs, commands shared in chat, or test fixtures.
```

For `docs/setup.md`, Prerequisites:

```markdown
- Connect to the company VPN; Artifactory and the GitLab container registry are not reachable otherwise.
- Generate a personal, read-only Artifactory identity token (Artifactory, your avatar, then **Set Me Up** or **Generate an Identity Token**) and set it in your shell as `{{NPM TOKEN VARIABLE}}` and `{{REGISTRY PASSWORD VARIABLE}}`, with your username in `{{REGISTRY USER VARIABLE}}`. Check how the build files read these values before relying on a `gradle.properties` or `settings.xml` file. Never commit, share or log a token.
```

## secret-scanning

For `AGENTS.md`, Git workflow:

```markdown
- A gitleaks pre-commit hook (`.pre-commit-config.yaml`, rules in `{{GITLEAKS CONFIG PATH}}`) scans every commit. Never bypass it (`--no-verify`).
```

For `docs/setup.md`, Commit hooks:

```markdown
1. Install Python 3.7 or later.
2. Install the tool: `pip install pre-commit`
3. From the repository root, enable the hook: `pre-commit install`
4. Optionally scan the whole working tree once: `pre-commit run --all-files`

The first run downloads gitleaks from GitHub.
```

## onboarding

```markdown
Company onboarding stays on the Confluence page [{{ONBOARDING PAGE TITLE}}]({{ONBOARDING PAGE URL}}): GitLab, Jira and Confluence accounts, Git and SSH keys, IDE licenses, container tooling, and design-tool access.
```

## compliance

```markdown
- Customers export logs and send them to support, so treat every log line as leaving the machine. Never log tokens, passwords, license or key material, or personal data. Keep the correlation ID in the log pattern.
- {{LOG INVENTORY: link the page that documents log formats, locations, retention and access, if the product keeps one.}}
- Health is the only monitoring endpoint exposed; API documentation UIs and developer tools stay disabled in production; allowed origins come from environment configuration. Do not relax these.
```
