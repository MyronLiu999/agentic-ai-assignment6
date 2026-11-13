# Assignment 6 requirement audit and execution status

> Update, 2026-11-13: Prediction commit `a9df821` is pushed. Original
> course tests and API ping passed; the split implementation is in commit
> `e20aa4c`, saved as `reports/lab-06-split-prep.bundle`. Official guard
> replays scored 8/8 each for deadlock, lost update, and combined state.
> Scripted runs completed but do not count as measured results. The real
> development probe hit `APIConnectionError` at zero tokens. The checklist
> below is the pre-implementation audit and has not been individually regraded.


Status: **API/Git preflight pending; Windows-compatible test invocation passes;
not a completed submission**.

Sources reviewed: the complete README (209 lines), the complete Assignment 6
format specification (`checks/FORMATS.md`, section 14), the complete
`checks/check_06.py` (821 lines), both report templates, Makefile, settings,
pricing, architecture/change notes, and the harness/tool interfaces relevant to
the split. The instructor's separate handout and lecture slides were not found
in the course directories searched or in matching uploaded files. Requirements
unique to that handout cannot yet be certified as covered.

## Preflight evidence and blockers

### Retry after the API update (November 12, 2026, America/Chicago)

- The existing `.env` loads successfully through `reports/start_06.ps1`; its
  secret value was not printed. Authentication remains unverified because the
  real gpt-4o ping still fails with `APIConnectionError: Connection error`.
- `git ls-remote origin HEAD` fails with `getaddrinfo() thread failed to start`.
- Staging only `reports/PREDICTIONS_06.md` fails with
  `.git/index.lock: Permission denied`. No commit, branch, tag or push was made.
- With the configured `PYTHONUTF8=1`, the unchanged original suite again runs
  107 tests: 104 pass, two are skipped by the original tests, and the resume test
  errors during Windows temporary-file cleanup (WinError 32). See
  `reports/preflight_retry_tests_06.txt`. A preceding invocation without loading
  the environment also encountered default-GBK decoding errors; those disappear
  after the provided setup helper loads the UTF-8 setting.
- `python checks/check_06.py --here` still reports zero measured runs, 0/80
  automated points and no protected-file integrity flags. Its process exits
  successfully even though the assignment is incomplete.
- The current execution session still restricts network access and Git metadata
  writes. The user's authorization is recorded, but these capabilities have not
  become available to the running session. The preflight gate remains unmet;
  no assignment implementation or measured experiments have started.

### Follow-up: user handles Git; independent preparation completed

- The user will handle commits and pushes. The required first checkpoint is only
  `reports/PREDICTIONS_06.md`, committed by itself on main and pushed before the
  experimental work; final submission follows the implementation and measurements.
- Diagnosed the Windows cleanup error: the mocked `_run_way` retains trace
  objects through reference cycles instead of running the real trace closer.
  Explicit garbage collection just before temporary-directory cleanup resolves
  the targeted test. Lowering GC thresholds alone did not resolve it.
- `reports/test_06_windows.ps1` runs the unchanged full suite in UTF-8 with that
  cleanup timing adjustment: **107 tests run, 105 passed, 2 original skips**,
  exit 0. See `reports/preflight_windows_gc_tests_06.txt`. This is a compatibility
  invocation; it does not claim the default unwrapped command stopped failing.
- Protected-file integrity was checked afterward: no flags. No test, harness,
  checker, answer fixture or baseline source was edited.
- `reports/IMPLEMENTATION_PLAN_06.md` now specifies role/tool boundaries, return
  accounting, guard behavior, tracing, S-plus measurement constraints and handoff.
  It is preparation only; real API ping and the prediction commit/push remain
  outstanding, and no assignment implementation or measured run is claimed.

### Initial inspection (historical results)

