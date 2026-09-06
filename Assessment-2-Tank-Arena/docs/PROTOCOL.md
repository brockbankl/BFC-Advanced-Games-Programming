# Tank Arena JSON protocol

All WebSocket messages are UTF-8 JSON objects. The server accepts at most 4 KiB per incoming message, parses defensively and only accepts the documented client message types. A client cannot select an authoritative ID, slot, position, health, score or hit.

```text
Browser                    Server
   | ---- WebSocket open ----> |
   | <--- connected --------- |
   | ---- createRoom -------->|
   | <--- roomCreated --------|  (server assigns playerId and slot)
   | <--- state snapshots ----|  (20 per second)
   | ---- input / fire ------>|
   | <--- state snapshots ----|
```

## Client → server

### `createRoom`

Sent only once on a newly connected browser. The server creates an ephemeral room, server-assigned player ID and slot.

```json
{ "type": "createRoom", "name": "Alex" }
```

### `joinRoom`

Sent only once on a newly connected browser. Room code is uppercase four characters from `A-Z`/`2-9`; names are 1–18 permitted characters after trimming.

```json
{ "type": "joinRoom", "name": "Sam", "roomCode": "K7PX" }
```

### `input`

Sent about 20 times a second while in a room. Each directional property must be boolean. `aimAngle` must be a finite number between `-2π` and `2π`; it is the mouse direction in radians. The server stores this input and performs movement itself.

```json
{ "type": "input", "input": { "up": true, "down": false, "left": false, "right": true, "aimAngle": -0.52 } }
```

### `fire`

Requests a shot. It has no coordinates or target; the server uses its current authoritative tank angle/location and enforces the firing cooldown.

```json
{ "type": "fire" }
```

## Server → client

### `connected`

Confirms a new WebSocket before room selection.

```json
{ "type": "connected", "message": "Connected. Create or join a room." }
```

### `roomCreated` and `joined`

Confirm membership. `playerId` and `slot` are created by the server; the browser only remembers them to identify its own tank in snapshots.

```json
{ "type": "roomCreated", "playerId": "player-1", "slot": 0, "roomCode": "K7PX" }
```

`joined` has the same fields for a joining player.

### `playerJoined` and `playerLeft`

These are small lobby notifications. A state snapshot immediately follows or is already arriving regularly, so clients should treat the snapshot as the final source of truth.

```json
{ "type": "playerJoined", "player": { "id": "player-2", "name": "Sam", "slot": 1 } }
```

```json
{ "type": "playerLeft", "playerId": "player-2" }
```

### `state`

Sent to every player in a room after each server tick. It contains only renderable public state: room code, players, projectiles and wall rectangles. `alive: false` with `respawnAt` lets the client show a respawn message. The client does not treat this as permission to change the state.

```json
{ "type": "state", "roomCode": "K7PX", "players": [{ "id": "player-1", "slot": 0, "name": "Alex", "x": 95, "y": 85, "angle": -1.57, "health": 100, "alive": true, "kills": 0, "deaths": 0, "colour": "#57d5ff", "respawnAt": 0 }], "projectiles": [], "walls": [] }
```

### `error`

The server rejects malformed JSON, unknown types, invalid fields, missing/full rooms and actions before joining. The socket remains usable for a recoverable error.

```json
{ "type": "error", "message": "That room is already full (maximum four players)." }
```

## Disconnect behaviour

The server removes a player on `close`, network error or stale heartbeat. It broadcasts `playerLeft` and the remaining room’s next `state`. An empty room is removed after five minutes. The baseline intentionally has no account/session recovery, grace period, reconnect token or AI takeover.

## Adding a message later

Add the new type in `parseClientMessage()` first, validate each value explicitly, then route its returned safe object in `server.js`. Update this document and tests in the same change. Do not accept arbitrary client object fields or use client values directly as server state.
