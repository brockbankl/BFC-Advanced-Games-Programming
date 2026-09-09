import test from "node:test";
import assert from "node:assert/strict";
import { PROJECTILE_DAMAGE } from "../server/constants.js";
import { requestFire, updateRoom } from "../server/game-simulation.js";
import { RoomManager } from "../server/room-manager.js";

test("server fire creates a projectile and applies hits instead of accepting client health", () => {
  const manager = new RoomManager(); const { room, player: shooter } = manager.createRoom("One"); const victim = manager.joinRoom(room.code, "Two").player;
  shooter.x = 100; shooter.y = 100; shooter.angle = 0; victim.x = 150; victim.y = 100;
  assert.equal(requestFire(room, shooter, 1000), true); updateRoom(room, 0.1, 1100);
  assert.equal(victim.health, 100 - PROJECTILE_DAMAGE);
});
