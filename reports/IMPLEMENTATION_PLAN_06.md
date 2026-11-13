# Assignment 6: implementation preparation

> Update, 2026-11-13: The prediction is committed and pushed as `a9df821`;
> the 107-test course suite (two skips) and gpt-4o ping passed before coding.
> Part B and the S-plus/results code were committed in an isolated
> `lab-06-split` work copy as `e20aa4c`, preserved in
> `reports/lab-06-split-prep.bundle`. Three official guard replays pass and
> scripted single/batch plumbing runs completed. A real development probe
> failed on `APIConnectionError` before any token usage. Historical "pending"
> and "blocked" entries below describe the initial audit, before this update.


This is a design note, not an implementation or a measured result. It does not
change the predictions. Sources: README, checks/FORMATS.md section 14, the
official checker, and the existing harness interfaces. The separate instructor
handout remains unavailable, so requirements unique to it remain unverified.

## Execution order and ownership

The user will perform Git commits and pushes. First, commit only
`reports/PREDICTIONS_06.md` on `main` and push that commit. Keep that file unchanged
afterward. This is the preliminary prediction checkpoint, not final submission.
The initial index was empty when inspected; verify staged paths before committing.

```powershell
git branch --show-current
git add -- reports/PREDICTIONS_06.md
git diff --cached --name-only
git commit -m "Record Assignment 6 predictions"
git push origin main
```

Proceed with the commit only when the displayed branch is `main` and the staged
file list contains only the prediction. Do not stage all pending setup changes
into this first commit. These commands have not been executed successfully here.

The README separately requires successful tests and model ping before assignment
implementation. After those gates and the prediction checkpoint, create
`lab-06-split` for implementation. Reports, diagrams, interface inspection and
environment diagnosis can be prepared while those steps are pending. Actual
measured runs still require API access from the executing environment.

## Planned files on lab-06-split only

| File | Responsibility |
|---|---|
| ways/split.py | Coordinate investigations, validate findings, serialize publication and check final state |
| split/contract.schema.json | Required worker return fields and structured finding |
| split/guards.py | Wait graph, versioned shared state and combined-state validation |
| split/roles.py | Enforce tool surfaces, issue ownership and observed tool-call accounting |
| prompts/investigator.md | Find a label/file using issue and repository evidence |
| prompts/publisher.md | Publish one accepted finding without reinvestigating it |
| ways/splus.py | Single-agent verification/refinement control using M's matched budget |
| prompts/splus.md | Additional evidence checks before final publication |
| eval/results_06.py | Recompute run rows and report aggregates from native evidence |

Keep arm S, original prompts, fixtures, harness, evaluator, checker and tests
unchanged. Registry calls must still go through the original hook and reviewer.
No way may read `ctx.task.answers`, evaluation answer files or planted solutions.

## Tool surfaces and publication rules

| Role | Registry actions | Local responsibility |
|---|---|---|
| Investigator per issue | read_issue, search_repo, read_file | Return a finding; cannot write |
| Publisher per accepted issue | apply_label, open_pr, post_comment | Use only the accepted issue, label and file |
| Coordinator | Deterministic orchestration and tracker inspection | Allocate budgets, validate, join, serialize, check |

Resolve actual tool/argument names through `harness.roles`. Filter both advertised
schemas and the dispatch function: hiding a schema alone does not restrict calls.
Reject calls about another issue in code. Publication order is label, optional
draft PR, then comment; `file: none` prohibits a PR. Insert disclosure before the
comment enters the registry using the existing helpers in `ways.agent`.

Use `ctx.agent` for every model loop and write model/tool events through that
agent's trace. The coordinator exists before children. Each loop has a distinct
identity because `agent_end` is emitted once. A local return tool is traced but
excluded from the count of registry calls.

## Return contract and acceptance

Require `result`, `status`, `searched`, `not_searched`, `calls_used` and
`could_not_determine`. The finding should include issue ownership, label, file
and evidence; labels come from the harness's allowed labels. Status is one of
`found`, `candidate`, `out_of_budget`.

The tool wrapper derives `calls_used` from actual registry calls and `searched`
from the exact query/path arguments of attempted searches and reads, deduplicated
in encounter order. Include unsuccessful calls in these observed facts, as the
official checker does. Keep these separate from evidence paths successfully read.
Do not let model estimates overwrite observed fields.

Record `worker_return` before publication. Its `valid` flag must agree with
`harness.schema.errors` against the saved schema: the official checker recomputes
this exact comparison. Record ownership, evidence and uncertainty acceptance
separately; a schema-valid return may still be held for those reasons. Never act
on an invalid return or a rejected finding. Budget exhaustion must remain visible
as uncertainty, not be converted into a fabricated successful finding.

