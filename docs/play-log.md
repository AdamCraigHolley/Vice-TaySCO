# Play log: Series S, played by hand

Build 672cf831 (diag), the test PC in the README, `scripts\play.ps1 -Console series-s`
with the RTX 4090 settings, full screen, the whole session recorded to video on the
card's encoder. Played by hand through the scripted pad (`VICTORY_KEYS_FILE`), looking
at the screen before each move. This log grows as the session goes on; the full numbers
land in [measurements.md](measurements.md) when it ends.

Loading: 88 s to the start screen, 126 s into the world.

## Minute by minute

Frame columns are the medians of the game's once-a-second frame lines in that minute
(over 1,000 draws a frame). Times are UTC.

| UTC | Where and what | fps | preparing ms | copying back ms | draws |
|---|---|---|---|---|---|
| 09:11 | Opening scene, then the dormitory | 17.0 | 49.2 | 17.0 | 2,986 |
| 09:12 | Dormitory, camera turned around | 20.7 | 37.5 | 16.4 | 4,561 |
| 09:13 | Walking to a cellmate, as the objective asks | 21.5 | 36.0 | 14.5 | 3,391 |
| 09:14 | The door opens, a guard comes in | 18.5 | 37.7 | 16.0 | 5,138 |
| 09:15 | Out of the dormitory, down the corridor behind the guard | 19.9 | 38.0 | 18.7 | 3,904 |
| 09:16 | Through a gate into a common room with other inmates | 24.5 | 31.2 | 13.6 | 2,288 |
| 09:17 | Waiting at a closed gate for the guard | 22.6 | 34.2 | 13.9 | 2,799 |
| 09:18 | Another corridor, into an office: a scene starts | 20.9 | 38.2 | 17.0 | 2,034 |
| 09:19 | A flashback starts, out in the city | 19.4 | 40.8 | 14.4 | 3,953 |
| 09:20 | Flashback, playable: aiming with the left trigger | 16.5 | 47.0 | 15.8 | 6,213 |
| 09:21 | Aiming with the right stick, threatening with X | 18.7 | 41.6 | 14.8 | 4,369 |
| 09:22 | Holding the aim while the scene plays | 19.3 | 39.8 | 14.3 | 4,364 |
| 09:23 | Running out to the street, jumping, sprinting | 13.4 | 54.6 | 11.4 | 9,267 |
| 09:24 | On a roof over the open city, wanted by the police | 12.3 | 48.5 | 16.9 | 4,216 |
| 09:25 | A scene in a car, then back in the office | 24.3 | 32.3 | 12.8 | 1,406 |

When the open city first came into view (09:23:49) one second ran at 5.0 fps
(200 ms a frame).

During those minutes: about 32-33 GB of private memory for the game, 15.3 GB of card
memory, 112-127 W and 45-46 C on the card.

## What worked

- Every pad input tried answers: both sticks, the left trigger held, X, A to jump or
  climb, the left stick click to run. X needs short taps; one long press was missed.
- The story moves from one checkpoint to the next without help: dormitory, corridor,
  gates, office, flashback, escape, the open city, and back.
- No crash, no hang.

## Picture defects seen

- A flat red patch behind a character standing in a doorway.
- In the flashback, clothes and people in the background turn a flat, blown-out white with
  coloured fringes, and the street and sky blow out. The flashback has a sepia grade of its
  own, but the flat white and the fringes look like the overexposure defect.
- Eyes lit white in a close-up.
- Skin and hair in flat bands of colour.
- Full-white frames between scenes are the game's own transitions: the next frame is right.

## Part 2: the boat (09:26 to 09:38 UTC)

| UTC | Where and what | fps | lowest second | preparing ms | copying back ms | draws |
|---|---|---|---|---|---|---|
| 09:26 | Office scene, then a cut to a scene on a boat | 12.7 | 3.5 | 41.4 | 13.4 | 2,740 |
| 09:27 | Driving the boat on open water, minimap on screen | 18.6 | 10.5 | 37.8 | 14.2 | 3,092 |
| 09:28 | Full throttle past other boats, a long bridge, a plane overhead | 18.2 | 14.6 | 38.9 | 15.1 | 3,736 |
| 09:29 | Off course round an island; back to a checkpoint with a new objective | 19.1 | 13.0 | 38.3 | 12.2 | 3,554 |
| 09:30 | Ran into mangroves: mission failed, the boat wrecked | 18.2 | 10.5 | 40.2 | 12.3 | 3,782 |
| 09:31 | Retried from the checkpoint, round the island | 17.1 | 10.1 | 40.5 | 12.8 | 4,346 |
| 09:32 | Mangroves again, failed; skipped the checkpoint | 18.4 | 13.6 | 39.5 | 12.1 | 3,766 |
| 09:33 | New objective with a GPS route on the minimap | 18.2 | 15.0 | 39.0 | 11.8 | 3,870 |
| 09:34 | Under an iron bridge, into the bushes | 18.9 | 16.9 | 38.0 | 11.6 | 4,348 |
| 09:35 | Failed, skipped the checkpoint | 17.2 | 3.6 | 41.6 | 13.2 | 4,694 |
| 09:36 | Short, careful legs: iron bridge, a canal | 16.5 | 9.7 | 42.0 | 13.4 | 5,007 |
| 09:37 | Past a ruined bridge onto a lake | 17.1 | 12.9 | 41.6 | 14.1 | 4,562 |
| 09:38 | Reached the objective, a scene starts | 16.4 | 14.8 | 42.1 | 14.3 | 4,658 |

Game memory rose to 35-36 GB on open water (from 33 GB in the prison); card memory
17.7-18.5 GB; 112-132 W and 43-46 C on the card.

What this part showed:

- Driving answers to the triggers and the left stick; the minimap, the GPS route and the
  distance to the objective update as it moves.
- The fail screen works, and so do its three choices (retry, skip the checkpoint,
  restart the mission); with no choice it retries by itself.
- Two failures were the driver's: steering in one- and two-second steps at 15-19 fps is
  coarse. Three- to five-second legs with a look between them got there.

More picture defects:

- Light-blue flat rectangles and square blocks in the clouds, coming and going with the
  camera.
- Flat purple patches in tree tops.
- The reflection on the boat's dark hull in square blocks.
- One-second drops to 3.5 and 3.6 fps when a new area loads (the cut to the boat scene,
  skipping a checkpoint).

## Still to check

- The log's "on the GPU" figure reads 0-2 ms on the Series S profile, against 33-36 ms on
  Series X. It is left out above until it is clear what it measures there.
