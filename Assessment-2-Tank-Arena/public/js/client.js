const canvas = document.querySelector("#game-canvas");
const context = canvas.getContext("2d");
const lobby = document.querySelector("#lobby");
const gameArea = document.querySelector("#game-area");
const nameInput = document.querySelector("#player-name");
const roomInput = document.querySelector("#room-code");
const lobbyMessage = document.querySelector("#lobby-message");
const roomLabel = document.querySelector("#room-label");
const connectionStatus = document.querySelector("#connection-status");
const scoreboard = document.querySelector("#scoreboard");
const createButton = document.querySelector("#create-room");
const joinButton = document.querySelector("#join-room");

const input = { up: false, down: false, left: false, right: false, aimAngle: -Math.PI / 2 };
let socket;
let myPlayerId = null;
let roomCode = null;
let state = { players: [], projectiles: [], walls: [] };

function websocketUrl() {
  const scheme = window.location.protocol === "https:" ? "wss:" : "ws:";
  return `${scheme}//${window.location.host}`;
}

function setLobbyMessage(message, isError = false) {
  lobbyMessage.textContent = message;
  lobbyMessage.classList.toggle("error", isError);
}

function setConnection(message, offline = false) {
  connectionStatus.textContent = message;
  connectionStatus.classList.toggle("offline", offline);
}

function send(message) {
  if (socket?.readyState === WebSocket.OPEN) socket.send(JSON.stringify(message));
}

function connect() {
  socket = new WebSocket(websocketUrl());
  socket.addEventListener("open", () => {
    createButton.disabled = false; joinButton.disabled = false;
    setLobbyMessage("Connected. Create a room or enter a room code."); setConnection("Connected");
  });
  socket.addEventListener("message", ({ data }) => {
    let message;
    try { message = JSON.parse(data); } catch { return; }
    if (message.type === "error") { setLobbyMessage(message.message, true); return; }
    if (message.type === "roomCreated" || message.type === "joined") {
      myPlayerId = message.playerId; roomCode = message.roomCode;
      roomLabel.textContent = `ROOM ${roomCode}`; lobby.hidden = true; gameArea.hidden = false;
      setConnection("Connected"); return;
    }
    if (message.type === "state") { state = message; drawScoreboard(); }
  });
  socket.addEventListener("close", () => {
    createButton.disabled = true; joinButton.disabled = true;
    setConnection("Disconnected — refresh to reconnect", true);
    if (!lobby.hidden) setLobbyMessage("Connection closed. Refresh the page and try again.", true);
  });
  socket.addEventListener("error", () => setLobbyMessage("Could not connect to the game server.", true));
}

function join(create) {
  const name = nameInput.value;
  if (!name.trim()) return setLobbyMessage("Please enter a display name.", true);
  if (create) send({ type: "createRoom", name });
  else send({ type: "joinRoom", name, roomCode: roomInput.value.toUpperCase() });
}

function drawScoreboard() {
  scoreboard.replaceChildren();
  state.players.slice().sort((a, b) => b.kills - a.kills || a.deaths - b.deaths).forEach((player) => {
    const row = document.createElement("li");
    if (player.id === myPlayerId) row.className = "you";
    const swatch = document.createElement("span"); swatch.className = "score-swatch"; swatch.style.background = player.colour;
    row.append(swatch, document.createTextNode(`${player.name}${player.id === myPlayerId ? " (you)" : ""} — ${player.kills} K / ${player.deaths} D`));
    scoreboard.append(row);
  });
}

