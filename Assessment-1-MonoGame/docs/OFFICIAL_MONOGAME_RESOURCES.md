# Official MonoGame and 3D Platformer Resources

The practical sessions give you the guided route through this project. This page is for anyone who wants a better understanding of what is happening underneath the cheerful robot, floating platforms, alarming quantities of bloom, and whatever we add to it next.

All links below lead to resources maintained or published by the MonoGame project. They were checked on 2 August 2026.

## Begin with the actual project

- [Official MonoGame 3D Platformer Starter Kit repository](https://github.com/MonoGame/Starter-Kit-3D-Platformer) — the original MonoGame project, its source, controls, project layout, Blender level workflow, and licence.
- [Official starter-kit reveal video](https://www.youtube.com/watch?v=_HTFDE4oDmY) — a short visual introduction to the game and the features included in it.
- [MonoGame starter kits and demos](https://monogame.net/create/) — the official collection containing this starter kit and other examples.
- [Original starter-kit announcement](https://monogame.net/blog/2025-07-16-3d-starter-kit/) — useful background about why the MonoGame Foundation created the port and what it set out to demonstrate. This is a historical announcement, so use the public GitHub repository for the current project.

Our course repository contains a **fixed teaching snapshot** of that project. Use the course copy for practical and assessed work unless you are told otherwise. The upstream project can continue changing, which is excellent for MonoGame but less excellent halfway through a lesson.

## Watch the official development streams

The MonoGame Foundation also developed and explained the starter kit in public livestreams. These are much longer than the reveal video, but they let you see the maintainers navigate the real project, explain decisions, investigate code, and occasionally encounter the less glamorous bits of development that edited tutorials politely hide.

### Original reveal and development background

- [MonoGame Open Hours — July 2025](https://www.youtube.com/watch?v=XYlfpiqM_fQ) (1 hour 8 minutes) — the Open Hours session associated with the starter kit's original announcement.
- [3D Platformer Starter Kit reveal](https://www.youtube.com/watch?v=_HTFDE4oDmY) — the shorter project overview if you would like the tour without first preparing provisions for a full livestream.

### MonoGame University: 3D Platformer Sample

This is a sequence of five official sessions presented by Simon Jackson. Watch them in order if you want the most complete guided exploration:

1. [3D Platformer Sample — Session 1](https://www.youtube.com/watch?v=NJJ2YKBeF58) (1 hour 4 minutes)
2. [3D Platformer Sample — Session 2](https://www.youtube.com/watch?v=2eciHqXEv4A) (55 minutes)
3. [3D Platformer Sample — Session 3](https://www.youtube.com/watch?v=KE0SBS2D6ng) (1 hour 7 minutes)
4. [3D Platformer Sample — Session 4](https://www.youtube.com/watch?v=I1Uq46WAS9w) (1 hour 7 minutes)
5. [3D Platformer Sample — Session 5](https://www.youtube.com/watch?v=nK2jreobQfk) (1 hour 5 minutes)

You do not have to watch all five before touching the code. Play the game and take our classroom tour first, then return to the stream sequence when you want to understand the project in more depth or see how experienced MonoGame developers reason about it.

### Later development and release

- [CodeTime with Tom Spilman — working on the 3D Platformer](https://www.youtube.com/watch?v=8S7OzNyI8TA) (2 hours 38 minutes) — a long-form development session showing work on the actual project.
- [MonoGame Open Hours — July 2026](https://www.youtube.com/watch?v=4v7wDXQJc8k) (1 hour 34 minutes) — includes the public 3D Platformer release among the session topics.
- [Official MonoGame livestream archive](https://www.youtube.com/@MonoGame/streams) — use this for later streams and follow-up material added after this guide was checked.

Livestreams represent the project at the date they were recorded. Names, folders, or implementation details may differ slightly from our pinned course copy, so concentrate on the ideas and check the code in front of you before copying anything wholesale.

## A sensible first tour of our copy

Run and play the game first. Afterwards, trace one small route through the source rather than trying to understand every class at once:

1. Open `WindowsDX/Program.cs` (`DesktopGL/Program.cs` on macOS or Linux) to find where the application starts.
2. Open `Source/PlatformerGame.cs` to see the main MonoGame class and game lifecycle.
3. Look at `Source/Base/Scene.cs` and `Source/Base/SceneLoader.cs` to see how a level becomes a running scene.
4. Compare `Source/Entities/Player.cs`, `Coin.cs`, and `Platform.cs` to see how different entities specialise shared behaviour.
5. Look at `Source/Base/SceneRenderer.cs` and `PostProcessor.cs` to find the rendering and screen-effect work.
6. Browse `Content/Assets/` to connect the source files—models, textures, sounds, levels, and effects—to what appears in the game.
7. Open `Content/Builder/Builder.cs` and `Content/BuildContent.targets` to see how those source assets are selected, processed, and copied into the game build.

Do not attempt to read the entire project in alphabetical order. That is less a learning strategy and more a very slow screensaver.

## MonoGame foundations

These official pages explain ideas used throughout the starter kit:

- [What is MonoGame?](https://docs.monogame.net/articles/tutorials/building_2d_games/01_what_is_monogame/) — what the framework provides, what it deliberately leaves to you, and why its cross-platform approach matters. This chapter belongs to the official 2D course, but the framework concepts apply equally to this 3D project.
- [MonoGame documentation home](https://docs.monogame.net/articles/) — the main route into the manuals, concepts, how-to articles, and reference material.
- [Getting started with MonoGame](https://docs.monogame.net/articles/getting_started/) — supported operating systems, development tools, and project setup.
- [Official Visual Studio Code setup](https://docs.monogame.net/articles/getting_started/2_choosing_your_ide_vscode.html) — C# support, MonoGame tools, templates, and the integrated terminal.
- [The `Game`/`Game1` lifecycle](https://docs.monogame.net/articles/tutorials/building_2d_games/03_the_game1_file/) — explains `Initialize`, `LoadContent`, `Update`, and `Draw`. Our class is named `PlatformerGame`, but it follows the same lifecycle.
- [Supported platforms](https://docs.monogame.net/articles/getting_started/platforms.html) — explains the desktop, mobile, and console targets behind MonoGame's cross-platform claim.

## Content and assets

This starter kit uses MonoGame's newer **Content Builder Project**, not the older MGCB Editor workflow found in many tutorials.

- [Working with Content Builder Projects](https://docs.monogame.net/articles/getting_started/content_pipeline/content_builder_project.html) — the most directly relevant content guide for this project. Read the sections on `ContentCollection`, include/exclude rules, importers, and processors.
- [Official Content Builder video](https://www.youtube.com/watch?v=QB43LgRmdNM) — a short setup and workflow demonstration from MonoGame.
- [Content Pipeline chapter](https://docs.monogame.net/articles/tutorials/building_2d_games/05_content_pipeline/) — a friendly explanation of why assets are processed into platform-ready content. It demonstrates the traditional MGCB route, so use it for the concepts and use the Content Builder page above for this project's actual implementation.

When you add an asset, remember that copying a file into `Content/Assets/` is only the first half of the job. The builder must include it, an appropriate importer and processor must understand it, the build must succeed, and the game must load the resulting content using the correct asset name. Four opportunities for a typo: how generous.

## Understanding the 3D rendering

- [What is 3D rendering?](https://docs.monogame.net/articles/getting_to_know/whatis/graphics/WhatIs_3DRendering.html) — world, view, and projection matrices; vertices; effects; textures; and the graphics device.
- [Official graphics how-to collection](https://docs.monogame.net/articles/getting_to_know/howto/graphics/) — a useful index covering cameras, 3D rendering, render targets, graphics state, and collision topics.
- [Render a model with `BasicEffect`](https://docs.monogame.net/articles/getting_to_know/howto/graphics/HowTo_RenderModel.html) — connects model loading, mesh drawing, lighting, and world/view/projection matrices.
- [Move and rotate a camera](https://docs.monogame.net/articles/getting_to_know/howto/graphics/HowTo_RotateMoveCamera.html) — a small example that helps explain the camera code used by the platformer.
- [Create a `BasicEffect`](https://docs.monogame.net/articles/getting_to_know/howto/graphics/HowTo_Create_a_BasicEffect.html) — demonstrates the minimum state required to draw 3D geometry.
- [Custom effects and shaders](https://docs.monogame.net/articles/getting_started/content_pipeline/custom_effects.html) — explains MonoGame's effect system, shader compilation, platform differences, and several wonderfully specific ways a shader can refuse to cooperate.
- [MonoGame API reference](https://docs.monogame.net/api/) — use this when you know the class or method you are investigating and need its precise members and behaviour.

The how-to examples are deliberately smaller than this starter kit. That is useful: identify the simple idea in the guide, then find the more complete version in our project.

## Official tutorials and help

- [MonoGame tutorial directory](https://docs.monogame.net/articles/tutorials/) — the official index of MonoGame and selected community learning material.
- [Samples and demos](https://docs.monogame.net/articles/samples.html) — other complete and focused examples for comparing approaches.
- [Help and support](https://docs.monogame.net/articles/help_and_support.html) — official routes to documentation, GitHub Discussions, and the MonoGame community.

At the time this list was checked, MonoGame's dedicated beginner 3D tutorial was still marked as **coming soon**. Check the official tutorial directory for updates, but do not wait for it before exploring this project: the starter kit, its README, and the focused 3D how-to pages already provide plenty to investigate.

## How to use these resources without getting lost

Choose a question first, then use the smallest relevant resource. For example:

- “Where does the game start?” — trace `Program.cs` into `PlatformerGame.cs`, then read the game-lifecycle chapter.
- “How does this model reach the screen?” — follow it from `Content/Assets/Models`, through the builder, into `Content.Load`, then into the renderer.
- “Why does this shader need matrices?” — read the 3D rendering and `BasicEffect` pages, then compare them with an `.fx` file in `Content/Assets/Effects/`.
- “How is this cross-platform?” — compare `WindowsDX`, `DesktopGL`, and the shared `Source` project, then read the supported-platforms page.

You do not need to memorise the entire framework. You need to become good at locating the relevant code, checking the official explanation, testing a small change, and using the result as evidence. That is a much more useful advanced-programming skill than remembering which folder contained the coin on a rainy Tuesday.
