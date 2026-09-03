require("which-key").setup({
  notify = false,
  plugins = {
    marks = false,
    registers = false,
    spelling = {
      enabled = false,
      suggestions = 20,
    },
    presets = {
      operators = false,
      motions = false,
      text_objects = false,
      windows = false,
      nav = false,
      z = false,
      g = false,
    },
  },
  icons = {
    breadcrumb = "»",
    separator = "➜",
    group = "+",
  },
  keys = {
    scroll_down = "<c-d>",
    scroll_up = "<c-u>",
  },
  win = {
    border = "rounded",
    padding = { 2, 2 },
    wo = {
      winblend = 0,
    },
  },
  layout = {
    width = { min = 20, max = 50 },
    spacing = 3,
  },
  show_help = false,
  triggers = {
    { "<leader>", mode = { "n", "v" } },
  },
})

-- Register keymaps
local wk = require("which-key")
wk.register({
  ["<leader>,"] = "Previous buffer",
  ["<leader>."] = "Next buffer",
  ["<leader>R"] = "Run in floating terminal",
  ["<leader>b"] = { name = "Buffer" },
  ["<leader>d"] = { name = "Debug" },
  ["<leader>e"] = "Explorer",
  ["<leader>f"] = { name = "File" },
  ["<leader>g"] = { name = "Git" },
  ["<leader>h"] = { name = "Hunk" },
  ["<leader>l"] = { name = "LSP" },
  ["<leader>q"] = "Dashboard",
  ["<leader>r"] = "Run current file",
  ["<leader>s"] = "Stop current run",
  ["<leader>t"] = "Theme picker",
})
