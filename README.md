# BFC Advanced Games Programming: MonoGame 3D Platformer

This is the stable course copy for our Level 6 advanced games programming work. It contains a tested snapshot of MonoGame's official 3D platformer starter kit, which we will use for graphics, particle, HLSL shader, and AI exercises.

The original starter kit belongs to the MonoGame project. Get it from:

**[MonoGame/Starter-Kit-3D-Platformer](https://github.com/MonoGame/Starter-Kit-3D-Platformer)**

Use this course repository for practical work so that later changes to MonoGame's upstream repository cannot break the teaching baseline. The steps below take you from a college PC with Visual Studio Code to a running copy.

## What you need

- A Windows college PC with Visual Studio Code.
- Access to Visual Studio Code's integrated terminal. You do **not** need access to the separate Windows Terminal, Command Prompt, or PowerShell applications.
- The **.NET 9 SDK** or a later supported SDK. The project currently targets `net9.0`.
- Git, if you use the recommended clone method. A ZIP download is available as a fallback.
- These Visual Studio Code extensions:
  - **C# Dev Kit** by Microsoft (`ms-dotnettools.csdevkit`). This also installs the base C# extension.
  - **HLSL Tools** by Tim Jones (`timgjones.hlsltools`).
  - **Blender Development** by Jacques Lucke (`jacqueslucke.blender-development`) is optional until we edit levels in Blender.

The **MonoGame for VS Code** community extension and the MonoGame project templates are useful when creating traditional MonoGame projects, but they are not required to build this starter kit. This kit uses MonoGame 3.8.5's newer Content Builder project.

## 1. Choose a folder with no spaces

This matters. At the upstream revision used for the course, the Content Builder command fails if any folder in the project path contains a space. Our pinned course copy includes a compatibility fix, but a short no-spaces path remains the supported college setup and avoids problems in other content tools.

Use a short location such as:

```text
C:\Users\your-college-login\BFCMonoGame\BFC-Advanced-Games-Programming
```

Avoid locations such as:

```text
OneDrive - College Name\Games Programming\Starter Kit
```

If your Windows user-profile folder itself contains a space, ask your lecturer which no-spaces college drive or folder to use before continuing.

## 2. Install the Visual Studio Code extensions

1. Open Visual Studio Code.
2. Select the **Extensions** icon on the left, or press `Ctrl+Shift+X`.
3. Search for **C# Dev Kit** and install the result published by Microsoft.
4. Search for **HLSL Tools** and install the result published by Tim Jones.
5. Reload Visual Studio Code if it asks you to do so.

When the starter kit is opened later, Visual Studio Code may also display a notification containing the repository's recommended extensions. It is fine to accept the C# and HLSL recommendations. Blender support is optional for now.

## 3. Check the .NET SDK

Open Visual Studio Code's integrated terminal using **Terminal > New Terminal** or ``Ctrl+` ``. Run:

```powershell
dotnet --list-sdks
```

You need to see a line beginning with `9.0` or a later compatible SDK such as `10.0`.

If `dotnet` is not recognised, or only .NET 8 and earlier are listed, stop and tell your lecturer or college IT. Installing Visual Studio Code's **.NET Install Tool** extension does not guarantee that the full SDK needed to build the game is installed.

## 4. Download the course copy

### Recommended: clone with Visual Studio Code

Cloning keeps the source's Git history and makes later updates easier.

1. Open a new Visual Studio Code window.
2. Press `Ctrl+Shift+P` to open the Command Palette.
3. run **Git: Clone**.
4. Paste:

   ```text
   https://github.com/brockbankl/BFC-Advanced-Games-Programming.git
   ```

5. Choose a no-spaces parent folder such as `C:\Users\your-college-login\BFCMonoGame`.
6. Select **Open** when cloning finishes.
7. If asked whether you trust the authors of the files, confirm that you trust the MonoGame repository.

If **Git: Clone** is unavailable or reports that Git is missing, use the ZIP method below or ask college IT to install Git.

### Fallback: download a ZIP in the browser

1. Open the [BFC course repository](https://github.com/brockbankl/BFC-Advanced-Games-Programming).
2. Select **Code**, then **Download ZIP**.
3. Extract the ZIP to a no-spaces location.
4. In Visual Studio Code, select **File > Open Folder** and open the extracted folder.

The correct folder contains `Platformer3D.slnx`, `Source`, `Content`, and `DesktopGL`. Do not open only `Source`, and do not open a parent folder above the starter kit.

The ZIP method runs the game, but it does not include Git history. Use the clone method when possible.

## 5. Restore and build for the first time

Open Visual Studio Code's integrated terminal in the starter-kit folder. Run these commands one at a time:

```powershell
dotnet restore Content/Content.csproj
dotnet restore DesktopGL/Platformer3D.csproj
dotnet build DesktopGL/Platformer3D.csproj
```

Why these exact commands?

- Restoring `Content` first avoids a fresh-checkout error about `Content\obj\project.assets.json`.
- Building only `DesktopGL` avoids attempting Android and iOS projects that require extra workloads not used in this module.
- The first build downloads NuGet packages and processes all game assets. It can take several minutes on a college network. Wait for `Build succeeded`.
- A warning beginning `NETSDK1206` may appear with newer SDKs. It is an upstream dependency warning and does not prevent this desktop build from succeeding.

Do not use an old instruction referring to `Starter-Kit-3D-Platformer.sln` or `Platforms/Desktop/Desktop.csproj`; those paths are not present in the current repository.

## 6. Run and debug in Visual Studio Code

1. Open **Run and Debug** using `Ctrl+Shift+D`.
2. Select **DesktopGL** from the configuration list at the top.
3. Press `F5`.

You can also run without the debugger from the integrated terminal:

```powershell
dotnet run --project DesktopGL/Platformer3D.csproj
```

Use DesktopGL for the module unless your lecturer asks for a different platform. The repository also contains WindowsDX, WindowsDX12, Vulkan, Android, and iOS targets, but they introduce extra machine-specific requirements.

## Basic controls

- `W`, `A`, `S`, `D`: move
- `Space`: jump/double-jump
- Arrow keys: rotate the camera
- Comma and full stop: zoom
- `F1`: collision meshes in debug builds
- `F2`: shadow and post-processing render targets
- `F3`: performance metrics
- `M`: mute/unmute
- `+` and `-`: change game-time speed in debug builds

## Before each practical

1. Open the starter-kit root folder in Visual Studio Code.
2. Check that **DesktopGL** is selected in Run and Debug.
3. Press `F5` and confirm that the unmodified game still runs.
4. Make the week's work in the copy or branch specified by your lecturer.
5. Commit regularly when Git is available. Do not edit the lecturer's master copy.

The main areas we will use are:

- `Source/`: C# game loop, scenes, entities, rendering, collision, and gameplay code.
- `Content/Assets/Effects/`: HLSL `.fx` shader source.
- `Content/Assets/`: models, textures, audio, fonts, and level data.
- `Content/Content.csproj` and `Content/BuildContent.targets`: the experimental code-based content pipeline.
- `DesktopGL/`: our normal desktop launch project.

## Common problems

### `'C:\part of the path' is not recognised as a command`

The project is in a folder containing spaces. Move or clone the entire repository to a no-spaces path, reopen that folder in Visual Studio Code, and build again.

### `project.assets.json not found` for the Content project

Run:

```powershell
dotnet restore Content/Content.csproj
dotnet restore DesktopGL/Platformer3D.csproj
```

Then press `F5` again.

### Android SDK, iOS workload, or API-level errors

You built the entire solution. This module uses the desktop target. Run:

```powershell
dotnet build DesktopGL/Platformer3D.csproj
```

### NuGet download or restore errors

Check that a web page opens, then retry the failed restore once. If it still fails, keep the full error visible and tell your lecturer; the college firewall, proxy, or NuGet cache may need support. Do not install packages from unofficial download sites.

### `dotnet` is missing or no compatible SDK is listed

The .NET SDK is a machine prerequisite. Report the PC number and the output of `dotnet --list-sdks` to your lecturer or college IT.

### C# has no IntelliSense or F5 configurations

Confirm that C# Dev Kit is installed, then reopen the folder containing `Platformer3D.slnx`. Give C# Dev Kit a moment to load the workspace.

### HLSL files are plain text

Confirm that HLSL Tools by Tim Jones is enabled for this workspace, then reopen the `.fx` file.

## Version used to prepare this module

This repository includes the teaching baseline checked against upstream commit [`985b84f1154714fb68eb295579cbd10ec16694c6`](https://github.com/MonoGame/Starter-Kit-3D-Platformer/commit/985b84f1154714fb68eb295579cbd10ec16694c6), retrieved on 1 August 2026. Upstream `main` can continue changing without altering this cohort's copy.

For background, see MonoGame's official [Visual Studio Code setup guide](https://docs.monogame.net/articles/getting_started/2_choosing_your_ide_vscode.html) and [Content Builder documentation](https://docs.monogame.net/articles/getting_started/content_pipeline/content_builder_project.html).

## Credits and licence

The starter kit is maintained by the MonoGame project, based on Kenney's original Godot starter kit. Its source is MIT licensed, and its included 2D sprites, 3D models, and sound effects are CC0 licensed. This course repository preserves the upstream [`LICENSE.md`](LICENSE.md); the [official repository](https://github.com/MonoGame/Starter-Kit-3D-Platformer) remains the source of the original project.

This public repository contains only the pinned starter kit and student-safe course material. Lecturer solutions and in-development resources are kept in a separate private repository.

Teaching staff should use [the local teacher workflow](docs/TEACHER_WORKFLOW.md) before creating lesson or solution copies.
