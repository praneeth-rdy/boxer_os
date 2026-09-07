# Project memory

Canonical, machine-independent memory for Boxer OS agents. Any Claude session, on any
machine, reads every `.md` file here at the start of substantial work and updates the
relevant file (or adds a new one, one fact per file, kebab-case name) when a durable
decision, preference or state change is made. Keep entries short, factual and current;
delete what becomes wrong. Commit memory changes with the docs commits.

The per-machine auto-memory under `~/.claude/projects/.../memory/` holds only a pointer here.
