# Assignment 6 topology decision

**One issue: keep the single-agent topology.** On the fixed six-issue set over three sweeps, S passed 18/18, M passed 10/18, and S-plus passed 4/18. M used fewer tokens than S (19,339 vs 31,929) but took longer on average (11.8 vs 8.8 seconds). The S-plus control averaged 19,837 tokens and did not recover M's score. The split's extra orchestration did not improve single-issue outcomes.

**Five-issue batch: keep the single-agent topology for now.** S passed 2/6 batches; M and S-plus passed 0/6. M reduced average wall time from 44.9 to 36.5 seconds, an 18.7% improvement, below the preregistered 25% threshold. M/S token use was 0.354, not a spend multiplier, and no batch passed. S-plus also did not match M's actual spend on batch-b (0.481x), so that comparison is not evidence of equal-budget performance.

This is a small fixed benchmark, not a universal result. Reopen the batch decision only if a held-out repeat shows at least 25% lower wall time, no worse all-five accuracy than S, and an M/S token multiplier no greater than 1.5. Keep the single agent for individual issues unless a separate replicated result overturns the accuracy gap.

Evidence: `reports/LAB_06.md`, Part C; 72 finished measured runs recorded under `runs/`, with grounded rows in `results/runs_06.jsonl`. The official working-tree checker recomputes all three arms. The split implementation remains isolated on `lab-06-split`.
