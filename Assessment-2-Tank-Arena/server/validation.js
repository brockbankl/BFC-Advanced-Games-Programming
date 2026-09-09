import { MAX_DISPLAY_NAME_LENGTH, MAX_MESSAGE_BYTES, ROOM_CODE_LENGTH } from "./constants.js";

const inputKeys = new Set(["up", "down", "left", "right"]);

export function normaliseDisplayName(value) {
  if (typeof value !== "string") return null;
  const name = value.trim().replace(/\s+/g, " ");
  if (name.length < 1 || name.length > MAX_DISPLAY_NAME_LENGTH) return null;
  // The client always uses textContent, but keeping names plain also makes logs safe to read.
  if (!/^[\p{L}\p{N} ._'-]+$/u.test(name)) return null;
  return name;
}

export function normaliseRoomCode(value) {
  if (typeof value !== "string") return null;
  const code = value.trim().toUpperCase();
  return new RegExp(`^[A-Z2-9]{${ROOM_CODE_LENGTH}}$`).test(code) ? code : null;
}

function validInput(input) {
  if (!input || typeof input !== "object" || Array.isArray(input)) return false;
  for (const key of Object.keys(input)) {
    if (!inputKeys.has(key) && key !== "aimAngle") return false;
  }
  if (!Number.isFinite(input.aimAngle) || Math.abs(input.aimAngle) > Math.PI * 2) return false;
  return [...inputKeys].every((key) => typeof input[key] === "boolean");
}

/** Parse and whitelist the small protocol; never spread arbitrary client objects. */
export function parseClientMessage(data) {
  if (typeof data !== "string" || Buffer.byteLength(data, "utf8") > MAX_MESSAGE_BYTES) {
    return { ok: false, error: "Message is too large or is not text." };
  }

  let message;
  try {
    message = JSON.parse(data);
  } catch {
    return { ok: false, error: "Message is not valid JSON." };
  }
  if (!message || typeof message !== "object" || Array.isArray(message) || typeof message.type !== "string") {
    return { ok: false, error: "Message must be an object with a type." };
  }

  switch (message.type) {
    case "createRoom": {
      const name = normaliseDisplayName(message.name);
      return name ? { ok: true, value: { type: "createRoom", name } } : { ok: false, error: "Display name must be 1–18 safe characters." };
    }
    case "joinRoom": {
      const name = normaliseDisplayName(message.name);
      const roomCode = normaliseRoomCode(message.roomCode);
      return name && roomCode ? { ok: true, value: { type: "joinRoom", name, roomCode } } : { ok: false, error: "Enter a valid name and four-character room code." };
    }
    case "input":
      return validInput(message.input) ? { ok: true, value: { type: "input", input: message.input } } : { ok: false, error: "Input state is invalid." };
    case "fire":
      return Object.keys(message).every((key) => key === "type") ? { ok: true, value: { type: "fire" } } : { ok: false, error: "Fire does not accept extra data." };
    default:
      return { ok: false, error: "Unknown message type." };
  }
}
