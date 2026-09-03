require("neo-tree").setup({
  close_if_last_window = true,
  popup_border_style = "rounded",
  enable_git_status = true,
  enable_diagnostics = true,
  sort_case_insensitive = true,
  filesystem = {
    filtered_items = {
      visible = true,
      hide_hidden = false,
      hide_dotfiles = false,
      hide_gitignored = false,
    },
  },
  window = {
    mappings = {
      ["-"] = "navigate_up",
      ["<bs>"] = "navigate_up",
    },
  },
})

local function is_valid_win(win)
  return win and vim.api.nvim_win_is_valid(win)
end

local function is_neotree_win(win)
  return is_valid_win(win) and vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree"
end

local function find_neotree_win()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_neotree_win(win) then
      return win
    end
  end
  return nil
end

local function find_first_normal_win()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_valid_win(win) and not is_neotree_win(win) then
      return win
    end
  end
  return nil
end

local function toggle_neotree_focus()
  local current = vim.api.nvim_get_current_win()
  local neotree_win = find_neotree_win()
  if not neotree_win then
    return
  end

  if is_neotree_win(current) then
    local target = vim.t.neotree_last_win
    if not is_valid_win(target) or is_neotree_win(target) then
      target = find_first_normal_win()
    end
    if target and target ~= current then
      vim.api.nvim_set_current_win(target)
    end
    return
  end

  vim.t.neotree_last_win = current
  vim.api.nvim_set_current_win(neotree_win)
end

vim.api.nvim_create_autocmd("WinEnter", {
  callback = function()
    local current = vim.api.nvim_get_current_win()
    if not is_neotree_win(current) then
      vim.t.neotree_last_win = current
    end
  end,
})

vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Toggle Neotree" })
vim.keymap.set("n", "<Tab>", toggle_neotree_focus, { desc = "Toggle focus with Neotree", silent = true })
