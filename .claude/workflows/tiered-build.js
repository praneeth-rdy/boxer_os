export const meta = {
  name: 'tiered-build',
  description: 'Opus implements each handoff package, Sonnet writes tests and smoke-checks, Opus repairs failures; returns a compact report for the Architect to review',
  whenToUse: 'Invoked by /build after the Architect has written handoff packages under .claude/handoffs/<run>/. Not for planning or review - those stay with Fable in the main session.',
  phases: [
    { title: 'Implement', detail: 'developer (Opus) - one agent per handoff package', model: 'opus' },
    { title: 'Test', detail: 'assistant (Sonnet) - tests per package where tests: true', model: 'sonnet' },
    { title: 'Smoke', detail: 'assistant (Sonnet) - flutter analyze + flutter test (+ apk)', model: 'sonnet' },
    { title: 'Fix', detail: 'developer (Opus) - repair smoke failures, bounded rounds', model: 'opus' },
  ],
}

// args: {
//   handoffDir: string,
//   tasks: [{ id: string, file: string, title: string, tests?: boolean }],
//   parallel?: boolean,      // default false - packages usually touch overlapping files
//   maxFixRounds?: number,   // default 2
//   buildApk?: boolean,      // default false - adds `flutter build apk --debug` to smoke
// }

const DEV_SCHEMA = {
  type: 'object',
  properties: {
    status: { type: 'string', enum: ['DONE', 'PARTIAL', 'BLOCKED'] },
    files: { type: 'array', items: { type: 'object', properties: { path: { type: 'string' }, change: { type: 'string' } }, required: ['path', 'change'] } },
    acceptance: { type: 'array', items: { type: 'object', properties: { criterion: { type: 'string' }, ok: { type: 'boolean' }, note: { type: 'string' } }, required: ['criterion', 'ok'] } },
    analyze: { type: 'string' },
    notes: { type: 'string' },
  },
  required: ['status', 'files', 'acceptance', 'analyze'],
}

const CHECK_SCHEMA = {
  type: 'object',
  properties: {
    status: { type: 'string', enum: ['PASS', 'FAIL', 'DONE', 'BLOCKED'] },
    ran: { type: 'array', items: { type: 'string' } },
    result: { type: 'string' },
    failures: { type: 'array', items: { type: 'object', properties: { file: { type: 'string' }, line: { type: 'integer' }, message: { type: 'string' } }, required: ['message'] } },
    files: { type: 'array', items: { type: 'string' } },
    notes: { type: 'string' },
  },
  required: ['status', 'ran', 'result', 'failures'],
}

const handoffDir = args?.handoffDir
const tasks = Array.isArray(args?.tasks) ? args.tasks : []
const parallel = Boolean(args?.parallel)
const maxFixRounds = Number.isInteger(args?.maxFixRounds) ? args.maxFixRounds : 2
const buildApk = Boolean(args?.buildApk)

if (!handoffDir || tasks.length === 0) {
  throw new Error('tiered-build needs args.handoffDir and a non-empty args.tasks array (see .claude/skills/build/SKILL.md)')
}

const implementPrompt = (t) => `Implement the handoff package at ${t.file} ("${t.title}").
Read .claude/CLAUDE.md and docs/architecture.md first, then the package, then only the files it lists.
If you add, remove or rename a file, prefs key or channel method, update the matching row in docs/architecture.md.
Do exactly what the package specifies; stop with STATUS: BLOCKED if anything required is missing.
Run flutter analyze on your work and dart format on touched files. Do not write tests unless the package assigns them to you.
Work on the currently checked-out branch: no worktrees, no branches, no git add/commit/stash - the user commits.`

const testPrompt = (t, dev) => `Write tests for the change described in the handoff package at ${t.file} ("${t.title}").
The developer reports these files changed: ${dev.files.map((f) => f.path).join(', ') || '(none listed)'}.
Read .claude/CLAUDE.md (Conventions → tests) and the package's Acceptance criteria + Verification sections; test those behaviours.
Put tests under test/ mirroring lib/ paths. Mock SharedPreferences, platform channels and timers as described in CLAUDE.md.
Run flutter test on the files you wrote. Do not modify lib/. No worktrees, no branches, no git add/commit/stash - the user commits.`

