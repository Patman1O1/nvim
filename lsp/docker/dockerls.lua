-- nvim/lsp/docker/dockerls.lua

return {
	cmd = { "docker-langserver", "--stdio" },
	filetypes = { "dockerfile" },
	root_markers = { ".git" },
}
