-- Matte Black — the colorscheme Omarchy uses for its matte-black theme.
-- Upstream: https://github.com/tahayvr/matteblack.nvim
--
-- Upstream is a deliberately *matte* dark grey (background #121212), not AMOLED.
-- The config block below crushes only the background shades to pure black so
-- Neovim matches theme/matte_black.yaml in Warp. Delete that block to go back to
-- upstream's #121212.
--
-- apply() reads palette at call time, so mutating it here is enough — LazyVim
-- applies the colorscheme after plugins load. If the background does not change,
-- re-run ':colorscheme matteblack' once.
return {
  {
    "tahayvr/matteblack.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local p = require("matteblack.colors").palette
      p.bg1 = "#000000" -- Normal background, terminal background
      p.bg3 = "#0D0D0D" -- cursorline, floats, statusline
      p.bg4 = "#1A1A1A" -- highlighted line, matchparen
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "matteblack",
    },
  },
}
