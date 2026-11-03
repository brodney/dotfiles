# Global agent instructions

Shared across all coding agents (Claude Code, Codex, etc.). Keep this tool-agnostic.

## Code style
- Comments: only for unusual or unexpected code; explain why, not what.
- Docstrings by access level:
    - public: required
    - internal: optional
    - private and below (private, fileprivate, etc.): only to clarify non-obvious behavior
- Docstrings describe the API only, never assumptions about server or upstream/downstream behavior (e.g. never comment that the server will only send XYZ if ABC is true).
- Priorities, in order: correctness, API design, clarity. Flag API changes before making them.

## Git / PRs
- Commit or push only when asked. Never run destructive git commands without confirmation.
- No AI attribution lines in commits or PRs.
- PR descriptions: 40 words or less unless absolutely necessary, in plain human phrasing (no "comprehensive", "robust", "leverage").
