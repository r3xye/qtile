require("bufferline").setup({
  options = {
    mode = "buffers",
    numbers = "none",
    close_command = "bdelete! %d",
    right_mouse_command = "bdelete! %d",
    left_mouse_command = "buffer %d",
    middle_mouse_command = nil,
    indicator = {
      style = "icon",
      icon = "▎",
    },
    buffer_close_icon = "",
    modified_icon = "●",
    close_icon = "",
    left_trunc_marker = "",
    right_trunc_marker = "",
    max_name_length = 24,
    max_prefix_length = 18,
    tab_size = 22,
    diagnostics = "nvim_lsp",
    diagnostics_indicator = function(_, _, diag)
      local parts = {}
      if diag.error then
        table.insert(parts, " " .. diag.error)
      end
      if diag.warning then
        table.insert(parts, " " .. diag.warning)
      end
      return table.concat(parts, " ")
    end,
    show_buffer_icons = true,
    show_buffer_close_icons = false,
    show_close_icon = false,
    show_tab_indicators = true,
    persist_buffer_sort = true,
    separator_style = { "┆", "┆" },
    enforce_regular_tabs = true,
    always_show_bufferline = true,
    hover = {
      enabled = true,
      delay = 120,
      reveal = { "close" },
    },
    offsets = {
      {
        filetype = "neo-tree",
        text = "File Explorer",
        highlight = "Directory",
        text_align = "left",
        separator = false,
      },
    },
  },
})

-- Keymaps for buffers
vim.keymap.set("n", "<leader>bn", "<cmd>enew<cr>", { desc = "New buffer" })
vim.keymap.set("n", "<leader>.", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>,", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer" })

local function close_current_buffer()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].modified then
    vim.cmd("write")
  end
  vim.api.nvim_buf_delete(buf, { force = false })
end

vim.keymap.set("n", "<leader>bd", close_current_buffer, { desc = "Close buffer" })

local function close_other_buffers()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.bo[buf].buflisted then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end

vim.keymap.set("n", "<leader>bo", close_other_buffers, { desc = "Close other buffers" })
