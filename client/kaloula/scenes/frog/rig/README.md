# Frog rig

`FrogRig` (`frog_rig.gd`) draws the frog in code (no textures) and animates it procedurally.
The frog faces up (−Y), like the `Frog` node. One hop is `hop_stride` rig units (150 by default);
in `game.tscn` the rig is scaled to 32/150 so a default hop covers one 32 px tile.

## Animations (`rig.animation`)
| Anim | Loop | Notes |
|---|---|---|
| `IDLE` | 4.0 s | breathe & blink (sitting pose) |
| `STRETCH` | 4.2 s | toe stretch, starts/ends sitting |
| `CATCH` | 4.8 s | catches a mosquito with its tongue, starts/ends sitting |
| `HOP` | 1.12 s | one hop forward, starts/ends sitting |
| `CRAWL` | 1.6 s | slow four-beat crawl, 36 units per loop |
| `BELLY_UP` | 3.2 s | on its back, struggling |
| `TURN` | 0.92 s per 90° | turn in place by a fixed angle: `rig.turn(degrees, then)` |

- `turn_by(angle)`: call it after rotating the frog's node yourself (`Frog.turn()` does). Planted
  feet stay put on the ground and step around to follow.
- `idle_fidgets`: while sitting, the frog now and then plays `STRETCH` or `CATCH` once
  (every `fidget_after` seconds, random).
- Hopping: set `hop_stride` (rig units) to the distance to the target, play `HOP`, move the node by
  `get_travel()` (or `travel_delta`) so planted feet stay still; `cycle_finished(HOP)` fires on landing.
- Switching between the standing animations blends the legs for `blend_time` (0.15 s).
  Belly up switches instantly.
- Set **Animation** in the Inspector to preview any loop in the editor.

## Colours
`Frog._ready()` builds the palette from the frog's `color` with `FrogPalette.from_color()`.
A `FrogPalette` resource can also be set on the rig directly (expand **Palette** in the Inspector);
the button at the bottom matches the eyelid, throat and belly-up colours to the skin.
`palettes/` has three examples (mint, tomato, poison dart).
