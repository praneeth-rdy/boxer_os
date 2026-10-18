# Working on Boxer OS

Pointers only. Nothing is defined here, so nothing here can go stale: follow the links.

Applies to any assistant (Claude Code, Codex, an editor agent) and to humans.

## Read before you start

1. `README.md` - what the app is, how to run it, the memory protocol in short.
2. `memory/current.md`, then the top of `memory/log.md` - where the work actually stands.
3. `docs/product.md` and `docs/architecture.md` - the why and the how.
4. `docs/backlog.md` and `docs/review-log.md` - what is planned and what is known broken.
5. `.claude/CLAUDE.md` - stack, commands, and the code guidelines (naming, structure, error
   handling, comments, tests). These apply whatever tool you are using; only the tiered agent
   workflow at the bottom of that file is Claude Code specific.
6. Any `memory/notes/` file naming the area you are about to touch.

## Write before you stop

`memory/README.md` has the protocol. In short: rewrite `memory/current.md`, add a dated entry to
`memory/log.md`, add a `memory/notes/<slug>.md` for anything a later reader would otherwise
rediscover, update `docs/architecture.md` if the structure changed, and mark the backlog item
done. Promote settled notes into `docs/` and delete them from `memory/`.

## Two standing rules

- Work on the checked-out branch. Do not branch, stage, commit, stash, or push: the owner
  reviews and commits.
- No new dependencies without the owner agreeing to one by name and version.