| Check | Observed result | Consequence |
|---|---|---|
| Existing repository | `main`, starter `e886e1fab0ec1f0bb9e074a053c4cade196b3d2e`, origin `https://github.com/MyronLiu999/agentic-ai-assignment6.git` | No split branch or submission tags exist. |
| Python/dependencies | Python 3.14.0; local `.venv` created; dependencies reused from Assignment 5 after pip network access failed; `pip check` passes | Local harness commands run. `make` is unavailable, so use its equivalent Python commands. |
| Model setup | Copied `provider`, `model`, `base_url`, `api_key_env` from Assignment 5: OpenAI-compatible, gpt-4o, null, OPENAI_API_KEY | Only permitted model settings changed. API key remains in the environment. |
| Pricing | Copied the Assignment 5 gpt-4o row, including source and original read date | No original price row removed or changed. |
| Original harness tests | 107 run: 104 passed, 2 skipped, 1 error | `make test` equivalent has not passed; see `preflight_tests_06.txt`. |
| Failing test | `tests.test_lab05.ResumeTests.test_held_and_stopped_resume_and_completed_does_not`; WinError 32 while removing the open `held-run.jsonl` in temporary-directory cleanup | Original test mocks `_run_way`, which normally closes the trace. This is a Windows handle-cleanup problem, not a failed triage assertion. Tests and harness have not been edited or skipped to hide it. |
| Real API ping | `APIConnectionError: Connection error`; `not ready` | No successful vendor/tool/pricing preflight, and no measured runs started. |
| Git write | `git add` and `git commit` fail: `.git/index.lock`: Permission denied | Prediction cannot be committed; branch/tag creation is blocked by the read-only Git metadata permission. |
| Git network | `git push origin main` fails: `getaddrinfo() thread failed to start` | Prediction and final artifacts cannot be pushed in this environment. |
| Protected-file hashes | Initial CRLF checkout caused 30 integrity flags; each file was verified against its original Git blob and restored to exactly those original LF bytes | All 30 published hashes now match; no protected source content changed. `core.autocrlf=true` could reintroduce CRLF on a later checkout. |
| Assignment checker | 0/80 automated before implementation; no real runs, no split tag | A successful checker process exit alone does not mean the assignment passed. |

README line 63 requires both test and ping to pass before writing code. README
line 69 requires the prediction to be committed and pushed by itself first.
Implementation therefore has not begun. This preserves the experiment order.

## Setup and immutable boundaries

| ID | Requirement | Source | Status/evidence |
|---|---|---|---|
| P01 | Read the separate handout's Getting started | README:16 | Missing source; still required. |
| P02 | Python >=3.10, Git, dependencies; setup and activation | README:30-43 | Python/Git/dependencies ready; use Windows `.venv/Scripts/python.exe`. |
| P03 | Use one tool-calling model; keep API credentials out of Git and reports | README:34-61 | Configured gpt-4o; no key printed or written. |
| P04 | Copy only the four permitted model settings | README:45-48 | Done; all ceilings, jobs, effort and output cap preserved. |
| P05 | Add model's price with source/read date; no unpriced real calls | README:46; pricing comments | Row copied; real acceptance still needs ping. |
| P06 | Test and ping both pass before implementation | README:63 | Blocked, as above. |
| P07 | REVIEWER=scripted:approve-all on every experimental run | README:60 | Required for future runs; no experiments started. |
| P08 | Keep arm S's four files unchanged on either branch | README:82 | Preserved; original bytes verified. |
| P09 | Do not change original agent/planned/state/policy/bin/tools on main | README:83 | Preserved. |
| P10 | Never change task answers or planted replay fixtures | README:84-85 | Preserved; original bytes verified. |
| P11 | Do not change evaluator, harness, runner, checks or tests | README:86-89 | Preserved. |
| P12 | Main may change only allowed report/decision/evidence paths, CHANGES.md and model lines | FORMATS 14.9; checker:388 | Preserved so far; verify against root commit before submission. |
| P13 | Experimental ways, split package, results script and custom prompts stay on lab-06-split | README:92; FORMATS 14.9 | Not created because branch cannot yet be created. |
| P14 | Do not exceed session/lab ceilings or use --over-budget without asking | README:175-178 | No measured tokens spent; ceilings unchanged. |

