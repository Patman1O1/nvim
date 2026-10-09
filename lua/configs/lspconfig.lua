local M = {}

-- Servers not installed through Mason (no prebuilt binary for this platform).
M.external = {
    clangd = true, -- Mason has no aarch64-linux build; use the system package
}

-- Treesitter parsers wanted per server.
M.parsers = {
    -- C/C++
    clangd = { "c", "cpp" },

    -- CSS
    cssls = { "css", "scss" },

    -- HTML
    html = { "html" },

    -- Java
    jdtls = { "java" },

    -- Lua
    lua_ls = { "lua", "luadoc" },

    -- Python
    pyright = { "python" },

    -- Rust
    rust_analyzer = { "rust", "toml" },

    -- TypeScript/JavaScript
    ts_ls = { "javascript", "typescript", "tsx", "jsdoc" },
}
--- Every lua/configs/lsp/*.lua is one server's config table.
---@return string[] lspconfig server names, sorted
function M.servers()
    local names, seen = {}, { init = true }
    for _, path in ipairs(vim.api.nvim_get_runtime_file("lua/configs/lsp/*.lua", true)) do
        local name = vim.fn.fnamemodify(path, ":t:r")
        if not seen[name] then
            seen[name] = true
            names[#names + 1] = name
        end
    end
    table.sort(names)
    return names
end

--- lspconfig names for mason-lspconfig's ensure_installed.
function M.mason_servers()
    return vim.tbl_filter(function(server)
        return not M.external[server]
    end, M.servers())
end

--- Parsers for nvim-treesitter's ensure_installed.
function M.ts_parsers()
    local out, seen = {}, {}
    for _, server in ipairs(M.servers()) do
        for _, lang in ipairs(M.parsers[server] or {}) do
            if not seen[lang] then
                seen[lang] = true
                out[#out + 1] = lang
            end
        end
    end
    return out
end

function M.setup()
    require("nvchad.configs.lspconfig").defaults()

    local servers = M.servers()
    for _, server in ipairs(servers) do
        vim.lsp.config(server, require("configs.lsp." .. server))
    end
    vim.lsp.enable(servers)
end

return M
