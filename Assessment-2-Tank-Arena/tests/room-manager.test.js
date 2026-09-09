import test from "node:test";
import assert from "node:assert/strict";
import { MAX_PLAYERS_PER_ROOM } from "../server/constants.js";
import { RoomManager } from "../server/room-manager.js";

test("creates short room codes and assigns server-owned player slots", () => {
  const manager = new RoomManager({ random: () => 0 });
  const { room, player } = manager.createRoom("Alex");
  assert.match(room.code, /^[A-Z2-9]{4}$/); assert.equal(player.slot, 0); assert.match(player.id, /^player-/);
});

test("a room allocates slots and refuses a fifth player", () => {
  const manager = new RoomManager(); const { room } = manager.createRoom("One");
  for (let number = 2; number <= MAX_PLAYERS_PER_ROOM; number += 1) assert.equal(manager.joinRoom(room.code, `Player ${number}`).player.slot, number - 1);
  assert.match(manager.joinRoom(room.code, "Five").error, /full/);
});

test("removed players free their slot and old empty rooms are cleaned", () => {
  let now = 0; const manager = new RoomManager({ now: () => now }); const { room, player } = manager.createRoom("One");
  manager.removePlayer(room.code, player.id); now = 5 * 60 * 1000; assert.equal(manager.cleanupEmptyRooms(), 1); assert.equal(manager.rooms.size, 0);
});
