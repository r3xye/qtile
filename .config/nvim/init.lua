-- Main Neovim configuration file
local config_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
package.path = table.concat({
  config_root .. "/lua/?.lua",
  config_root .. "/lua/?/init.lua",
  package.path,
}, ";")

vim.g.mapleader = " "

-- Settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.cursorline = true
vim.opt.guicursor = "n-v-c:block,i-ci-ve:block,r-cr-o:block"
vim.opt.list = false
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 300
vim.opt.timeoutlen = 300
vim.opt.laststatus = 3

-- Load plugins via lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  change_detection = {
    notify = false,
  },
      git = {
          timeout=300
      },
})

-- Load configurations
require("config.lsp")
require("config.cmp")
require("config.telescope")
require("config.neotree")
require("config.lualine")
require("config.bufferline")
require("config.gitsigns")
require("config.dap")
require("config.autopairs")
require("config.indent")
require("config.winshift")
require("config.whichkey")
require("config.surround")
require("config.themes")
require("config.terminal").setup()
require("config.keymaps")
require("config.typst")