const smokePrompt = () => `Smoke-check the working tree for the Boxer OS project.
Run, in order: flutter analyze; flutter test${buildApk ? '; flutter build apk --debug' : ''}.
Compare analyze against the baseline in .claude/CLAUDE.md (pre-existing infos are NOT failures; new errors/warnings/infos are).
Report PASS only if analyze has no new issues, all tests pass${buildApk ? ', and the apk builds' : ''}. List at most 5 failures as file:line - message. Do not edit any files, do not touch git.`

const fixPrompt = (smoke, round) => `Fix round ${round}: the smoke check failed on the current working tree.
Failures reported by the assistant:
${smoke.failures.map((f) => `- ${f.file || '?'}${f.line ? ':' + f.line : ''} - ${f.message}`).join('\n')}
Assistant notes: ${smoke.notes || '(none)'}
The change being built is described by the handoff packages in ${handoffDir}/ (read plan.md and the task files).
Fix only what is needed to make these failures pass, within the scope of those packages. Run flutter analyze and flutter test yourself before returning. No worktrees, no branches, no git add/commit/stash - the user commits.`

// ---- Implement (+ per-package tests), sequential by default ----------------------------------
phase('Implement')
log(`${tasks.length} handoff package(s) in ${handoffDir}${parallel ? ' - parallel' : ' - sequential'}`)

const implementOne = (t) =>
  agent(implementPrompt(t), { label: `dev:${t.id} ${t.title}`, phase: 'Implement', agentType: 'developer', model: 'opus', schema: DEV_SCHEMA })

const testOne = (t, dev) =>
  agent(testPrompt(t, dev), { label: `test:${t.id} ${t.title}`, phase: 'Test', agentType: 'assistant', model: 'sonnet', schema: CHECK_SCHEMA })

const results = []
if (parallel) {
  const out = await pipeline(
    tasks,
    (t) => implementOne(t),
    async (dev, t) => {
      if (!dev) return { task: t, dev: null, tests: null }
      const tests = dev.status === 'DONE' && t.tests ? await testOne(t, dev) : null
      return { task: t, dev, tests }
    },
  )
  results.push(...out.filter(Boolean))
} else {
  for (const t of tasks) {
    const dev = await implementOne(t)
    if (!dev) { results.push({ task: t, dev: null, tests: null }); continue }
    log(`dev:${t.id} → ${dev.status} (${dev.files.length} file(s))`)
    if (dev.status === 'BLOCKED') {
      results.push({ task: t, dev, tests: null })
      log(`stopping: task ${t.id} is BLOCKED - ${dev.notes || 'see acceptance'}`)
      break
    }
    const tests = dev.status === 'DONE' && t.tests ? await testOne(t, dev) : null
    if (tests) log(`test:${t.id} → ${tests.status} - ${tests.result}`)
    results.push({ task: t, dev, tests })
  }
}

const blocked = results.filter((r) => !r.dev || r.dev.status === 'BLOCKED')
if (blocked.length === results.length) {
  return { outcome: 'BLOCKED', handoffDir, tasks: results, smoke: null, fixRounds: 0 }
}

// ---- Smoke → fix loop -------------------------------------------------------------------------
phase('Smoke')
let smoke = await agent(smokePrompt(), { label: 'smoke:0', phase: 'Smoke', agentType: 'assistant', model: 'sonnet', schema: CHECK_SCHEMA })
let fixRounds = 0
while (smoke && smoke.status === 'FAIL' && fixRounds < maxFixRounds) {
  fixRounds += 1
  log(`smoke FAIL (${smoke.failures.length} failure(s)) - fix round ${fixRounds}/${maxFixRounds}`)
  await agent(fixPrompt(smoke, fixRounds), { label: `fix:${fixRounds}`, phase: 'Fix', agentType: 'developer', model: 'opus', schema: DEV_SCHEMA })
  smoke = await agent(smokePrompt(), { label: `smoke:${fixRounds}`, phase: 'Smoke', agentType: 'assistant', model: 'sonnet', schema: CHECK_SCHEMA })
}
if (smoke && smoke.status === 'FAIL') log(`still failing after ${maxFixRounds} fix round(s) - handing back to the Architect`)

return {
  outcome: !smoke ? 'UNKNOWN' : smoke.status === 'PASS' ? (blocked.length ? 'PARTIAL' : 'PASS') : 'FAIL',
  handoffDir,
  tasks: results,
  smoke,
  fixRounds,
}
