# odintest

An early-phase **retro FPS/RPG engine** written in [Odin](https://odin-lang.org/) on top of [raylib](https://www.raylib.com/). Built as a learning project — systems-first: custom UI, an in-game console, and netcode before the game itself.

> ⚠️ Early phase / work-in-progress. Expect breaking changes and rough edges.

## Systems

- **Custom UI toolkit** (`ui/`) — buttons, checkboxes, sliders, text fields, text areas, labels, and draggable/scalable windows, drawn from a hand-made raygui-style texture atlas (`assets/ui/`).
- **In-game console** (`console/`) — Quake-style cvar system (`cvar`, `logging`) with config-file parsing (`config.cfg`), exposed through the UI.
- **Networking** (`networking/`) — client/server architecture with packet framing, message serialization (`messageinput` / `messageoutput`), and connection lifecycle handling.
- **Entity system** (`engine/entity.odin`) — base entity model for the FPS/RPG layer.
- **Texture cache** (`fileio/texturecache.odin`) — deduplicated GPU texture loading.
- **Crash handling** — vendored [`back`](back/) stack-trace library with PDB symbol support for readable crash output.

## Stack

| Layer | Tech |
| --- | --- |
| Language | **Odin** |
| Graphics/windowing | raylib |
| UI assets | raygui-style atlas, custom fonts (Sangyo, Bodycare) |

## Getting started

Requires the [Odin compiler](https://odin-lang.org/docs/overview/) and raylib.

```bash
odin build . -o:speed
# or run directly:
odin run . -o:speed
```

Windows development builds (`odintest.exe` + `raylib.dll` / `raygui.dll`) are checked in; on Linux/macOS you'll need raylib installed (e.g. `brew install raylib` or from your distro's packages).

## Layout

```
test.odin           main entry
initialize.odin     engine startup
close.odin          shutdown
config.cfg          runtime cvar config
console/            cvars, logging, config parsing
defs/               constants & variables
engine/             entity system
fileio/             texture cache
networking/         client, server, packets, messages
ui/                 UI widgets & windows
assets/             UI atlas, fonts, asset converter
back/               vendored stack-trace library
```
