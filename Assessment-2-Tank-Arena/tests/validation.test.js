import test from "node:test";
import assert from "node:assert/strict";
import { parseClientMessage } from "../server/validation.js";

test("rejects malformed and unknown network messages", () => {
  assert.equal(parseClientMessage("not json").ok, false);
  assert.equal(parseClientMessage('{"type":"teleport","x":99}').ok, false);
  assert.equal(parseClientMessage('{"type":"joinRoom","name":"<img>","roomCode":"ABCD"}').ok, false);
});
test("only accepts bounded input state with finite aim", () => {
  const good = '{"type":"input","input":{"up":true,"down":false,"left":false,"right":false,"aimAngle":1}}';
  assert.equal(parseClientMessage(good).ok, true);
  const bad = '{"type":"input","input":{"up":true,"down":false,"left":false,"right":false,"aimAngle":"Infinity"}}';
  assert.equal(parseClientMessage(bad).ok, false);
});
