return {
  -- Plugin manager
  "folke/lazy.nvim",

  -- Themes
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },
  "folke/tokyonight.nvim",
  "ellisonleao/gruvbox.nvim",
  "navarasu/onedark.nvim",
  "EdenEast/nightfox.nvim",
  "rebelot/kanagawa.nvim",
  "Mofiqul/dracula.nvim",
  "sainnhe/everforest",
  "sainnhe/gruvbox-material",
  "Shatur/neovim-ayu",
  "marko-cerovac/material.nvim",
  "projekt0n/github-nvim-theme",
  "shaunsingh/nord.nvim",
  "rose-pine/neovim",
  "sainnhe/sonokai",
  "bluz71/vim-nightfly-colors",
  "nyoom-engineering/oxocarbon.nvim",
  "Mofiqul/vscode.nvim",
  "savq/melange-nvim",
  "sainnhe/edge",
  "maxmx03/solarized.nvim",
  "NLKNguyen/papercolor-theme",

  -- Dashboard / UI goodies
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = function()
      return require("config.snacks")
    end,
  },

  -- LSP
  "neovim/nvim-lspconfig",
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",

  -- Autocompletion
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",

  -- Telescope for searching
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Neotree for file tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
  },

  -- Status bar
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Buffers
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Git integration
  "lewis6991/gitsigns.nvim",

  -- Debugger
  "mfussenegger/nvim-dap",
  "mfussenegger/nvim-dap-python",

  -- Comments
  {
    "numToStr/Comment.nvim",
    config = function()
      require("config.comment").setup()
    end,
  },

  -- Auto pairs
  "windwp/nvim-autopairs",

  -- Indent guides
  "lukas-reineke/indent-blankline.nvim",

  -- Swap windows
  "sindrets/winshift.nvim",

  -- Which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
  },

  -- Surround
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
  },
}
