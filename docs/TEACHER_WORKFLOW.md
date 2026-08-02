# Teacher workflow

The repository root is student-safe. Everything under `_teacher/` is ignored by the outer Git repository and must remain unpublished.

## Local layout

```text
_teacher/
  upstream-clean/       Git checkout of MonoGame's untouched repository
  teaching-base/        Copy with local college/workspace compatibility fixes
  lessons/              Independent copies for particles, shaders, AI, and solutions
```

`upstream-clean` is the reference source. Do not teach directly from it and do not commit course work to it. `teaching-base` is the source for new lesson copies. The provided quoting change in `Content/BuildContent.targets` is required because this local workspace has a space in `BFC Work`; it does not change game behaviour.

## Create or repair the local teacher area

From Visual Studio Code's integrated terminal at the repository root:

```powershell
./scripts/Initialize-TeacherWorkspace.ps1
```

The script refuses to replace existing directories. This is intentional: an existing lesson or solution should never be overwritten as a side effect of refreshing the base.

## Create a lesson copy

Use a short descriptive name containing letters, numbers, hyphens, or underscores:

```powershell
./scripts/New-LessonCopy.ps1 -Name 01-particles
./scripts/New-LessonCopy.ps1 -Name 02-hlsl-lighting
./scripts/New-LessonCopy.ps1 -Name 03-steering-ai
```

Each copy is placed under `_teacher/lessons/<name>` without upstream Git metadata. If a lesson later needs its own private remote, initialise Git inside that specific lesson directory and confirm the remote's privacy before pushing.

## Update the upstream baseline

Do not silently pull upstream changes into an active teaching year. Instead:

1. Fetch in `_teacher/upstream-clean`.
2. inspect the upstream diff and release/build requirements.
3. Test the exact desktop restore, build, and run workflow.
4. Update `upstream.json` and the version section in `README.md` together.
5. Create a fresh `teaching-base` only after archiving or renaming the old one.

This preserves a reproducible cohort baseline even when upstream `main` moves.

## Before publishing the course repository

Run:

```powershell
./scripts/Confirm-StudentSafe.ps1
git status --short
```

Also review the complete staged diff before committing. Never use `git add -f _teacher`, and never make the outer repository's ignore rule narrower to expose a single lesson file. Move genuinely student-facing material out of `_teacher` explicitly and review it first.

Choose the repository name and visibility before creating the GitHub remote. A public student guide and a private solution repository are safer than mixing both audiences in one repository.
