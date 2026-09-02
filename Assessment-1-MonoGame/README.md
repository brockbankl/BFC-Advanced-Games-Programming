# BFC Advanced Games Programming: MonoGame 3D Platformer

This is the stable course copy for our Level 6 advanced games programming work. It contains a tested snapshot of MonoGame's official 3D platformer starter kit, which we will use for graphics, particle, HLSL shader, and AI exercises.

The original starter kit belongs to the MonoGame project. Get it from:

**[MonoGame/Starter-Kit-3D-Platformer](https://github.com/MonoGame/Starter-Kit-3D-Platformer)**

Use this course repository for practical work so that later changes to MonoGame's upstream repository cannot break the teaching baseline. The steps below take you from a college PC with Visual Studio Code to a running copy.

For a guided route through the official project materials, videos, MonoGame concepts, content workflow, and 3D graphics documentation, see [Official MonoGame and 3D Platformer Resources](docs/OFFICIAL_MONOGAME_RESOURCES.md).

## What you need

- A college Windows PC or a personal Windows, macOS, or Linux computer with Visual Studio Code.
- Access to Visual Studio Code's integrated terminal. You do **not** need access to the separate Windows Terminal, Command Prompt, or PowerShell applications.
- The **.NET 10 SDK**. The project targets `net10.0` and the recommended setup command can install it for the current Windows user when college policy allows.
- Git, if you use the recommended clone method. A ZIP download is available as a fallback.
- These Visual Studio Code extensions:
  - **C# Dev Kit** by Microsoft (`ms-dotnettools.csdevkit`). This also installs the base C# extension.
  - **HLSL Tools** by Tim Jones (`timgjones.hlsltools`).

The **MonoGame for VS Code** community extension and the MonoGame project templates are useful when creating traditional MonoGame projects, but they are not required to build this starter kit. This kit uses MonoGame 3.8.5's newer Content Builder project. On a personal macOS or Linux computer, you will launch the `DesktopGL` project rather than the Windows-only `WindowsDX` project.

## Quick setup (recommended)

After cloning or extracting the course copy, open the `Assessment-1-MonoGame` folder directly in Visual Studio Code. Open its integrated terminal and run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Setup-Assessment1.ps1
```

The script identifies the correct project folder, selects `WindowsDX` on Windows or `DesktopGL` on macOS/Linux, checks for a .NET 10 SDK, installs it for the current Windows user from Microsoft's official installer when needed, checks the two recommended VS Code extensions, restores dependencies, and builds the selected desktop project. It does not require administrator rights and is safe to run again after an interruption.

The command uses PowerShell's process-only execution-policy override; it does not change your machine settings. The included script is also directly available as `Setup-Assessment1.ps1`. If you prefer a double-clickable route on Windows, run:

```text
Setup-Assessment1.cmd
```

Alternatively, choose **Terminal > Run Task** and select **BFC: Setup Assessment 1**. The setup only reports completion after its build succeeds. On Windows, launch the game afterwards with:

```powershell
dotnet run --project ./WindowsDX/Platformer3D.csproj
```

On macOS or Linux, use `dotnet run --project ./DesktopGL/Platformer3D.csproj`. The manual route below remains useful when diagnosing a specific problem.

## 1. Use `Documents\projects` on a college PC

> **College PC requirement**
>
> Clone or extract the project inside a folder named `projects` in your Windows `Documents` folder. The college debugger may refuse to run game files stored elsewhere, even when the project builds successfully.

Use this parent folder:

```text
C:\Users\your-college-login\Documents\projects
```

The completed repository path should look like:

```text
C:\Users\your-college-login\Documents\projects\BFC-Advanced-Games-Programming
```

Create the `projects` folder in File Explorer before cloning or extracting the download if it does not already exist. Do not use Desktop, Downloads, a USB drive, OneDrive, or another convenient-looking folder on a college PC. This is a college restriction, not a MonoGame one. I do not know why either, but the debugger will not negotiate with us.

The path also avoids spaces, which helps the starter kit's content tools. If your Windows `Documents` folder is redirected or you cannot create `Documents\projects`, stop and ask your lecturer before continuing.

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

You need to see a line beginning with `10.0`.

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

5. Choose `C:\Users\your-college-login\Documents\projects` as the parent folder.
6. Select **Open** when cloning finishes.
7. In the new repository window, select **File > Open Folder** and open `Assessment-1-MonoGame`.
8. If asked whether you trust the authors of the files, confirm that you trust the course repository and its credited MonoGame source.

If **Git: Clone** is unavailable or reports that Git is missing, use the ZIP method below or ask college IT to install Git.

### Fallback: download a ZIP in the browser

1. Open the [BFC course repository](https://github.com/brockbankl/BFC-Advanced-Games-Programming).
2. Select **Code**, then **Download ZIP**.
3. Extract the ZIP inside `C:\Users\your-college-login\Documents\projects`.
4. In Visual Studio Code, select **File > Open Folder** and open the extracted `Assessment-1-MonoGame` folder.

The correct Assessment 1 folder contains `Platformer3D.slnx`, `Source`, `Content`, `WindowsDX`, and `DesktopGL`. Do not open only `Source`, and do not leave the module repository root open when you are trying to use the F5 configurations.

The ZIP method runs the game, but it does not include Git history. Use the clone method when possible.

## 5. Manual restore and build for the first time

Open the `Assessment-1-MonoGame` folder in Visual Studio Code, then open its integrated terminal using **Terminal > New Terminal** or ``Ctrl+` ``. The terminal prompt should end in `Assessment-1-MonoGame`.

You can check the current folder with:

```powershell
Get-Location
```

If you opened the whole module repository instead, move into the correct folder with:

```powershell
Set-Location ./Assessment-1-MonoGame
```

### College PCs and personal Windows PCs

Run these commands one at a time:

```powershell
dotnet restore ./Content/Content.csproj
dotnet restore ./WindowsDX/Platformer3D.csproj
dotnet build ./WindowsDX/Platformer3D.csproj
```

### Personal macOS or Linux computers

Use the cross-platform DesktopGL launcher instead:

```bash
dotnet restore ./Content/Content.csproj
dotnet restore ./DesktopGL/Platformer3D.csproj
dotnet build ./DesktopGL/Platformer3D.csproj
```

Why these exact commands?

- Restoring `Content` first avoids a fresh-checkout error about `Content/obj/project.assets.json`.
- `WindowsDX` is the recommended launcher on the college's Windows PCs and on personal Windows computers.
- `DesktopGL` uses the same shared game and content code with a desktop OpenGL platform layer, making it the normal choice on macOS and Linux.
- Building one desktop project avoids Android and iOS workloads that are not used in this module.
- The first build downloads NuGet packages and processes the game assets. It can take several minutes on a college network, so allow it to finish and look for `Build succeeded`.
- Warnings beginning `NETSDK1206` or `WFO0003` come from the starter kit's current dependencies and Windows settings; they do not prevent a successful desktop build.

Do not use an old instruction referring to `Starter-Kit-3D-Platformer.sln` or `Platforms/Desktop/Desktop.csproj`; those paths are not present in this repository.

## 6. Run the game from Visual Studio Code

### Reliable method: use the integrated terminal

On a college PC or personal Windows PC, run this from inside `Assessment-1-MonoGame`:

```powershell
dotnet run --project ./WindowsDX/Platformer3D.csproj
```

On macOS or Linux, run:

```bash
dotnet run --project ./DesktopGL/Platformer3D.csproj
```

`dotnet run` rebuilds changed code and content before launching the game. Keep the terminal open while playing, and press `Ctrl+C` in that terminal to stop the program if closing the game window does not return control.

If your terminal is at the module repository root rather than inside `Assessment-1-MonoGame`, the Windows command is:

```powershell
dotnet run --project ./Assessment-1-MonoGame/WindowsDX/Platformer3D.csproj
```

Check `Get-Location` whenever you have several copies or branches of the project. A correct-looking relative command can still launch the wrong copy if the terminal is in the wrong folder. It is quite easy to test the wrong copy without noticing.

### Optional method: F5

On a personal computer, or if the college configuration permits it:

1. Open the `Assessment-1-MonoGame` folder rather than just an individual `.cs` file.
2. Open **Run and Debug** using `Ctrl+Shift+D`.
3. Select **WindowsDX** on Windows or **DesktopGL** on macOS/Linux.
4. Press `F5`.

Opening a C# file and selecting a small **Run** button is not reliable for this multi-project game. Some college PCs may also hide or block the F5/debug route entirely. Use the integrated-terminal command above. It builds the same project, so you are not missing anything.

### Useful commands at a glance

Run these from `Assessment-1-MonoGame`, replacing `WindowsDX` with `DesktopGL` on macOS/Linux:

| Task | Command |
| --- | --- |
| Show installed SDKs | `dotnet --list-sdks` |
| Restore shared content dependencies | `dotnet restore ./Content/Content.csproj` |
| Build without launching | `dotnet build ./WindowsDX/Platformer3D.csproj` |
| Build and run | `dotnet run --project ./WindowsDX/Platformer3D.csproj` |
| Remove generated build output | `dotnet clean ./WindowsDX/Platformer3D.csproj` |
| Stop a game launched in the terminal | `Ctrl+C` |

## Basic controls

- `W`, `A`, `S`, `D`: move
- `Space`: jump/double-jump
- Arrow keys: rotate the camera
- Comma and full stop: zoom
- `Ctrl+F1`: collision meshes in debug builds
- `Ctrl+F2`: shadow and post-processing render targets
- `Ctrl+F3`: performance metrics
- `Ctrl+M`: mute/unmute in debug builds
- `Ctrl+B`: toggle bloom in debug builds
- `Ctrl+V`: toggle the vignette in debug builds
- `Ctrl++` and `Ctrl+-`: change game-time speed in debug builds
- `Alt+Enter`: toggle full-screen mode

## Before each practical

1. Open `Assessment-1-MonoGame` in Visual Studio Code.
2. Open the integrated terminal and use `Get-Location` to confirm that it is in the expected copy.
3. Run `dotnet run --project ./WindowsDX/Platformer3D.csproj` on Windows, or use `DesktopGL` on macOS/Linux.
4. Confirm that the starting version still runs before changing it.
5. Make the week's work in the copy or branch specified by your lecturer.
6. Commit regularly when Git is available. Do not edit the lecturer's master copy.

The main areas we will use are:

- `Source/`: C# game loop, scenes, entities, rendering, collision, and gameplay code.
- `Content/Assets/Effects/`: HLSL `.fx` shader source.
- `Content/Assets/`: models, textures, audio, fonts, and level data.
- `Content/Content.csproj` and `Content/BuildContent.targets`: the experimental code-based content pipeline.
- `WindowsDX/`: the recommended Windows and college-PC launch project.
- `DesktopGL/`: the cross-platform desktop launcher used on macOS and Linux.

## Common problems

### `'C:\part of the path' is not recognised as a command`

The project is in an unsupported location or a path containing spaces. Move or clone the entire repository into `C:\Users\your-college-login\Documents\projects`, reopen `Assessment-1-MonoGame` in Visual Studio Code, and build again.

### The project builds but the debugger will not start the game

Check the full folder path first. On a college PC, the repository must be somewhere inside:

```text
C:\Users\your-college-login\Documents\projects
```

Move or clone it there, reopen `Assessment-1-MonoGame` in Visual Studio Code, and run:

```powershell
dotnet run --project ./WindowsDX/Platformer3D.csproj
```

If it still fails, keep the complete terminal error visible and report the PC number to your lecturer.

### `project.assets.json not found` for the Content project

Run:

```powershell
dotnet restore ./Content/Content.csproj
dotnet restore ./WindowsDX/Platformer3D.csproj
```

Then run `dotnet run --project ./WindowsDX/Platformer3D.csproj` again.

### Android SDK, iOS workload, or API-level errors

You built the entire solution. This module uses the desktop target. Run:

```powershell
dotnet build ./WindowsDX/Platformer3D.csproj
```

### `3DPlatformer.exe` is being used by another process

The game is still running, so Windows has locked the executable while the build is trying to replace it. Close the game window or return to the terminal that launched it and press `Ctrl+C`, then run the build or launch command again. Check that you have not left another copy running.

### NuGet download or restore errors

Check that a web page opens, then retry the failed restore once. If it still fails, keep the full error visible and tell your lecturer; the college firewall, proxy, or NuGet cache may need support. Do not install packages from unofficial download sites.

### `dotnet` is missing or no compatible SDK is listed

Run `powershell -NoProfile -ExecutionPolicy Bypass -File .\Setup-Assessment1.ps1` first. It can install .NET 10 for your current Windows user without administrator rights when college policy permits. If that bootstrap fails, report the PC number and the complete error to your lecturer or college IT.

### C# has no IntelliSense or F5 configurations

Confirm that C# Dev Kit is installed, then reopen the folder containing `Platformer3D.slnx`. Give C# Dev Kit a moment to load the workspace.

### HLSL files are plain text

Confirm that HLSL Tools by Tim Jones is enabled for this workspace, then reopen the `.fx` file.

## Version used to prepare this module

This folder includes the teaching baseline checked against upstream commit [`985b84f1154714fb68eb295579cbd10ec16694c6`](https://github.com/MonoGame/Starter-Kit-3D-Platformer/commit/985b84f1154714fb68eb295579cbd10ec16694c6), retrieved on 1 August 2026. Upstream `main` can continue changing without altering this cohort's copy.

For background, see MonoGame's official [Visual Studio Code setup guide](https://docs.monogame.net/articles/getting_started/2_choosing_your_ide_vscode.html) and [Content Builder documentation](https://docs.monogame.net/articles/getting_started/content_pipeline/content_builder_project.html).

## Credits and licence

The starter kit is maintained by the MonoGame project, based on Kenney's original Godot starter kit. Its source is MIT licensed, and its included 2D sprites, 3D models, and sound effects are CC0 licensed. This course repository preserves the upstream [`LICENSE.md`](LICENSE.md); the [official repository](https://github.com/MonoGame/Starter-Kit-3D-Platformer) remains the source of the original project.

This public repository contains only the pinned starter kit and student-safe course material. Lecturer solutions and in-development resources are kept in a separate private repository.
