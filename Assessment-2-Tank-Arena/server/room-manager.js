import { EMPTY_ROOM_TTL_MS, MAX_PLAYERS_PER_ROOM, PLAYER_COLOURS, PLAYER_MAX_HEALTH, SPAWN_POINTS } from "./constants.js";

const roomAlphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

function newPlayer(id, slot, name) {
  const spawn = SPAWN_POINTS[slot];
  return {
    id, slot, name, x: spawn.x, y: spawn.y, angle: -Math.PI / 2,
    health: PLAYER_MAX_HEALTH, alive: true, kills: 0, deaths: 0,
    colour: PLAYER_COLOURS[slot], input: { up: false, down: false, left: false, right: false, aimAngle: -Math.PI / 2 },
    lastFireAt: 0, respawnAt: 0
  };
}

export class RoomManager {
  constructor({ now = () => Date.now(), random = Math.random } = {}) {
    this.rooms = new Map();
    this.nextPlayerNumber = 1;
    this.now = now;
    this.random = random;
  }

  generateCode() {
    let code;
    do {
      code = Array.from({ length: 4 }, () => roomAlphabet[Math.floor(this.random() * roomAlphabet.length)]).join("");
    } while (this.rooms.has(code));
    return code;
  }

  createRoom(name) {
    const code = this.generateCode();
    const room = { code, players: new Map(), projectiles: [], createdAt: this.now(), emptySince: null };
    this.rooms.set(code, room);
    const player = this.addPlayer(room, name);
    return { room, player };
  }

  joinRoom(code, name) {
    const room = this.rooms.get(code);
    if (!room) return { error: "That room code does not exist." };
    if (room.players.size >= MAX_PLAYERS_PER_ROOM) return { error: "That room is already full (maximum four players)." };
    return { room, player: this.addPlayer(room, name) };
  }

  addPlayer(room, name) {
    const usedSlots = new Set([...room.players.values()].map((player) => player.slot));
    const slot = [0, 1, 2, 3].find((value) => !usedSlots.has(value));
    const player = newPlayer(`player-${this.nextPlayerNumber++}`, slot, name);
    room.players.set(player.id, player);
    room.emptySince = null;
    return player;
  }

  removePlayer(roomCode, playerId) {
    const room = this.rooms.get(roomCode);
    if (!room || !room.players.delete(playerId)) return null;
    if (room.players.size === 0) room.emptySince = this.now();
    return room;
  }

  cleanupEmptyRooms() {
    let removed = 0;
    for (const [code, room] of this.rooms) {
      if (room.emptySince !== null && this.now() - room.emptySince >= EMPTY_ROOM_TTL_MS) {
        this.rooms.delete(code);
        removed += 1;
      }
    }
    return removed;
  }
}
