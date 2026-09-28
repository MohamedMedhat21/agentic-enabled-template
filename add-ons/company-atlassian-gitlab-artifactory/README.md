# Profile: Atlassian + GitLab + Artifactory

An example company profile for teams that:

- track stories in **Jira** and keep design documentation in **Confluence**, both reachable by agents through the **Atlassian MCP server**;
- host code on **GitLab** and review through merge requests, with numeric release tags that trigger delivery pipelines;
- resolve npm and Gradle/Maven dependencies from a private **JFrog Artifactory**, reachable only on the company network or VPN;
- scan commits with a **gitleaks** pre-commit hook;
- ship software that customers install and operate, so logs leave the machine when customers send them to support.

Adjust anything that does not match your team. The replacement text for each slot is in [slots.md](slots.md). Placeholders in double curly braces are filled per repository during bootstrap.

## Prerequisites for agents

- The Atlassian MCP server is configured in the agent tool, and the user has access to the Jira project and Confluence space.
- Agents never store tracker or wiki credentials; the MCP server handles authentication.
