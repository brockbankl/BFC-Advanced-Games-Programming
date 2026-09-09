import { ARENA, FIRE_COOLDOWN_MS, PLAYER_MAX_HEALTH, PLAYER_RADIUS, PLAYER_SPEED, PROJECTILE_DAMAGE, PROJECTILE_RADIUS, PROJECTILE_SPEED, RESPAWN_MS, SPAWN_POINTS, WALLS } from "./constants.js";

function clamp(value, low, high) { return Math.max(low, Math.min(high, value)); }
function distanceSquared(a, b) { const dx = a.x - b.x; const dy = a.y - b.y; return dx * dx + dy * dy; }

function circleHitsWall(point, radius) {
  return WALLS.some((wall) => {
    const x = clamp(point.x, wall.x, wall.x + wall.width);
    const y = clamp(point.y, wall.y, wall.y + wall.height);
    return (point.x - x) ** 2 + (point.y - y) ** 2 < radius ** 2;
  });
}

function validTankPosition(room, player, x, y) {
  if (x < PLAYER_RADIUS || x > ARENA.width - PLAYER_RADIUS || y < PLAYER_RADIUS || y > ARENA.height - PLAYER_RADIUS) return false;
  if (circleHitsWall({ x, y }, PLAYER_RADIUS)) return false;
  return [...room.players.values()].every((other) => other === player || !other.alive || ((other.x - x) ** 2 + (other.y - y) ** 2 >= (PLAYER_RADIUS * 2) ** 2));
}

function respawnPlayer(room, player) {
  const orderedSpawns = [...SPAWN_POINTS.slice(player.slot), ...SPAWN_POINTS.slice(0, player.slot)];
  const spawn = orderedSpawns.find((candidate) => validTankPosition(room, player, candidate.x, candidate.y)) ?? SPAWN_POINTS[player.slot];
  player.x = spawn.x; player.y = spawn.y; player.health = PLAYER_MAX_HEALTH; player.alive = true; player.respawnAt = 0;
}

export function requestFire(room, player, now) {
  if (!player?.alive || now - player.lastFireAt < FIRE_COOLDOWN_MS) return false;
  player.lastFireAt = now;
  const offset = PLAYER_RADIUS + PROJECTILE_RADIUS + 2;
  room.projectiles.push({
    ownerId: player.id,
    x: player.x + Math.cos(player.angle) * offset,
    y: player.y + Math.sin(player.angle) * offset,
    vx: Math.cos(player.angle) * PROJECTILE_SPEED,
    vy: Math.sin(player.angle) * PROJECTILE_SPEED
  });
  return true;
}

export function updateRoom(room, deltaSeconds, now) {
  for (const player of room.players.values()) {
    if (!player.alive) {
      if (now >= player.respawnAt) respawnPlayer(room, player);
      continue;
    }
    player.angle = player.input.aimAngle;
    const xAxis = Number(player.input.right) - Number(player.input.left);
    const yAxis = Number(player.input.down) - Number(player.input.up);
    const length = Math.hypot(xAxis, yAxis) || 1;
    const dx = (xAxis / length) * PLAYER_SPEED * deltaSeconds;
    const dy = (yAxis / length) * PLAYER_SPEED * deltaSeconds;
    if (validTankPosition(room, player, player.x + dx, player.y)) player.x += dx;
    if (validTankPosition(room, player, player.x, player.y + dy)) player.y += dy;
  }

  room.projectiles = room.projectiles.filter((projectile) => {
    projectile.x += projectile.vx * deltaSeconds;
    projectile.y += projectile.vy * deltaSeconds;
    if (projectile.x < 0 || projectile.x > ARENA.width || projectile.y < 0 || projectile.y > ARENA.height || circleHitsWall(projectile, PROJECTILE_RADIUS)) return false;
    const victim = [...room.players.values()].find((player) => player.alive && player.id !== projectile.ownerId && distanceSquared(player, projectile) < (PLAYER_RADIUS + PROJECTILE_RADIUS) ** 2);
    if (!victim) return true;
    victim.health = Math.max(0, victim.health - PROJECTILE_DAMAGE);
    if (victim.health === 0) {
      victim.alive = false; victim.deaths += 1; victim.respawnAt = now + RESPAWN_MS;
      const shooter = room.players.get(projectile.ownerId);
      if (shooter) shooter.kills += 1;
    }
    return false;
  });
}

export function serialiseRoom(room) {
  return {
    type: "state", roomCode: room.code,
    players: [...room.players.values()].map(({ id, slot, name, x, y, angle, health, alive, kills, deaths, colour, respawnAt }) => ({ id, slot, name, x, y, angle, health, alive, kills, deaths, colour, respawnAt })),
    projectiles: room.projectiles.map(({ x, y }) => ({ x, y })),
    walls: WALLS
  };
}
