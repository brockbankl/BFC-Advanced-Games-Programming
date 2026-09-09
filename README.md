# BFC Advanced Games Programming

This repository contains the two practical strands for Advanced Games Programming (AGP).

The module begins by examining the current games market: how audiences are split across PC, console, mobile, and other platforms, and how the meaning of "market share" changes when we measure revenue, active users, hardware sales, or play time. That evidence leads into the technical and commercial case for reaching more than one platform. Assessment 1 then uses MonoGame, a cross-platform games framework, to investigate how that affects rendering, effects, performance, and optimisation.

## Repository structure

| Folder | Status | Purpose |
| --- | --- | --- |
| [`Assessment-1-MonoGame`](Assessment-1-MonoGame/) | **Current** | Cross-platform 3D MonoGame work: HLSL shaders, particles, rendering, profiling, and optimisation. |
| [`Assessment-2-Tank-Arena`](Assessment-2-Tank-Arena/) | **Teaching baseline** | Browser-based, server-authoritative multiplayer Tank Arena: Node.js, WebSockets, Canvas and ephemeral rooms. |

## Start here: Assessment 1

During the first part of the module, work only in [`Assessment-1-MonoGame`](Assessment-1-MonoGame/).

1. Read its [setup guide](Assessment-1-MonoGame/README.md) completely.
2. Open the `Assessment-1-MonoGame` folder directly in Visual Studio Code.
3. Run the Assessment 1 setup and WindowsDX build check before the first practical.
4. Follow the version-control and submission instructions given in class.

After the classroom tour, use [Official MonoGame and 3D Platformer Resources](Assessment-1-MonoGame/docs/OFFICIAL_MONOGAME_RESOURCES.md) for the original project, official development livestreams, focused tutorials, and reference documentation.

The MonoGame project is a pinned and tested course snapshot of the official [MonoGame Starter Kit 3D Platformer](https://github.com/MonoGame/Starter-Kit-3D-Platformer). It will not move automatically when the upstream project changes.

## Assessment 2: multiplayer Tank Arena

Assessment 2 uses the [Tank Arena networking baseline](Assessment-2-Tank-Arena/). It is a small playable browser game supplied to support later work on client/server architecture, JSON protocols, server authority, validation, disconnections, latency and multiplayer identity.

Read the [Tank Arena setup and running guide](Assessment-2-Tank-Arena/README.md) before opening it. The project includes a student-safe setup script, server-side automated tests, local two-player instructions and a Render deployment walkthrough. It is starter material, not the eventual assessment brief: follow your lecturer's release and submission instructions.

Assessment 1 and Assessment 2 use different technology for different learning goals. Do not mix their setup routes or edit the Assessment 1 MonoGame implementation while working on Tank Arena.

## Licensing and provenance

The Assessment 1 starter project retains MonoGame and Kenney's upstream licensing information inside its folder. Course-specific instructions and the Assessment 2 teaching code are provided for students enrolled on the module.