## Part A: before experiments

| ID | Requirement | Status |
|---|---|---|
| A01 | Explain considered role pairs, mid-task information needs, communication method and cost | Drafted in LAB_06.md Part A. |
| A02 | Discuss one issue separately from a five-issue batch | Drafted. |
| A03 | Include an architecture sketch | Drafted as a compact Mermaid graph. |
| A04 | Evaluate four gates in order and stop at the first failure | Drafted; later gates marked not_reached where appropriate. |
| A05 | State intended benefit and necessary condition | Drafted: possible parallel batch latency benefit requires independent work. |
| A06 | Write reports/PREDICTIONS_06.md before split implementation/runs | File prepared; no split code or runs exist. |
| A07 | Commit prediction alone on main, push it, and record the commit ID | Blocked by Git metadata/network restrictions. Do not stage all files for this commit. |
| A08 | Never edit the prediction in a subsequent main commit | Must preserve after first successful commit. |
| A09 | Prediction commit timestamp precedes earliest real split task run | Enforce before starting measured M; no timestamps altered. |

## Part B: implementation and free validation

All rows in this section remain **pending**. They specify acceptance criteria,
not a claim that code exists.

| ID | Requirement | Source / verification |
|---|---|---|
| B01 | Create lab-06-split and ways/split.py with run(ctx) | README order/path tables. |
| B02 | Define coordinator and roles, with executable tool-surface restrictions | Report Part B; proposed read-only investigators and write-only publishers. |
| B03 | Route every course tool call through ctx.tools and existing policy hook | README:83, 145-147; no direct tracker writes. |
| B04 | Keep all model prompts under prompts/ | README:180. |
| B05 | Allocate bounded worker budgets and coordinator reserve; use ctx.budget/ceiling | FORMATS 14.1-14.3; report Part B. |
| B06 | Use ctx.agent IDs and parent links; create parent before children | FORMATS 14.3. |
| B07 | Every M model/tool trace line has agent and parent | Checker one-trace test. |
| B08 | Worker client charges the shared run client; per-agent sums agree with run_end within 1% | FORMATS 14.3; checker:543. |
| B09 | End each agent trace once; do not reuse an ended agent for another loop | README:163-168. |
| B10 | Create split/contract.schema.json supported by harness.schema.errors | FORMATS 14.4. |
| B11 | Contract has result object and status enum found/candidate/out_of_budget | FORMATS 14.4. |
| B12 | Contract has searched, not_searched, could_not_determine string arrays | FORMATS 14.4. |
| B13 | Contract calls_used is an integer counting actual registry calls, excluding local return tool | FORMATS 14.4; checker worker_facts. |
| B14 | searched records every actual query and read path, each once | Derive from observed tool calls; never trust model's self-report. |
| B15 | Log every worker_return before acting, with worker/contract/valid/errors | FORMATS 14.4. |
| B16 | Reject invalid returns; never act on them | Schema plus task/ownership validation, enforced in code. |
| B17 | Implement WaitGraph.wait and victim | FORMATS 14.6; victim belongs to cycle and is never coordinator. |
| B18 | Detect recorded patch/test worker cycle by turn 2; no false cycle for acyclic fixture | Official deadlock/no_deadlock replays. |
| B19 | Record wait(waiter,on,what,turn), worker_stopped(worker,reason) when applicable | FORMATS 14.5; guards must be used in live orchestration. |
| B20 | Implement SharedState(initial), read -> (content,version), write -> bool, content | FORMATS 14.6. |
| B21 | Atomic compare-and-set refuses stale write without modifying content | Lost-update replay: A succeeds, B refused, A content retained. |
| B22 | B can reread and successfully write new version | Lost-update replay's retry test. |
| B23 | Implement check_combined(task,state), without reading answer keys | Use runtime tracker state and public task invariants. |
| B24 | Exactly one valid triage comment per issue, exactly its label, one matching PR for a file or none for file:none | FORMATS 14.6. |
| B25 | Reject planted wrong state and accept planted right state | Official combined-result replay. |
| B26 | Run combined check after the last write; record passed and violations | FORMATS 14.5. |
| B27 | Add disclosure in code before comment enters registry | README:149-151; reuse with_disclosure/disclosure_line. |
| B28 | Label then PR if needed, comment last; no extra comments/PRs | FORMATS 1 and 14; preserve idempotent registry behavior. |
| B29 | Use ScriptedWorkers to test plumbing, then development issues | README:70, 100-104; scripted output is intentionally always bug/dedupe.ts. |
| B30 | Run python checks/check_06.py --here before tagging | README:74-76. |
| B31 | Explain five checks with code locations in report | Report template; confirm intended five against missing handout before finalizing. |

