export const ARENA = Object.freeze({ width: 960, height: 640 });
export const MAX_PLAYERS_PER_ROOM = 4;
export const TICK_RATE = 20;
export const TICK_MS = 1000 / TICK_RATE;
export const PLAYER_RADIUS = 18;
export const PLAYER_SPEED = 150;
export const PLAYER_MAX_HEALTH = 100;
export const RESPAWN_MS = 3000;
export const FIRE_COOLDOWN_MS = 450;
export const PROJECTILE_SPEED = 430;
export const PROJECTILE_RADIUS = 5;
export const PROJECTILE_DAMAGE = 34;
export const MAX_DISPLAY_NAME_LENGTH = 18;
export const ROOM_CODE_LENGTH = 4;
export const MAX_MESSAGE_BYTES = 4096;
export const EMPTY_ROOM_TTL_MS = 5 * 60 * 1000;
export const WALLS = Object.freeze([
  { x: 170, y: 120, width: 130, height: 44 },
  { x: 660, y: 120, width: 130, height: 44 },
  { x: 410, y: 235, width: 140, height: 44 },
  { x: 170, y: 475, width: 130, height: 44 },
  { x: 660, y: 475, width: 130, height: 44 },
  { x: 60, y: 285, width: 88, height: 70 },
  { x: 812, y: 285, width: 88, height: 70 }
]);

export const SPAWN_POINTS = Object.freeze([
  { x: 95, y: 85 },
  { x: 865, y: 85 },
  { x: 95, y: 555 },
  { x: 865, y: 555 }
]);

export const PLAYER_COLOURS = Object.freeze(["#57d5ff", "#ff718a", "#b7eb6d", "#ffc857"]);
