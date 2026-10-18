# Codex setup

Run `codex` from the repository root, or open this folder in the Codex app or IDE extension.
`AGENTS.md` is the instruction entry point; follow its reading order for shared memory,
product docs and coding conventions. The Codex workflow is described there too.

`.codex/config.toml` supplies project defaults:

- `workspace-write`: commands can write within the workspace and temporary directories.
- `on-request`: Codex requests approval when it needs to run outside the sandbox.
- Sandbox network access is disabled; dependency downloads may need approval.

Flutter and Android tooling may also need approval to update SDK or Gradle caches outside the
workspace. Keep any additional writable paths in personal settings or pass `--add-dir` for a
specific session; do not commit absolute paths for one machine.

Model, reasoning effort, credentials, project trust and personal integrations stay in user
settings. This repo does not select a model or change `~/.codex/`.

Project config loads only for trusted projects. If Codex asks whether to trust this checkout,
review it and accept the prompt to load these defaults. Start a new session after changing
configuration or instructions. CLI overrides and managed requirements can take precedence.

No extra MCP servers, plugins or skills are required to develop this app. The existing Flutter
commands in `.claude/CLAUDE.md` and CI remain the validation workflow.

References: [configuration basics](https://learn.chatgpt.com/docs/config-file/config-basic),
[configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference),
[instruction discovery](https://learn.chatgpt.com/docs/agent-configuration/agents-md).
