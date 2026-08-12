-- nvim/lsp/json/jsonls.lua

-- NOTE: npm i -g vscode-langservers-extracted

return {
	cmd = { "vscode-json-language-server", "--stdio" },
	filetypes = { "json", "jsonc" },
	settings = {
		json = {
			validate = { enable = true },
		},
	},
}