## Part C: experiments, aggregation and failure analysis

All implementation/measurement rows remain **pending**; observed real run count
is zero. Passing the assignment does not require hiding or changing failed runs.

| ID | Requirement | Acceptance criterion |
|---|---|---|
| C01 | Implement eval/results_06.py and ways/splus.py on split branch | Test using ScriptedWorkers before real model runs. |
| C02 | Run eight fixed tasks three times in each of S, M, S-plus | 24 finished real runs/arm; 72 total, 18 single and 6 batch per arm. |
| C03 | S is untouched agent way; M is split; S-plus is single-agent extra-spend control | Do not substitute an oracle or scripted model for any measured arm. |
| C04 | S and M have same per-task ceiling | --budget 250000 per issue; five-issue task budget 1,250,000. |
| C05 | Finish M before starting S-plus with --match split | Each S-plus task budget equals prior M mean spend on that task within 1%. |
| C06 | Verify actual spend, not merely configured budget | S-plus mean <=125% M; if M>S, S-plus mean >=75% M, by kind. Also report each task. |
| C07 | Hold model, definitions, evaluator, task set and reviewer fixed | All real run_start.constants agree; use same eight-task directory command in sweeps. |
| C08 | Record budgets separately from the five constants object | constants contains model, schemas_sha, checks_sha, reviewer, task_ids. |
| C09 | All agents share run's hard ceiling; lab total below 20,000,000 | Read run_end totals and ledger; never silently raise limits. |
| C10 | Resume rate-limited/quota sweeps with same command | Harness skips finished pairs; crashes count as finished failures. |
| C11 | If implementation changes after measuring, discard that arm before rerunning | Use harness --discard; ledger spend remains. Never select only favorable runs. |
| C12 | Agents never read ctx.task.answers or evaluation answer files | Only evaluator may use answers. |
| C13 | Ground every result in eval.check_task.check_task | Tracker reads scoped to run_id; no agent-declared success. |
| C14 | Ground task passes in all issue parts | Exact comment label/file, active label, matching open PR; all five must pass for batch. |
| C15 | Write one results/runs_06.jsonl row per finished measured run | run_id, arm, way, task, kind, sweep, passed, parts, tokens, wall_s. |
| C16 | Exclude scripted/oracle, dev and unfinished quota/rate-limit runs from measured table | Do not exclude ordinary model errors or crashes. |
| C17 | Tokens and wall time come from run_end | No estimates or invented numbers in measured output. |
| C18 | Populate LAB_06.json arms for each arm and kind | runs, passes, per_task, sweep_min/max, all_three, mean_tokens, mean_wall_s. |
| C19 | Fill six-row report results table | Include range of sweep pass counts and tasks all three sweeps passed. |
| C20 | Compute M/S multiplier separately for single/batch and discuss lecture's 15x | Distinguish predictions from observations. |
| C21 | Report task-by-task S-plus/M actual spend | Explain any mismatch and causal limitation. |
| C22 | Answer three spend questions separately for both kinds | spent_more, spend_raises_score, one_agent_as_well, each yes/no in JSON. |
| C23 | Explain inference from S/M alone and how S-plus changes it | Avoid claiming topology benefit that can be explained by extra spend. |
| C24 | Analyze every failed M run | Read agents' tools/writes/waits; locate first failure; include run ID. |
| C25 | Use allowed anomaly names | lost_update, write_skew, deadlock, misalignment, none. |
| C26 | Use allowed MAST names | system_design, inter_agent_misalignment, task_verification. |
| C27 | Populate JSON gates with four ordered verdicts per kind | daily/batch; pass, fail, not_reached; consistent with Part A. |
| C28 | Disclose AI assistance accurately | Name tool, what it wrote, and actual verification; do not claim manual review that did not occur. |

