# Assessment 2: Tank Arena

Tank Arena is a small browser-based, real-time multiplayer game for Advanced Games Programming. It is a **teaching baseline**, not the finished assessment challenge. You receive a playable game so later work can focus on networking design: identity, protocol messages, server authority, validation, latency, reconnection, authentication and persistence.

Two to four people can join a short-code room, drive tanks, aim with a mouse, fire projectiles and see scores, damage, deaths and respawns. The server is authoritative: browsers send input, while the Node.js server decides positions, collisions, damage and scores.

## First time on a new or reset college PC

You need Visual Studio Code and Git if you use the recommended clone-and-push workflow. You do **not** need to install Node.js first: the recommended Windows setup installs the course-pinned Node.js 22 runtime into your own user account when it is missing. npm is included with Node and downloads the two project libraries recorded in `package-lock.json`.

For consistency with Assessment 1, clone or extract the course repository beneath:

```text
C:\Users\your-college-login\Documents\projects
```

Tank Arena itself does not technically require that location, but using the same location for both assessments avoids opening or editing the wrong copy on a reset college PC. Do not work directly from Downloads, a USB drive or a OneDrive-synchronised temporary copy. If your Documents folder is redirected or unavailable, ask your lecturer which approved location to use.

The setup labels mean:

- `[CHECK]`: checking a requirement.
- `[INFO]`: explaining the next step.
- `[PASS]`: a completed step.
- `[WARN]`: setup can continue, but something needs attention.
- `[FAIL]`: setup stopped; leave the complete message visible for your lecturer or IT.

### Route A: easiest Windows route

1. In File Explorer, open the `Assessment-2-Tank-Arena` folder.
2. Double-click `Setup-Assessment2.cmd`.
3. Read the terminal window while it works. Do not close it if it shows `[FAIL]`.
4. When it says **ASSESSMENT 2 SETUP COMPLETE**, open the same folder in Visual Studio Code.
5. Choose **Terminal > Run Task > BFC: Run Tank Arena**, or open a new integrated terminal and run `npm start`.

The `.cmd` file only starts the checked PowerShell script in the same folder. Its execution-policy override applies to that one process; it does not alter Windows security settings. The window stays open after a double-click so you can read the result.

### Route B: from Visual Studio Code

Open the `Assessment-2-Tank-Arena` folder directly in Visual Studio Code. Choose **Terminal > New Terminal** and run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Setup-Assessment2.ps1
```

The terminal prompt should end in `Assessment-2-Tank-Arena`. This workspace opens **Command Prompt** by default because it reliably runs Node's `npm.cmd` on college PCs with restrictive PowerShell script policy. **Terminal > Run Task > BFC: Setup Assessment 2** is an equivalent route. If setup has just installed Node, open a new terminal afterwards (or restart VS Code) so it reads the updated user PATH.

### What the setup script does

On Windows x64 or ARM64, setup looks for a suitable Node 22 first. If it cannot find one, it downloads the official Node.js `v22.23.2` ZIP directly from `nodejs.org`, verifies its published SHA-256 checksum, and extracts it without administrator rights to:

```text
%LOCALAPPDATA%\BFC-AGP\node\v22.23.2\x64
```

(`arm64` replaces `x64` on ARM Windows.) The verified ZIP is cached in `%LOCALAPPDATA%\BFC-AGP\node-cache` for reuse. The script adds only this folder to the existing **user** PATH, without replacing the rest of it, so future Command Prompt/VS Code terminals can find `node`, `npm` and `npx`. It works in the current setup process immediately even when policy prevents saving the user PATH. The workspace deliberately defaults its terminal to Command Prompt: it uses Node's normal `.cmd` launchers and does not require relaxing PowerShell execution policy.

Setup then runs `npm ci`, `npm test`, `npm run check`, and a short local `/health` check. The temporary test server is stopped automatically. It is safe to run again: a working user-local Node copy and a verified archive are reused, while `npm ci` ensures project packages match the committed lockfile.

The project uses Node 22 for reproducible teaching. If Node 23 or later is already installed, setup deliberately uses the pinned user-local Node 22 copy instead of silently changing the course runtime.

### Manual fallback

If the official download is blocked by college policy or the network is unavailable and no verified archive is cached, setup explains the failure and stops. Do not try to change execution policy, firewall settings or install Node system-wide. Instead, install Node **22** using the [official Node.js download page](https://nodejs.org/en/download), reopen VS Code, and run setup again. Keep the complete `[FAIL]` message and PC number for your lecturer or college IT if that route is unavailable.

`HTTP` is the ordinary web request that delivers the page, CSS and JavaScript. A `WebSocket` is the long-lived two-way connection that the page keeps open afterwards for game messages. `localhost` means “this same computer”, so `http://localhost:3000` works without putting your game online.