The schema validator supports only a subset of JSON Schema. Use supported types,
required properties, enum, additionalProperties and supported alternatives.
Enforce nonempty strings, path safety and cross-field consistency in code where
the validator lacks the needed keyword.

## Five planned enforcement points

These are the implementation's five checks; confirm terminology against the
separate handout when available.

1. Validate the return's shape and independently check ownership/evidence before
   publication. Retain rejected returns and their reasons in the trace.
2. Bound each loop's turns, tokens and elapsed time; all calls use the shared
   metered client. Reserve a publication allowance instead of giving research
   the whole budget. Retain the existing run and lab ceilings.
3. Use WaitGraph for real outstanding waits. Add dependencies before waiting,
   clear completed dependencies, detect a cycle when its closing edge arrives,
   and select a cycle member other than the coordinator as the cancellation victim.
   Cancellation must prevent further calls; merely logging a stop is insufficient.
4. Protect SharedState content and version with one lock. Compare and update
   atomically; a stale write returns false without changing content/version.
   A reread supplies the new version for retry. Use this guard for live shared
   findings/publication state as well as replay tests.
5. Run check_combined on the tracker's run-scoped end state after the last write.
   For each assigned issue require one parsed comment, exactly its label, and
   exactly one matching PR for a named file or no PR for `none`. Do not consult
   answer keys. Record violations even when the task ultimately fails evaluation.

Batch investigations may overlap; publication is serialized. Confirm registry
thread safety before enabling overlapping tool dispatch. The shared model client
checks spend before calls and accounts for responses afterward: concurrent
in-flight requests need conservative local admission/reservation, not an
assumption that the root client alone prevents all overshoot.

## S-plus and measurement

S-plus must remain one sequential decision-maker with access to the complete tool
surface. Spend additional compute on substantive verification/refinement before
publication, with no investigator/publisher handoff. Prevent duplicate final
comments/PRs across any retries. Do not pad requests simply to consume tokens.
Validate the design on scripted and development runs before fixed-task sweeps.

Run the complete eight-task directory for every arm, three sweeps each. S and M
use 250,000 tokens per issue (1,250,000 per batch). Finish M before starting
S-plus with `--match split`. Use `REVIEWER=scripted:approve-all` throughout.

The checker compares both configured and actual spend: each S-plus task budget
must match the earlier M mean within 1%; actual S-plus mean by task kind may not
exceed M by 25%, and may not be more than 25% below M where M spent more than S.
Report task-level spend as well. A budget match alone does not support a causal
claim about topology. Treat failure to match spend as a limitation, not a reason
to remove an unfavorable run.

The aggregator must include all 72 finished real runs, including ordinary crashes
and wrong answers. Exclude scripted/oracle, development, unfinished quota and
rate-limit runs. Read pass/parts from `eval.check_task.check_task`, tokens/wall
time from run_end, and constants from run_start. Summarize each arm by kind,
task and sweep, and inspect every failed M run for the first failure and its
per-agent evidence. Do not fill empirical report fields before data exists.

## Windows test diagnosis

The original resume test mocks `_run_way`, which normally closes the trace.
The mock retains arguments, including TraceWriter objects, in reference cycles.
Windows temporary-directory cleanup then cannot unlink the open trace files.
Changing garbage-collector thresholds alone did not resolve the error. Explicit
collection immediately before TemporaryDirectory cleanup allowed the targeted
test to pass with its assertions unchanged.

`reports/test_06_windows.ps1` supplies that runtime cleanup timing adjustment and
UTF-8, runs the original discovery suite and preserves failures. It does not
modify protected files, replace tests or suppress cleanup exceptions. Its result
must be distinguished from the default unwrapped command, which previously
failed. The full-suite result is recorded in `preflight_windows_gc_tests_06.txt`:
107 tests run, 105 passed, two original skips, exit 0. A subsequent protected-file
integrity check found no flags. Real API preflight and Git checkpoints are still
pending.

## Final handoff

The user will commit/push `lab-06-split` and `lab-06-split-final`, then commit
evidence and write-ups on `main` and push `lab-06`. Transfer evidence without
merging implementation onto main. Run the official checker on main against the
split tag, retain integrity results, and verify the remote refs. Staff collaborator
access and the Canvas repository URL remain separate submission requirements.

## AI assistance

Codex prepared this design from local course interfaces and checker code and
diagnosed the Windows test cleanup error. No implementation, experiment result,
successful API preflight or student review is claimed by this document.
