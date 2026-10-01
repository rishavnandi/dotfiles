// ponytail — V2 plugin shim.
//
// Why this exists: @dietrichgebert/ponytail 4.10.0 still default-exports a V1
// plugin function. This loader requires the default export to be an object with
// `id` and `setup` (or `effect`) — see the loader schema in
// packages/core/src/config/plugin/external.ts — and rejects a function with:
//
//   Plugin must export a default definition with an id and an effect or setup
//   function.  (cause: SchemaError(Expected object at ["default"]))
//
// Upstream PRs are unmerged, so this wraps the package until a release ships a
// V2 entrypoint. Watch DietrichGebert/ponytail#962 ("feat: add OpenCode V2
// plugin support") — it rewrites this same entrypoint as
// `{ id, setup(ctx) }` against the V2 plugin API, which is what makes this
// file deletable. #946 ("feat: add V2 plugin entrypoint") adds a separate
// .v2.mjs file instead and needs a package.json exports change to help.
//
// Delete this file and add "@dietrichgebert/ponytail" to the config's
// `plugins` list once that release lands.

import fs from "fs"
import os from "os"
import path from "path"
import { createRequire } from "module"
import { fileURLToPath } from "url"

const require = createRequire(import.meta.url)
const __dirname = path.dirname(fileURLToPath(import.meta.url))

// This file is tracked in dotfiles and symlinked into the opencode config
// directory, but node resolves modules from a file's realpath — which is the
// dotfiles checkout, not the config dir where node_modules lives. So resolve
// the package against the config dir explicitly instead of relying on an
// ancestor node_modules.
//
// Also deliberately not a hardcoded cache path: opencode installs plugins
// under a timestamped directory (~/.cache/opencode/npm/<pkg>@latest/<n>/...),
// which changes on every reinstall. The package is a real dependency of the
// config dir, so its path is stable.
const configDir =
  process.env.OPENCODE_CONFIG_DIR ||
  path.join(process.env.XDG_CONFIG_HOME || path.join(os.homedir(), ".config"), "opencode")

// If this throws, the module fails to import and the plugin does not load at
// all — which is the same visible failure as the bug this shim exists to fix,
// but with a message that actually says what to do. Keep it as a throw with a
// fix hint rather than a silent fallback to a half-working path.
function resolvePkg() {
  try {
    return require.resolve("@dietrichgebert/ponytail", { paths: [configDir] })
  } catch (err) {
    try {
      return require.resolve("@dietrichgebert/ponytail")
    } catch {
      throw new Error(
        `ponytail-shim: cannot resolve @dietrichgebert/ponytail from ${configDir}. ` +
          `Run \`bun add @dietrichgebert/ponytail\` in that directory. (${err.message})`,
      )
    }
  }
}

const pkgEntry = resolvePkg()
// package.json `main` is ./.opencode/plugins/ponytail.mjs
const pkgRoot = path.resolve(path.dirname(pkgEntry), "..", "..")

const { getPonytailInstructions } = require(path.join(pkgRoot, "hooks/ponytail-instructions"))
const { getDefaultMode, normalizePersistedMode } = require(path.join(pkgRoot, "hooks/ponytail-config"))

const skillsDir = path.join(pkgRoot, "skills")
const commandDir = path.join(pkgRoot, ".opencode", "command")

const statePath = path.join(
  process.env.XDG_CONFIG_HOME || path.join(os.homedir(), ".config"),
  "opencode",
  ".ponytail-active",
)

function readMode() {
  try {
    return normalizePersistedMode(fs.readFileSync(statePath, "utf8").trim()) || getDefaultMode()
  } catch {
    return getDefaultMode()
  }
}

function writeMode(mode) {
  fs.mkdirSync(path.dirname(statePath), { recursive: true })
  fs.writeFileSync(statePath, mode)
}