## Part D and submission

| ID | Requirement | Status / acceptance criterion |
|---|---|---|
| D01 | Decide separately for one issue and five-issue batch | Pending measurements; JSON single/batch each single or split. |
| D02 | State concrete condition for revisiting | Prediction proposes >=25% latency improvement, multiplier <=1.5 and comparable accuracy; final condition must reflect evidence. |
| D03 | Write decisions/0006-topology.md on main | Pending; cite real runs and three-arm comparison. |
| D04 | Add exactly three Assignment 6 change bullets: added, removed, constrained | Pending actual completed work; no claims of unbuilt features. |
| D05 | Keep split code off main even if decision favors split | Main evidence only; experimental implementation lives in branch/tag. |
| D06 | Commit/push final lab-06-split branch and lab-06-split-final tag | Blocked by Git permissions/network. |
| D07 | Bring runs, tracker database/archives, results, logs and reports to main without merging code | Pending runs; retain native artifacts, not only report summaries. |
| D08 | On main run official checker reading guards/schema from final split tag | Pending tag; --here alone is insufficient for final submission. |
| D09 | Automated score covers 80; report/decision carry remaining 20 | Never describe 80/80 as guaranteed 100/100. |
| D10 | Review integrity flags and all human-review requirements | Current protected hashes fixed; rerun after checkout/tag changes. |
| D11 | Commit main with final evidence; create lab-06 tag; push main and tag | Pending; an unpushed tag is not submitted. |
| D12 | Private repository, course staff collaborator, repository URL in Canvas assignment | Not verified. Staff account and exact assignment destination absent from local instructions. |

## Grading cross-check

| Checker row | Points | Principal evidence |
|---|---:|---|
| Nothing merged | 8 | main versus root commit; split files only on tagged branch |
| Prediction first | 6 | one main prediction commit before first real M task run |
| Return contract | 10 | schema validation and actual tool-derived calls/searched |
| Deadlock caught | 8 | early cycle, valid victim, no acyclic false positive |
| Lost update refused | 8 | CAS rejects stale version and accepts reread |
| Combined result | 8 | wrong/right planted states |
| One trace | 6 | agents/parents and complete token accounting |
| Budget | 10 | S/M ceilings, S-plus matching and actual spend, 72 runs |
| Constants recorded | 6 | identical run constants and exact JSON report match |
| Results recompute | 10 | rows/report recompute from tracker and traces |
| Read and decided | 20 | full report and reasoned topology decision, read by staff |

## Safe continuation order

1. Use an execution environment with authorized Git metadata writes and network
   access. Resolve the original Windows test cleanup issue without silently
   changing protected tests/harness (for example, verify in a supported Linux
   environment). Obtain the independent handout and compare this checklist.
2. Run the original tests and real `python -m harness.ping` successfully.
3. On main, stage **only** `reports/PREDICTIONS_06.md`, commit and push it. Record
   its real commit ID; do not invent or backdate it. Commit setup and Part A separately.
4. Create lab-06-split; implement B and C; run free validation and development checks.
5. Run the fixed S and M sweeps, then matched S-plus; aggregate all 72 real runs.
6. Complete failure analysis and decision; tag/push split; transfer evidence only
   to main; run the official checker; commit/tag/push main and verify submission.

No assignment implementation, measured result, final decision, Git commit, tag,
or successful push is claimed by this audit.
