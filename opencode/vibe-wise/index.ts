// VibeWise plugin entry for OpenCode V2.
//
// Copied to ~/.config/opencode/plugins/vibe-wise/index.ts by auto_config.sh, not
// symlinked from here the way ponytail-plugin.js is. Bun resolves a module's
// imports from its realpath, so a symlink would make the relative import below
// resolve against the dotfiles checkout, where there is no vibe-wise/ sibling.
// A copy lands in the real config dir, where ../../vibe-wise/ is the bundle that
// auto_config.sh clones.
//
// The import is type-only in the adapter (bridge.mjs uses node: builtins), so
// there is no runtime dependency to install here — no @opencode/plugin, no npm.

import { makeSetup } from "../../vibe-wise/adapters/opencode-v2/setup.ts";

export default { id: "vibe-wise", setup: makeSetup() };
