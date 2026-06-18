vim.pack.add({
	"https://github.com/yorickpeterse/nvim-jump",
})

require("jump").setup()

-- stylua: ignore start
for _, key in ipairs({ "s", "f", "t" }) do
  vim.keymap.set({ "n", "x", "o" }, key, require("jump").start)
end
-- stylua: ignore end
