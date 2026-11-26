# Compare the two refresh schedulers from an isolated checkout on Windows x64.
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Exe,
    [ValidateRange(20, 600)][int]$Seconds = 60,
    [switch]$Reverse
)
$ErrorActionPreference = 'Stop'
if ([IntPtr]::Size -ne 8) { throw 'Use 64-bit PowerShell.' }
$game = (Resolve-Path -LiteralPath $Exe).Path
$repo = Split-Path $PSScriptRoot
$report = Join-Path $repo ('target\refresh-comparison-' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff'))
$tree = Join-Path (Split-Path $repo) ('vice-refresh-' + [guid]::NewGuid())
$null = New-Item $report -ItemType Directory -Force
$revisions = @('6bd66f28f868cc3efaff06d7c5c9006c17c16ca5', '4020b184043998748bc7bf11c2238c522bbea882')
if ($Reverse) { [array]::Reverse($revisions) }

# SystemProcessInformation, Windows x64. Read only the fixed record prefix:
# NextEntryOffset, HardFaultCount and UniqueProcessId (ntdoc.m417z.com/system_process_information).
if (-not ('ViceRefreshFaults' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class ViceRefreshFaults {
    [DllImport("ntdll.dll")]
    static extern int NtQuerySystemInformation(int kind, IntPtr data, int size, out int used);
    public static long Read(int pid) {
        int size = 1024 * 1024;
        while (size <= 128 * 1024 * 1024) {
            IntPtr data = Marshal.AllocHGlobal(size);
            try {
                int used;
                int status = NtQuerySystemInformation(5, data, size, out used);
                if (status == unchecked((int)0xC0000004)) {
                    size = Math.Max(size * 2, used);
                    continue;
                }
                if (status != 0) throw new InvalidOperationException("Process query failed: " + status);
                for (int at = 0; at <= Math.Min(size, used) - 88;) {
                    if (Marshal.ReadInt64(data, at + 80) == pid)
                        return (uint)Marshal.ReadInt32(data, at + 16);
                    int next = Marshal.ReadInt32(data, at);
                    if (next < 88 || next > used - at) break;
                    at += next;
                }
                return -1;
            } finally { Marshal.FreeHGlobal(data); }
        }
        throw new InvalidOperationException("Process query exceeded size limit.");
    }
}
'@
}
function Median($values) {
    $sorted = @($values | Sort-Object)
    if ($sorted.Count -eq 0) { return $null }
    $mid = [int][math]::Floor($sorted.Count / 2)
    if ($sorted.Count % 2) { return $sorted[$mid] }
    return ($sorted[$mid - 1] + $sorted[$mid]) / 2
}

git -C $repo worktree add --detach $tree $revisions[0]
if ($LASTEXITCODE) { throw 'Could not create the benchmark checkout.' }
$summary = @()
$launcher = $null
try {
    $cfg = Join-Path $repo 'victory.toml'
    if (Test-Path -LiteralPath $cfg) { Copy-Item -LiteralPath $cfg -Destination $tree }
    foreach ($revision in $revisions) {
        $tag = $revision.Substring(0,7)
        git -C $tree switch --detach $revision
        if ($LASTEXITCODE) { throw "Checkout failed for $tag." }
        Push-Location $tree
        try {
            cargo build --target-dir target --locked --profile diag -p victory --features diagnostics
            if ($LASTEXITCODE) { throw "Build failed for $tag." }
        } finally { Pop-Location }
        $prefix = Join-Path $report $tag
        $quotedGame = "'" + $game.Replace("'", "''") + "'"
        $command = "& .\scripts\play.ps1 -Exe $quotedGame -Safe -Console series-s -Windowed -More @{VICTORY_WINDOW_KB='1024'}; exit `$LASTEXITCODE"
        $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))
        $launcher = Start-Process powershell.exe -WorkingDirectory $tree -ArgumentList '-NoProfile','-EncodedCommand',$encoded -PassThru -RedirectStandardOutput "$prefix.stdout.log" -RedirectStandardError "$prefix.stderr.log"
        Read-Host "Load the same save and camera position for $tag. After the same warm-up, press Enter here" | Out-Null
        $enginePath = Join-Path $tree 'target\diag\victory.exe'
        $engine = Get-Process -Name victory -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $enginePath } | Select-Object -First 1
        if (!$engine) { throw "Could not find the benchmark process. See $prefix.stderr.log" }
        $start = [datetime]::UtcNow
        $clock = [Diagnostics.Stopwatch]::StartNew()
        $previous = [ViceRefreshFaults]::Read($engine.Id)
        $previousTime = $clock.Elapsed.TotalSeconds
        $samples = @()
        while ($clock.Elapsed.TotalSeconds -lt $Seconds) {
            Start-Sleep -Seconds 1
            $faults = [ViceRefreshFaults]::Read($engine.Id)
            if ($faults -lt 0 -or $engine.HasExited) { break }
            $elapsed = $clock.Elapsed.TotalSeconds
            $engine.Refresh()
            $samples += [pscustomobject]@{
                Utc = [datetime]::UtcNow.ToString('o')
                HardFaultsPerSec = [math]::Round(($faults - $previous) / ($elapsed - $previousTime), 2)
                PrivateMiB = [math]::Round($engine.PrivateMemorySize64 / 1MB)
                WorkingSetMiB = [math]::Round($engine.WorkingSet64 / 1MB)
            }
            $previous = $faults
            $previousTime = $elapsed
        }
        $clock.Stop()
        $end = [datetime]::UtcNow
        $samples | Export-Csv "$prefix.memory.csv" -NoTypeInformation
        Write-Host "Capture finished for $tag. Close the game window normally to continue."
        $launcher.WaitForExit()
        $frames = @()
        $refresh = @()
        foreach ($file in "$prefix.stderr.log","$prefix.stdout.log") {
            foreach ($line in [IO.File]::ReadLines($file)) {
                if ($line -notmatch '^(\S+Z).*?(?:fps, ([\d.]+) ms/frame|in the lists.+?refreshes ([\d.]+) in \d+ flushes)') { continue }
                $utc = [datetimeoffset]::Parse($Matches[1]).UtcDateTime
                # Discard the first reporting interval, which can straddle Enter.
                if ($utc -lt $start.AddSeconds(7) -or $utc -gt $end) { continue }
                if ($Matches[2]) { $frames += [double]$Matches[2] }
                else { $refresh += [double]$Matches[3] }
            }
        }
        $summary += [pscustomobject]@{
            Revision = $revision
            StartUtc = $start.ToString('o')
            EndUtc = $end.ToString('o')
            CompletedWindow = ($clock.Elapsed.TotalSeconds -ge $Seconds)
            FrameReports = $frames.Count
            MedianFrameMs = Median $frames
            MedianRefreshMs = Median $refresh
            MedianHardFaultsPerSec = Median $samples.HardFaultsPerSec
            ExitCode = $launcher.ExitCode
        }
        $summary | Export-Csv (Join-Path $report 'summary.csv') -NoTypeInformation
    }
} finally {
    Write-Host "Results: $report"
    if (!$launcher -or $launcher.HasExited) {
        git -C $repo worktree remove --force $tree
    } else {
        Write-Host "Game still open. Temporary checkout retained at $tree"
    }
}
$summary | Format-Table Revision,MedianFrameMs,MedianRefreshMs,MedianHardFaultsPerSec -AutoSize
