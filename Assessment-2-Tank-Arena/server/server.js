import http from "node:http";
import path from "node:path";
import { fileURLToPath } from "node:url";
import express from "express";
import { WebSocket, WebSocketServer } from "ws";
import { MAX_MESSAGE_BYTES, TICK_MS } from "./constants.js";
import { updateRoom, requestFire, serialiseRoom } from "./game-simulation.js";
import { RoomManager } from "./room-manager.js";
import { parseClientMessage } from "./validation.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const publicDirectory = path.join(__dirname, "..", "public");

function safelySend(socket, message) {
  if (socket.readyState === WebSocket.OPEN) socket.send(JSON.stringify(message));
}

export function createTankArenaServer({ roomManager = new RoomManager(), logger = console } = {}) {
  const app = express();
  app.disable("x-powered-by");
  app.get("/health", (_request, response) => response.status(200).json({ status: "ok" }));
  app.use(express.static(publicDirectory, { extensions: ["html"] }));

  const httpServer = http.createServer(app);
  const webSocketServer = new WebSocketServer({ server: httpServer, maxPayload: MAX_MESSAGE_BYTES });
  const sessions = new Map();

  function sendRoomState(room) {
    const snapshot = serialiseRoom(room);
    for (const player of room.players.values()) safelySend(sessions.get(player.id)?.socket, snapshot);
  }

  function removeSessionPlayer(session) {
    if (!session.playerId || !session.roomCode) return;
    const room = roomManager.removePlayer(session.roomCode, session.playerId);
    if (room) {
      for (const player of room.players.values()) safelySend(sessions.get(player.id)?.socket, { type: "playerLeft", playerId: session.playerId });
      sendRoomState(room);
    }
    sessions.delete(session.playerId);
    session.playerId = null; session.roomCode = null;
  }

  webSocketServer.on("connection", (socket) => {
    const session = { socket, playerId: null, roomCode: null, isAlive: true };
    socket.on("pong", () => { session.isAlive = true; });
    safelySend(socket, { type: "connected", message: "Connected. Create or join a room." });

    socket.on("message", (data, isBinary) => {
      if (isBinary || data.length > MAX_MESSAGE_BYTES) return safelySend(socket, { type: "error", message: "Only small JSON text messages are allowed." });
      const parsed = parseClientMessage(data.toString("utf8"));
      if (!parsed.ok) return safelySend(socket, { type: "error", message: parsed.error });
      const message = parsed.value;

      if (message.type === "createRoom" || message.type === "joinRoom") {
        if (session.playerId) return safelySend(socket, { type: "error", message: "This connection has already joined a room." });
        const result = message.type === "createRoom" ? roomManager.createRoom(message.name) : roomManager.joinRoom(message.roomCode, message.name);
        if (result.error) return safelySend(socket, { type: "error", message: result.error });
        const { room, player } = result;
        session.playerId = player.id; session.roomCode = room.code; sessions.set(player.id, session);
        safelySend(socket, { type: message.type === "createRoom" ? "roomCreated" : "joined", playerId: player.id, slot: player.slot, roomCode: room.code });
        for (const other of room.players.values()) if (other.id !== player.id) safelySend(sessions.get(other.id)?.socket, { type: "playerJoined", player: { id: player.id, name: player.name, slot: player.slot } });
        sendRoomState(room);
        return;
      }

      if (!session.playerId) return safelySend(socket, { type: "error", message: "Create or join a room first." });
      const room = roomManager.rooms.get(session.roomCode);
      const player = room?.players.get(session.playerId);
      if (!room || !player) return safelySend(socket, { type: "error", message: "Your room is no longer available." });
      if (message.type === "input") player.input = { ...message.input };
      if (message.type === "fire") requestFire(room, player, Date.now());
    });
    socket.on("close", () => removeSessionPlayer(session));
    socket.on("error", () => removeSessionPlayer(session));
  });

  let previousTick = Date.now();
  const gameLoop = setInterval(() => {
    const now = Date.now();
    const delta = Math.min((now - previousTick) / 1000, 0.1);
    previousTick = now;
    for (const room of roomManager.rooms.values()) {
      if (room.players.size) { updateRoom(room, delta, now); sendRoomState(room); }
    }
  }, TICK_MS);

  const housekeeping = setInterval(() => {
    for (const session of sessions.values()) {
      if (!session.isAlive) { session.socket.terminate(); continue; }
      session.isAlive = false; session.socket.ping();
    }
    roomManager.cleanupEmptyRooms();
  }, 30000);

  return {
    app, httpServer, webSocketServer, roomManager,
    listen(port, host = "0.0.0.0") { return new Promise((resolve) => httpServer.listen(port, host, resolve)); },
    close() { clearInterval(gameLoop); clearInterval(housekeeping); webSocketServer.clients.forEach((socket) => socket.terminate()); return new Promise((resolve) => httpServer.close(resolve)); }
  };
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const port = Number.parseInt(process.env.PORT ?? "3000", 10);
  const server = createTankArenaServer();
  server.listen(Number.isFinite(port) ? port : 3000).then(() => loggerInfo(`Tank Arena listening at http://localhost:${Number.isFinite(port) ? port : 3000}`));
  function loggerInfo(message) { console.log(message); }
  process.on("SIGTERM", () => server.close().finally(() => process.exit(0)));
  process.on("SIGINT", () => server.close().finally(() => process.exit(0)));
}
