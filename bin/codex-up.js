#!/usr/bin/env node

const { spawnSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const scriptPath = path.resolve(__dirname, "..", "install.sh");

if (!fs.existsSync(scriptPath)) {
  console.error("codex-up: install.sh is missing beside the npm package.");
  process.exit(1);
}

const args = process.argv.slice(2);
const result = spawnSync("bash", [scriptPath, ...args], {
  stdio: "inherit",
  cwd: path.dirname(scriptPath),
  env: process.env,
});

if (result.error) {
  console.error(`codex-up: ${result.error.message}`);
  process.exit(result.status ?? 1);
}

if (result.signal) {
  process.kill(process.pid, result.signal);
}

process.exit(result.status ?? 0);
