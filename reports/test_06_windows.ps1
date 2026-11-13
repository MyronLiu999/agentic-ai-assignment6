# Runs the unchanged course suite with UTF-8 and explicit garbage collection
# immediately before TemporaryDirectory cleanup on Windows. This only changes
# cleanup timing; no test is replaced, skipped or made to ignore an exception.
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$pythonPath = Join-Path $projectRoot '.venv\Scripts\python.exe'
if (-not (Test-Path -LiteralPath $pythonPath -PathType Leaf)) {
    throw 'Create the project .venv and install requirements first.'
}
Push-Location -LiteralPath $projectRoot
try {
    @'
import gc
import os
import sys
import unittest

# In the original resume test, mocked _run_way retains its call arguments,
# including TraceWriter instances, in a reference cycle. The actual _run_way
# normally closes them. Windows cannot unlink their files until collection.
def collect_before_cleanup(frame, event, arg):
    if (event == "call" and frame.f_code.co_name == "cleanup"
            and frame.f_globals.get("__name__") == "tempfile"):
        gc.collect()

print("Original course suite; UTF-8 enabled; GC before Windows temp cleanup.", flush=True)
previous_profile = sys.getprofile()
if os.name == "nt":
    sys.setprofile(collect_before_cleanup)
try:
    suite = unittest.defaultTestLoader.discover("tests", top_level_dir=".")
    result = unittest.TextTestRunner(verbosity=1).run(suite)
finally:
    sys.setprofile(previous_profile)
raise SystemExit(not result.wasSuccessful())
'@ | & $pythonPath -X utf8 -
    $testExit = $LASTEXITCODE
    if ($testExit -ne 0) {
        throw "The original suite failed (exit $testExit)."
    }
}
finally {
    Pop-Location
}
