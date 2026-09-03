local theme_groups = {
  dark = {
    "gruvbox-material",
    "gruvbox",
    "tokyonight",
    "catppuccin-mocha",
    "onedark",
    "nightfox",
    "kanagawa",
    "dracula",
    "everforest",
    "ayu-dark",
    "github_dark",
    "nord",
    "rose-pine",
    "material",
    "sonokai",
    "nightfly",
    "oxocarbon",
    "vscode",
    "melange",
    "solarized",
  },
  light = {
    "catppuccin-latte",
    "dayfox",
    "dawnfox",
    "ayu-light",
    "github_light",
    "rose-pine-dawn",
    "edge",
    "PaperColor",
  },
}

local themes = {}
for _, group in ipairs({ "dark", "light" }) do
  vim.list_extend(themes, theme_groups[group])
end

local theme_state_file = vim.fn.stdpath("state") .. "/theme.txt"
local default_theme = "gruvbox-material"
local current_theme_index = 1
local light_themes = {}
for _, name in ipairs(theme_groups.light) do
  light_themes[name] = true
end

for i, name in ipairs(themes) do
  if name == default_theme then
    current_theme_index = i
    break
  end
end

local function read_saved_theme()
  local f = io.open(theme_state_file, "r")
  if not f then
    return nil
  end
  local name = f:read("*l")
  f:close()
  if name and name ~= "" then
    return name
  end
  return nil
end

local function save_theme(name)
  local f = io.open(theme_state_file, "w")
  if not f then
    return
  end
  f:write(name)
  f:close()
end

local function theme_background(name)
  if light_themes[name] then
    return "light"
  end
  return "dark"
end

function SetTheme(name)
  local previous_background = vim.o.background
  vim.o.background = theme_background(name)
  local ok = pcall(vim.cmd.colorscheme, name)
  if ok then
    save_theme(name)
    vim.schedule(function()
      local ok_snacks, snacks = pcall(require, "snacks")
      if ok_snacks and snacks.dashboard then
        snacks.dashboard.update()
      end
    end)
    return true
  end
  vim.o.background = previous_background
  return false
end

local function picker_results()
  local results = {
    { kind = "header", label = "Dark themes" },
  }

  for _, name in ipairs(theme_groups.dark) do
    results[#results + 1] = { kind = "theme", name = name }
  end

  results[#results + 1] = { kind = "header", label = "Light themes" }

  for _, name in ipairs(theme_groups.light) do
    results[#results + 1] = { kind = "theme", name = name }
  end

  return results
end

-- Function to select theme with Telescope
function SelectTheme()
  local telescope = require("telescope")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local entries = picker_results()

  pickers.new({}, {
    prompt_title = "Select Theme",
    finder = finders.new_table({
      results = entries,
      entry_maker = function(item)
        local is_header = item.kind == "header"
        return {
          value = item,
          ordinal = is_header and item.label or item.name,
          display = is_header and ("[" .. item.label .. "]") or ("  " .. item.name),
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        if not selection or selection.value.kind ~= "theme" then
          return
        end

        actions.close(prompt_bufnr)
        if SetTheme(selection.value.name) then
          print("Theme: " .. selection.value.name)
        end
      end)
      return true
    end,
  }):find()
end

-- Keymap to select theme
vim.keymap.set("n", "<leader>t", SelectTheme, { desc = "Theme select" })

-- Set initial theme (restore saved theme if available)
local saved_theme = read_saved_theme()
if saved_theme then
  for i, name in ipairs(themes) do
    if name == saved_theme then
      current_theme_index = i
      break
    end
  end
  if not SetTheme(saved_theme) then
    SetTheme(themes[current_theme_index])
  end
else
  SetTheme(themes[current_theme_index])
end