## Run the game

```powershell
npm start
```

Then open [http://localhost:3000](http://localhost:3000). Stop the server with `Ctrl+C` in the terminal. Setup already runs `npm ci`, which installs exactly the versions recorded in `package-lock.json`. `npm test` runs server-side logic tests, and `npm run check` checks JavaScript syntax without starting a browser.

### VS Code shortcuts

No extension is required for the supplied vanilla JavaScript/Node baseline; modern VS Code includes JavaScript and Node debugging support. Open **Terminal > Run Task** to use:

- **BFC: Setup Assessment 2** — run the safe rerunnable bootstrap.
- **BFC: Run Tank Arena** — start the server in an integrated terminal.
- **BFC: Test Assessment 2** — run the automated server-side tests.

You can also open **Run and Debug**, select **Tank Arena server (Node 22)**, then press `F5` to debug the server. Complete setup first. If you deliberately open a PowerShell terminal and `npm` is blocked by policy, use `npm.cmd start`; do not change the execution policy.

### Controls

- `W`, `A`, `S`, `D` or arrow keys: move.
- Mouse: aim the turret.
- Mouse click or `Space`: fire.
- A destroyed tank respawns after three seconds.

## Test locally before changing anything

1. Start the server with `npm start`.
2. Open `http://localhost:3000` in one normal browser window. Enter a name, choose **Create room**, and note the code.
3. Open an incognito/private browser window (or a second browser). This gives you a separate connection.
4. Visit the same address, enter a different name and choose **Join room** with the code.
5. Move both tanks, fire at each other, and check that health, score and respawn appear the same in both windows.
6. Close one tab. Its tank should disappear from the other tab. Join again from a fresh tab to confirm that a place becomes available.

For two computers on the same permitted network, start the server on one machine and discover its private IPv4 address with `ipconfig`. On the other machine browse to `http://that-address:3000`. College Wi-Fi, Windows Firewall or network isolation may block this; that is a network-policy issue, not a reason to weaken the code. Online deployment below is the more reliable cross-device test.

## How the supplied architecture works

```text
Browser: keys/mouse → JSON input/fire → Node + WebSocket server
Browser: Canvas ← state snapshots     ← server game simulation
```

- `server/server.js` serves `public/`, owns HTTP/WebSocket connections, sends heartbeat pings and dispatches safe messages.
- `server/validation.js` is the protocol gate. It parses JSON, rejects malformed/unknown input and only returns whitelisted fields.
- `server/room-manager.js` creates in-memory rooms, generates codes and assigns server-controlled IDs and player slots.
- `server/game-simulation.js` advances the 20-tick-per-second simulation: movement, wall/tank collision, projectiles, damage, death and respawn.
- `public/js/client.js` reads controls, sends bounded input and draws only the server’s snapshots on an HTML5 Canvas.
- `tests/` exercises logic that does not need a graphical browser.

Read [the networking primer](docs/NETWORKING-PRIMER.md) alongside the code, then use [the protocol reference](docs/PROTOCOL.md) when editing messages. These files deliberately expose the networking decisions rather than hiding them behind a framework.

## Deploy to Render

Render is a hosting provider: it runs your Node process on a public server. This project serves both the page and WebSocket from one Render **Web Service**, so the client automatically uses secure `wss://` when the page is HTTPS.

1. Make your own GitHub repository or fork/copy the course repository. See [GitHub’s account guide](https://docs.github.com/en/get-started/start-your-journey/creating-an-account-on-github) and [GitHub’s repository guide](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository).
2. Commit your work and push it. From the repository root, for example: `git add Assessment-2-Tank-Arena`, `git commit -m "Start Tank Arena"`, then add and push to **your own** GitHub remote.
3. Create or sign in to a [Render account](https://dashboard.render.com/), choose **New > Web Service**, connect GitHub, and select your repository.
4. Set the **Root Directory** to `Assessment-2-Tank-Arena`. This is important because `package.json` is inside that folder.
5. Choose **Node**. Set **Build Command** to `npm ci`; set **Start Command** to `npm start`; choose a region and, where permitted for the module, the Free instance type. Set health-check path to `/health`.
6. Select **Create Web Service** and watch the build log. A successful service receives a public `https://...onrender.com` URL.
7. Open that URL. Share it with a second device, create a room and join with the code. No separate WebSocket URL is required.

The server reads Render’s `PORT` environment variable and binds to `0.0.0.0`, as required for a public Render Web Service. The walkthrough is based on Render’s official [Node/Express deployment guide](https://render.com/docs/deploy-node-express-app), [Web Service documentation](https://render.com/docs/web-services) and [WebSocket guidance](https://render.com/docs/websocket). Providers and free-plan rules can change: always check the current course instructions and Render documentation before teaching or submitting.

### Render limitations worth knowing

This baseline intentionally stores rooms only in memory. A redeploy, restart or sleep loses rooms and players. At the time this guide was checked, Render says free Web Services can spin down after 15 minutes without incoming HTTP or WebSocket traffic, and the next request can take about a minute to wake it. Free services may also restart and have an ephemeral filesystem. That is suitable for a class demo, not persistent accounts or production play. See Render’s current [free-service limitations](https://render.com/docs/free).

## Troubleshooting

### `node` or `npm` is not recognised

Run `Setup-Assessment2.cmd` first. If it has just installed Node, close and reopen the VS Code terminal (or restart VS Code) so it receives the updated user PATH. If the command is still unavailable, rerun setup and keep its full error visible. Do not download Node from an unofficial site or change machine-wide PATH/security settings.

### `npm ci` says the lock file is out of date

Check that your terminal is in `Assessment-2-Tank-Arena` and that you copied the whole project, including `package-lock.json`. Delete only the local `node_modules` folder if necessary, then rerun `npm ci`. Do not commit `node_modules`.

### The page opens but says it cannot connect

Keep `npm start` running and use the exact address shown by it. Locally, use `http://localhost:3000`, not a saved `file:///` HTML file. On Render, open the HTTPS `onrender.com` page; the browser then selects WSS automatically.

### A classmate cannot join over the local network

Try two windows on one machine first. Network isolation, firewall policy and guest Wi-Fi commonly block peer-to-peer local testing. Use the deployed Render URL when permitted; do not disable college security controls.

### Render build or health check fails

Confirm the Root Directory is `Assessment-2-Tank-Arena`, Build Command is `npm ci`, Start Command is `npm start`, and Health Check Path is `/health`. Read the first actual error in the build log rather than only the final failure line.

## Working safely in Git

Work in your own copy/branch, make small commits and push only to your own repository. Do not edit the lecturer’s master copy. Before a practical, run `npm test`, start the baseline and confirm it works before changing it. The repository has no secrets, accounts or database; do not add credentials to source control.

## Natural next extensions (not implemented here)

The `RoomManager`, protocol gate and simulation boundary are intentional seams for later lessons: persistent accounts; server-assigned tank appearances; stronger rate limiting; reconnect tokens and grace periods; bot takeover; spectators; ping statistics; interpolation/prediction; reconciliation; artificial latency; and database-backed account data. Do not add those features until the baseline is understood and tested.
