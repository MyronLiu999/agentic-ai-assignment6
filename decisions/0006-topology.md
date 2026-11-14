# Assignment 6 topology decision

Keep the single agent for both task sizes, with accuracy taking priority over
token cost in this decision.

For one issue, S passed 18/18, compared with M's 10/18 and S-plus's 4/18. S used
more tokens than M (31,929 versus 19,339 per run) but finished sooner on average
(8.8 versus 11.8 seconds). M did better than S-plus at similar actual spend;
that makes it a possible option under a tighter token budget, but it does not
meet S's observed accuracy.

For five-issue batches, S passed 2/6 and both alternatives passed 0/6. M used
35.4% of S's tokens and reduced mean wall time from 44.9 to 36.5 seconds, an
18.7% improvement. That falls short of the predicted 25% latency target. S is
the best of these measured options, but 2/6 is still too weak to call reliable.

The controls limit what this comparison establishes. S-plus used a different,
shorter prompt than S and spent substantially less than M on batch-b. Thus the
results compare these implementations; they do not isolate the effect of
splitting agents or of changing the budget. The S-plus/M batch tie at zero
passes is not evidence that either handles batches adequately.

Revisit the batch split on a larger held-out set if it matches or exceeds S's
all-five accuracy, reduces mean wall time by at least 25%, and uses no more than
1.5 times S's tokens. A follow-up should preserve equivalent task guidance
across arms and check actual spend as well as the configured budget.

Evidence: the 72 measured rows in `results/runs_06.jsonl`, backed by `runs/` and
`tracker/`; the full comparison and failure analysis are in `reports/LAB_06.md`.
The split implementation remains on `lab-06-split`, outside main.