function drawTank(player) {
  context.save(); context.translate(player.x, player.y); context.rotate(player.angle);
  context.fillStyle = player.colour; context.strokeStyle = "#06101b"; context.lineWidth = 3;
  context.fillRect(-21, -15, 42, 30); context.strokeRect(-21, -15, 42, 30);
  context.fillStyle = "#dff6ff"; context.fillRect(0, -5, 31, 10);
  context.fillStyle = "#102131"; context.beginPath(); context.arc(0, 0, 10, 0, Math.PI * 2); context.fill(); context.restore();
  context.fillStyle = "#eff8ff"; context.font = "bold 13px system-ui"; context.textAlign = "center"; context.fillText(player.name, player.x, player.y - 30);
  context.fillStyle = "#07111f"; context.fillRect(player.x - 20, player.y + 25, 40, 6); context.fillStyle = "#69e5a2"; context.fillRect(player.x - 20, player.y + 25, 40 * (player.health / 100), 6);
}

function draw() {
  context.clearRect(0, 0, canvas.width, canvas.height); context.fillStyle = "#123049"; context.fillRect(0, 0, canvas.width, canvas.height);
  context.strokeStyle = "#21445f"; context.lineWidth = 1;
  for (let x = 0; x <= canvas.width; x += 40) { context.beginPath(); context.moveTo(x, 0); context.lineTo(x, canvas.height); context.stroke(); }
  for (let y = 0; y <= canvas.height; y += 40) { context.beginPath(); context.moveTo(0, y); context.lineTo(canvas.width, y); context.stroke(); }
  for (const wall of state.walls) { context.fillStyle = "#536f83"; context.fillRect(wall.x, wall.y, wall.width, wall.height); context.strokeStyle = "#a5c3d2"; context.strokeRect(wall.x, wall.y, wall.width, wall.height); }
  for (const projectile of state.projectiles) { context.fillStyle = "#fff1a8"; context.beginPath(); context.arc(projectile.x, projectile.y, 5, 0, Math.PI * 2); context.fill(); }
  for (const player of state.players) { if (player.alive) drawTank(player); else { context.fillStyle = "#ff9aa8"; context.font = "14px system-ui"; context.textAlign = "center"; context.fillText(`${player.name} respawning…`, player.x, player.y); } }
  requestAnimationFrame(draw);
}

function updateAim(event) {
  const rect = canvas.getBoundingClientRect();
  const me = state.players.find((player) => player.id === myPlayerId);
  if (!me) return;
  const x = (event.clientX - rect.left) * canvas.width / rect.width;
  const y = (event.clientY - rect.top) * canvas.height / rect.height;
  input.aimAngle = Math.atan2(y - me.y, x - me.x);
}

const keyBindings = { KeyW: "up", ArrowUp: "up", KeyS: "down", ArrowDown: "down", KeyA: "left", ArrowLeft: "left", KeyD: "right", ArrowRight: "right" };
function isEditableTarget(target) {
  return target instanceof HTMLInputElement || target instanceof HTMLTextAreaElement || target.isContentEditable;
}

function canUseGameKeyboard(event) {
  return !gameArea.hidden && !isEditableTarget(event.target);
}

window.addEventListener("keydown", (event) => {
  if (!canUseGameKeyboard(event)) return;
  if (keyBindings[event.code]) { input[keyBindings[event.code]] = true; event.preventDefault(); }
  if (event.code === "Space") { send({ type: "fire" }); event.preventDefault(); }
});
window.addEventListener("keyup", (event) => {
  if (!canUseGameKeyboard(event)) return;
  if (keyBindings[event.code]) { input[keyBindings[event.code]] = false; event.preventDefault(); }
});
canvas.addEventListener("mousemove", updateAim); canvas.addEventListener("mousedown", (event) => { updateAim(event); send({ type: "fire" }); });
setInterval(() => { if (!gameArea.hidden) send({ type: "input", input }); }, 50);
createButton.addEventListener("click", () => join(true)); joinButton.addEventListener("click", () => join(false)); roomInput.addEventListener("input", () => { roomInput.value = roomInput.value.toUpperCase().replace(/[^A-Z2-9]/g, ""); });
document.querySelector("#leave-room").addEventListener("click", () => window.location.reload());
createButton.disabled = true; joinButton.disabled = true; connect(); draw();
