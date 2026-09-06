# Assessment 2: Tank Arena

Tank Arena is a small browser-based, real-time multiplayer game for Advanced Games Programming. It is a **teaching baseline**, not the finished assessment challenge. You receive a playable game so later work can focus on networking design: identity, protocol messages, server authority, validation, latency, reconnection, authentication and persistence.

Two to four people can join a short-code room, drive tanks, aim with a mouse, fire projectiles and see scores, damage, deaths and respawns. The server is authoritative: browsers send input, while the Node.js server decides positions, collisions, damage and scores.

## What you need

- [Node.js 22](https://nodejs.org/en/download) (the runtime that runs the server and npm).
- npm, which is installed with Node and downloads the two project libraries listed in `package.json`.
- Visual Studio Code and its integrated terminal. Administrator rights are not required to run this project.
- Git if you use the recommended clone-and-push workflow.

Use **Node 22**, not an old Node version. In the `Assessment-2-Tank-Arena` folder, check it with:

```powershell
node --version
npm --version
```

`HTTP` is the ordinary web request that delivers the page, CSS and JavaScript. A `WebSocket` is the long-lived two-way connection that the page keeps open afterwards for game messages. `localhost` means “this same computer”, so `http://localhost:3000` works without putting your game online.

## First setup

Open **this folder** (`Assessment-2-Tank-Arena`) in Visual Studio Code, then choose **Terminal > New Terminal**. The prompt should end in `Assessment-2-Tank-Arena`.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Setup-Assessment2.ps1
```

That script checks Node/npm, installs the locked dependencies and runs the automated checks. Its execution-policy setting applies only to this one process; it does not change computer-wide security settings. You can run it repeatedly. For a double-click route on Windows, use `Setup-Assessment2.cmd`.

If Node is missing, install the current Node **22 LTS** release using the official link above, then completely close and reopen VS Code so its terminal receives the updated path. On a restricted college PC, do not improvise a machine-wide installation: keep the `[FAIL]` message visible and ask your lecturer or IT team for the official route.

## Run the game

```powershell
npm ci
npm start
```

Then open [http://localhost:3000](http://localhost:3000). Stop the server with `Ctrl+C` in the terminal. `npm ci` installs exactly the versions recorded in `package-lock.json`; use it for a fresh course copy. `npm test` runs server-side logic tests, and `npm run check` checks JavaScript syntax without starting a browser.

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

Node 22 is absent or VS Code was opened before it was installed. Install it through the approved route, close all VS Code windows, reopen this folder and rerun setup. Do not download Node from an unofficial site.

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
