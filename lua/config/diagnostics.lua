-- lua/config/diagnostics.lua
--
-- Controls how LSP/linter errors and warnings are shown.
-- This does not depend on any plugin, so load it once at startup, e.g. add
--   require("config.diagnostics")
-- to lua/config/init.lua (or just paste this block in there directly).

vim.diagnostic.config({
  -- Gutter signs (on by default) — customize the icons.
  -- These glyphs need a Nerd Font, which you already install via fonts.sh.
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.INFO]  = "",
      [vim.diagnostic.severity.HINT]  = "󰌵",
    },
  },

  -- Underline the offending text (on by default; here for explicitness).
  underline = true,

  -- Inline message at the end of the line.
  -- As of Neovim 0.11 this handler is OFF by default — this turns it back on.
  virtual_text = {
    prefix = "●",
    spacing = 2,
    source = "if_many", -- show the reporting tool only when a line has >1 source
  },

  -- Alternative to virtual_text: a full-width message on its own line below the
  -- code, which is far easier to read for long messages. To use it, comment out
  -- the whole `virtual_text` block above and uncomment the next line:
  -- virtual_lines = { current_line = true },

  severity_sort = true,     -- draw errors above warnings on the same line
  update_in_insert = false, -- don't recompute diagnostics on every keystroke

  float = {
    border = "rounded",
    source = true,          -- always show which tool reported it in the popup
  },
})

-- Keymaps
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics (float)" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to location list" })
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev diagnostic" })
