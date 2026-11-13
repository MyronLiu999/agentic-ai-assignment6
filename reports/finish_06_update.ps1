# Updates the two assignment branches/tags after the checked prompt-only refactor.
$ErrorActionPreference = 'Stop'
function Invoke-LabGit {
    & git @args
    if ($LASTEXITCODE -ne 0) { throw "Git failed; stop here and share the output." }
}
Set-Location -LiteralPath (Split-Path -Parent $PSScriptRoot)
if ((git branch --show-current) -ne 'main') { throw 'Start on main.' }
if ((git rev-parse HEAD) -ne '4831af2d089262e9379e2c218f3081a04edf1332') { throw 'Main has changed; have the update reviewed before running it again.' }
if ((git rev-parse lab-06-split) -ne 'dcf6812571be86998a761d904cdafb8062e0152b') { throw 'Split branch has changed; stop for review.' }
$staged = @(git diff --cached --name-only)
if ($staged.Count -ne 0) { throw 'The index already contains staged changes; stop for review.' }
$oldMainTag = (git rev-parse refs/tags/lab-06).Trim()
$oldSplitTag = (git rev-parse refs/tags/lab-06-split-final).Trim()
$remoteRefs = @(Invoke-LabGit ls-remote origin refs/tags/lab-06 refs/tags/lab-06-split-final)
if (-not ($remoteRefs -match "^$oldMainTag\s+refs/tags/lab-06$")) { throw 'Remote lab-06 differs from local; stop for review.' }
if (-not ($remoteRefs -match "^$oldSplitTag\s+refs/tags/lab-06-split-final$")) { throw 'Remote split tag differs from local; stop for review.' }

Invoke-LabGit add -- CHANGES.md reports/LAB_06.md reports/prompt-layout-06-validation.txt
Invoke-LabGit commit -m 'Clarify Assignment 6 report and change log'
Invoke-LabGit switch lab-06-split
Invoke-LabGit apply --check reports/prompt-layout-06.patch
Invoke-LabGit apply reports/prompt-layout-06.patch
Invoke-LabGit add -- ways/split.py prompts/investigator_task.md prompts/investigator_retry.md prompts/publisher_task.md
Invoke-LabGit commit -m 'Move split instructions into prompt templates'
Invoke-LabGit tag -f lab-06-split-final
Invoke-LabGit switch main

$output = @(& python checks/check_06.py 2>&1)
$code = $LASTEXITCODE
$output | ForEach-Object { Write-Host $_ }
$checkText = $output -join "`n"
if ($code -ne 0 -or $checkText -notmatch 'Automated:\s+80\s*/\s*80' -or $checkText -notmatch 'Integrity flags[^\r\n]*none') {
    throw 'Final check did not pass. Changes are local; no push has started.'
}
Invoke-LabGit tag -f lab-06
Invoke-LabGit push --atomic "--force-with-lease=refs/tags/lab-06-split-final:$oldSplitTag" origin refs/heads/lab-06-split refs/tags/lab-06-split-final
Invoke-LabGit push --atomic "--force-with-lease=refs/tags/lab-06:$oldMainTag" origin refs/heads/main refs/tags/lab-06
Invoke-LabGit ls-remote origin refs/heads/main refs/heads/lab-06-split refs/tags/lab-06 refs/tags/lab-06-split-final
Write-Host 'Assignment 6 documentation and prompt layout update pushed.'
