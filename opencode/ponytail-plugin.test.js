// Self-check for the ponytail V2 shim. Run: node --test
//
// Guards the parts that broke silently before: the folded (`>`) skill
// frontmatter, the transform/hook registration, and mode persistence.

import { test } from "node:test"
import assert from "node:assert/strict"
import fs from "node:fs"
import os from "node:os"
import path from "node:path"

const SHIM = new URL("./ponytail-plugin.js", import.meta.url)

// Capture the shim's mode state file so a run never leaves a level behind.
const statePath = path.join(
  process.env.XDG_CONFIG_HOME || path.join(os.homedir(), ".config"),
  "opencode",
  ".ponytail-active",
)
const stateExisted = fs.existsSync(statePath)
const stateBefore = stateExisted ? fs.readFileSync(statePath, "utf8") : null
process.on("exit", () => {
  try {
    if (stateExisted) fs.writeFileSync(statePath, stateBefore)
    else fs.rmSync(statePath, { force: true })
  } catch {}
})

const { default: plugin } = await import(SHIM.href)

// Drive setup() against a recording stub of the V2 context.
async function setupV2() {
  const skills = []
  const commands = []
  const hooks = {}
  const prompts = []
  await plugin.setup({
    skill: { transform: async (fn) => fn({ add: (s) => skills.push(s) }) },
    command: { transform: async (fn) => fn({ add: (c) => commands.push(c) }) },
    session: {
      hook: async (name, fn) => {
        hooks[name] = fn
      },
      prompt: async (input) => {
        prompts.push(input)
      },
    },
  })
  return { skills, commands, hooks, prompts }
}

test("exports one default with id and setup, and no V1 server()", () => {
  assert.equal(plugin.id, "ponytail")
  assert.equal(typeof plugin.setup, "function")
  assert.equal(plugin.server, undefined, "V1 server() should be gone")
})

test("registers all six skills with unfolded descriptions", async () => {
  const { skills } = await setupV2()
  const ids = skills.map((s) => s.id).sort()
  assert.deepEqual(ids, [
    "ponytail",
    "ponytail-audit",
    "ponytail-debt",
    "ponytail-gain",
    "ponytail-help",
    "ponytail-review",
  ])
  for (const skill of skills) {
    // A folded description that was not unfolded would start with ">".
    assert.ok(skill.description, `${skill.id} needs a description`)
    assert.ok(!skill.description.startsWith(">"), `${skill.id} description is still folded`)
    assert.ok(skill.description.length > 100, `${skill.id} description looks truncated`)
    // Frontmatter must be stripped from the body.
    assert.ok(!skill.content.startsWith("---"), `${skill.id} content kept its frontmatter`)
    assert.ok(fs.existsSync(skill.path), `${skill.id} path does not exist`)
  }
})

test("registers all six commands and both request hooks", async () => {
  const { commands, hooks } = await setupV2()
  assert.equal(commands.length, 6)
  assert.ok(commands.some((c) => c.name === "ponytail"))
  // Registering only "context" would drop the ruleset on compaction.
  assert.ok(hooks.context, "context hook missing")
  assert.ok(hooks.compaction, "compaction hook missing")
})

test("system injection pushes a part and leaves the existing system intact", async () => {
  const { hooks, commands } = await setupV2()
  fs.writeFileSync(statePath, "full")
  const event = { system: [{ type: "text", text: "base" }] }
  hooks.context(event)
  assert.equal(event.system.length, 2)
  assert.equal(event.system[0].text, "base")
  assert.match(event.system[1].text, /PONYTAIL MODE ACTIVE — level: full/)
  assert.equal(event.system[1].type, "text")
  void commands
})

test("/ponytail persists the level and substitutes $ARGUMENTS", async () => {
  const { commands, hooks, prompts } = await setupV2()
  const ponytail = commands.find((c) => c.name === "ponytail")
  await ponytail.execute({ sessionID: "ses_x", prompt: { text: "lite" }, delivery: "steer" })
  assert.equal(fs.readFileSync(statePath, "utf8"), "lite")

  const event = { system: [] }
  hooks.context(event)
  assert.match(event.system[0].text, /level: lite/)
  assert.equal(prompts.length, 1)
  assert.match(prompts[0].text, /^Switch to ponytail lite mode\./)
  assert.equal(prompts[0].sessionID, "ses_x")
  assert.equal(prompts[0].delivery, "steer")
})

test("off suppresses injection; a bogus level leaves the current one alone", async () => {
  const { commands, hooks } = await setupV2()
  const ponytail = commands.find((c) => c.name === "ponytail")
  await ponytail.execute({ sessionID: "ses_x", prompt: { text: "off" }, delivery: "steer" })
  const off = { system: [] }
  hooks.context(off)
  assert.equal(off.system.length, 0, "off should inject nothing")

  await ponytail.execute({ sessionID: "ses_x", prompt: { text: "not-a-level" }, delivery: "steer" })
  const stillOff = { system: [] }
  hooks.context(stillOff)
  assert.equal(stillOff.system.length, 0, "a bogus level should not change the mode")
})