// `off` persists like any other mode; the injection reads it and stays silent.
// An unrecognized level leaves the current one alone. The write lands before
// the next turn's injection, not the current one.
function persistMode(args) {
  const wanted = String(args == null ? "" : args).trim()
  const mode = wanted ? normalizePersistedMode(wanted) : getDefaultMode()
  if (!mode) return
  writeMode(mode)
}

function readCommands() {
  try {
    return fs
      .readdirSync(commandDir)
      .filter((file) => file.endsWith(".md"))
      .map((file) => {
        const content = fs.readFileSync(path.join(commandDir, file), "utf8")
        // Tolerate CRLF: a Windows checkout delivers \r\n, npm ships \n.
        const match = content.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n([\s\S]*)$/)
        if (!match) return null
        return {
          name: path.basename(file, ".md"),
          description: match[1].match(/description:\s*(.+)/)?.[1]?.trim(),
          template: match[2].trim(),
        }
      })
      .filter(Boolean)
  } catch {
    return []
  }
}

// The package ships parseCommandFile but no skill equivalent, and its skill
// frontmatter uses folded (`>`) multi-line descriptions that a single-line
// regex would truncate to ">". Unfold those: YAML joins folded lines with a
// space, with a blank line becoming a newline.
function parseSkill(file) {
  const content = fs.readFileSync(file, "utf8")
  const match = content.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n([\s\S]*)$/)
  if (!match) return null

  const lines = match[1].split(/\r?\n/)
  const fields = {}
  for (let i = 0; i < lines.length; i++) {
    const key = lines[i].match(/^([A-Za-z0-9_-]+):\s*(.*)$/)
    if (!key) continue
    if (key[2].trim() === ">") {
      const parts = []
      for (let j = i + 1; j < lines.length; j++) {
        if (!/^\s+\S/.test(lines[j])) break
        parts.push(lines[j].trim())
      }
      fields[key[1]] = parts.join(" ").trim()
      i = lines.length
    } else {
      fields[key[1]] = key[2].trim().replace(/^["']|["']$/g, "")
    }
  }

  return { name: fields.name, description: fields.description, body: match[2].trim() }
}

function readSkills() {
  try {
    return fs
      .readdirSync(skillsDir, { withFileTypes: true })
      .filter((entry) => entry.isDirectory())
      .map((entry) => {
        const file = path.join(skillsDir, entry.name, "SKILL.md")
        if (!fs.existsSync(file)) return null
        const parsed = parseSkill(file)
        // V2 selects a skill by path-derived ID, not by frontmatter name.
        return parsed && { id: entry.name, name: parsed.name || entry.name, ...parsed, file }
      })
      .filter(Boolean)
  } catch {
    return []
  }
}

export default {
  id: "ponytail",

  async setup(ctx) {
    const commands = readCommands()
    const skills = readSkills()

    await ctx.skill.transform((editor) => {
      for (const skill of skills) {
        editor.add({
          id: skill.id,
          name: skill.name,
          description: skill.description,
          path: skill.file,
          content: skill.body,
        })
      }
    })

    await ctx.command.transform((editor) => {
      for (const command of commands) {
        editor.add({
          name: command.name,
          description: command.description,
          execute: async ({ sessionID, prompt, delivery }) => {
            // V2 has no global command.execute.before hook, so the plugin's own
            // command persists the level before it prompts.
            if (command.name === "ponytail") persistMode(prompt.text)
            await ctx.session.prompt({
              ...prompt,
              sessionID,
              text: command.template.replaceAll("$ARGUMENTS", prompt.text || ""),
              delivery,
            })
          },
        })
      }
    })

    // V2 hands over owned system parts, so push one instead of rewriting the
    // tail of another. Register every model-request kind that carries the
    // agent's instructions, or the ruleset disappears on compaction.
    const inject = (event) => {
      const mode = readMode()
      if (mode === "off") return
      event.system.push({ type: "text", text: getPonytailInstructions(mode) })
    }
    await ctx.session.hook("context", inject)
    await ctx.session.hook("compaction", inject)
  },
}
