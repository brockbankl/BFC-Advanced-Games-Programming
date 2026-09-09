# Tank Arena networking primer

This is a guide to the specific networked system in this folder. Read it with `server/server.js`, `server/room-manager.js` and `public/js/client.js` open.

## The two sides

A **client** is the program someone uses: here, a browser tab running `public/js/client.js`. A **server** is the program shared by clients: here, one Node process running `server/server.js`. The server is not “one player’s browser”; it is the referee that owns rooms and game outcomes.

The browser first makes an **HTTP request** for `GET /`. Express returns `public/index.html`, then the browser requests CSS and JavaScript. HTTP is request/response: the browser asks and the server replies. It is excellent for loading a page but not for rapid two-way game events.

The client then creates a **WebSocket** with `new WebSocket(websocketUrl())`. A WebSocket begins with an HTTP upgrade but becomes a persistent, two-way connection. The browser can send `{ "type": "input", ... }` at any time; the server can send snapshots at any time. Messages are serialised into **JSON** text before crossing the connection and parsed after arrival.

## Addresses in this project

`localhost` is a special name meaning the current computer. `http://localhost:3000` reaches the Node server you started locally. The number after `:` is a **port**, like a numbered entrance to a particular program on a computer. `3000` is the local default; Render supplies a different `PORT` value when deployed.

A public address has a domain, such as `your-game.onrender.com`. An ordinary page uses `http://` locally or `https://` publicly. WebSockets similarly use `ws://` locally and `wss://` over HTTPS. The extra `s` means TLS encryption. `websocketUrl()` deliberately chooses from `window.location.protocol`, so the same browser code is safe on Render.

At a conceptual level, HTTP and WebSockets normally use **TCP**, a transport designed to deliver an ordered stream reliably. TCP does not make it instantaneous: every network hop adds **latency**, the time taken for information to travel. The baseline does not hide latency with prediction; that is a later extension.

## Server authority and the game loop

The browser never sends “my tank is now at x/y”, “I hit them”, or “my score is 12”. It sends a short input state (`up`, `down`, `left`, `right`, `aimAngle`) and a `fire` request. `validation.js` rejects bad values, then `server.js` stores the valid input for that server-assigned player.

Every 50 milliseconds (20 times per second), `updateRoom()` in `game-simulation.js` reads each stored input, applies speed and collision rules, moves projectiles and calculates hits. This frequency is the simulation **tick/update rate**. It then sends a **game-state snapshot** containing player and projectile data. Browser rendering uses `requestAnimationFrame`, normally faster than the network tick, and draws the latest snapshot to Canvas.

This is called server-authoritative state. It makes client cheating harder and ensures the server, rather than an arbitrary browser, decides health and score. It also provides clear places to teach validation, client prediction and reconciliation later.

## Identity, rooms and lobby

When a browser creates or joins a room, `RoomManager` generates the internal `player-…` identifier and selects an unused numeric slot. The name is only a temporary display name; it is checked for length and allowed characters. The client receives its ID in `roomCreated`/`joined`, but it cannot choose it.

A **room** is a short-lived group of 2–4 players. The initial lobby asks one player to create a room and gives the resulting four-character code to others. Rooms live only in the server’s `Map`: closing/restarting the process clears them. When the last player leaves, `emptySince` is recorded; the housekeeping job removes the empty room after five minutes.

## Disconnects and heartbeat

Closing a tab causes the WebSocket’s `close` event. The server removes its player and sends `playerLeft` and a fresh snapshot to the remaining room. This prevents permanent ghosts.

Some failures never produce a clean close—for example, a laptop sleeping. Every 30 seconds `server.js` sends a WebSocket **ping**. A functioning connection responds with **pong**. A connection that failed the previous ping is terminated; its normal cleanup path removes the player. This is a simple heartbeat, not reconnection support. There are deliberately no reconnect tokens, grace period or bot substitution yet.

For exact fields and message examples, see [PROTOCOL.md](PROTOCOL.md).
