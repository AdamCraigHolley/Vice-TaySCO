# Measurements

Build 672cf831 (`cargo build --profile diag -p victory --features diagnostics`), 2026-11-26,
on the test PC the README describes. Each session: `scripts\play.ps1` with the
RTX 4090 settings, full screen, past the start screen into the prologue, then
every minute a capture, the camera turned, a walk, and a route (run, turn,
look around, step aside) with another capture.

Frame columns are medians over the world lines (once a second, over 1,000
draws a frame). Memory and card columns are samples every 20 s over the whole
session, loading included.

| Profile | world lines | fps median | p10 | p90 | 1% low | ms/frame | preparing | copies ms / MB | textures ms / MB | GPU ms | copying back ms / MB | draws | dropped draws | captures |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Series X | 123 | 14.3 | 13.6 | 14.7 | 3.5 | 69.7 | 24.3 | 10.8 / 90.0 | 0.4 / 21.5 | 35.0 | 20.0 / 39.0 | 4893.0 | 334.0 | 46 |

| Profile | samples | game memory median / max (GB) | working set max (GB) | card memory max (GB) | card load median (%) | power median (W) | temperature max (C) | clock median (MHz) | CPU seconds per minute |
|---|---|---|---|---|---|---|---|---|---|
| Series X | 39 | 29.3 / 30.6 | 30.5 | 13.6 | 90.0 | 152.9 | 57.0 | 2745.0 | 543 |

CPU seconds per minute: the game's CPU time over all its threads; 60 is one core busy all the time.
