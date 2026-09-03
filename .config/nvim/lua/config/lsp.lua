require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "pyright", "lua_ls", "ruff", "tinymist", "clangd" },
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local python = require("config.python")

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Python LSP
vim.lsp.config("pyright", {
  capabilities = capabilities,
  before_init = function(_, config)
    local root = config.root_dir or python.get_project_root(0)
    local python_path = python.get_python({ root = root })
    local venv_dir = python.get_venv_dir({ root = root })

    config.settings = config.settings or {}
    config.settings.python = config.settings.python or {}

    if python_path then
      config.settings.python.pythonPath = python_path
    end

    if venv_dir then
      config.settings.python.venvPath = vim.fs.dirname(venv_dir)
      config.settings.python.venv = vim.fs.basename(venv_dir)
    end
  end,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        diagnosticMode = "openFilesOnly",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticSeverityOverrides = {
          reportMissingImports = "none",
          reportMissingTypeStubs = "none",
        },
      },
      completion = {
        completeFunctionParens = true,
      },
    },
  },
})

-- Lua LSP
vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
    },
  },
})

-- Ruff LSP (Python linting/formatting)
vim.lsp.config("ruff", {
  capabilities = capabilities,
})

-- Typst LSP (Tinymist)
vim.lsp.config("tinymist", {
  capabilities = capabilities,
})

-- C/C++ LSP (clangd)
vim.lsp.config("clangd", {
  capabilities = capabilities,
})

vim.lsp.enable("pyright")
vim.lsp.enable("lua_ls")
vim.lsp.enable("ruff")
vim.lsp.enable("tinymist")
vim.lsp.enable("clangd")

-- Keymaps for LSP
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "LSP code action" })
vim.keymap.set("n", "<leader>lf", function() vim.lsp.buf.format { async = true } end, { desc = "LSP format" })
