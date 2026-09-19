return {
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        on_dir(vim.fs.root(fname, { "Cargo.toml", "rust-project.json" }))
    end,
    settings = {
        ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            check = { command = "clippy" },
        },
    },
}
