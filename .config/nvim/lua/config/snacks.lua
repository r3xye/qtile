local file_presets = {
  py = {
    ext = "py",
    ft = "python",
    label = "Python (.py)",
    cursor = { 2, 4 },
    lines = {
      'def main() -> None:',
      "    ",
      "    pass",
      "",
      'if __name__ == "__main__":',
      "    main()",
    },
  },
  cpp = {
    ext = "cpp",
    ft = "cpp",
    label = "C++ (.cpp)",
    cursor = { 4, 4 },
    lines = {
      "#include <iostream>",
      "",
      "int main() {",
      "",
      "    return 0;",
      "}",
    },
  },
  typst = {
    ext = "typst",
    ft = "typst",
    label = "Typst (.typst)",
    cursor = { 6, 0 },
    lines = {
      "#set page(margin: 1cm)",
      '#set text(font: "Libertinus Serif", size: 12pt)',
      "",
      "= Title",
      "",
      "Your text here.",
    },
  },
}

local extension_aliases = {
  typ = "typst",
}

local function canonical_extension(ext)
  if not ext or ext == "" then
    return nil
  end
  ext = ext:gsub("^%.*", ""):lower()
  return extension_aliases[ext] or ext
end

local function resolve_preset(ext)
  local key = canonical_extension(ext)
  return key and file_presets[key] or nil
end

local function make_unique_name(extension)
  local stamp = os.date("%Y%m%d-%H%M%S")
  return ("untitled-%s.%s"):format(stamp, extension)
end

local function populate_new_buffer(name, preset)
  vim.cmd("enew")
  vim.cmd("file " .. vim.fn.fnameescape(name))

  if preset then
    vim.bo.filetype = preset.ft
    vim.api.nvim_buf_set_lines(0, 0, -1, false, preset.lines)
    vim.api.nvim_win_set_cursor(0, preset.cursor)
    return
  end

  local detected = vim.filetype.match({ filename = name })
  if detected then
    vim.bo.filetype = detected
  end
end

local function open_existing_buffer_or_edit(path)
  local bufnr = vim.fn.bufnr(path)
  if bufnr > 0 and vim.api.nvim_buf_is_valid(bufnr) then
    vim.cmd("buffer " .. bufnr)
    return true
  end

  local ok, err = pcall(vim.cmd, "e " .. vim.fn.fnameescape(path))
  if not ok then
    vim.notify(tostring(err), vim.log.levels.WARN)
    return false
  end
  return true
end

local function create_new_file(name)
  local trimmed = vim.trim(name or "")
  if trimmed == "" then
    return false
  end

  local filename = trimmed
  local preset

  if trimmed:match("^%.[%w_-]+$") then
    preset = resolve_preset(trimmed)
    local ext = canonical_extension(trimmed)
    filename = make_unique_name(ext)
  else
    preset = resolve_preset(vim.fn.fnamemodify(trimmed, ":e"))
  end

  populate_new_buffer(filename, preset)
  return true
end

local function select_new_file_preset()
  local choices = {
    file_presets.py,
    file_presets.cpp,
    file_presets.typst,
  }

  vim.ui.select(choices, {
    prompt = "Create new file:",
    format_item = function(item)
      return item.label
    end,
  }, function(item)
    if not item then
      return
    end

    populate_new_buffer(make_unique_name(item.ext), item)
  end)
end

local function ensure_dashboard_new_file_command()
  if vim.fn.exists(":DashboardNewFile") == 2 then
    return
  end

  vim.api.nvim_create_user_command("DashboardNewFile", function()
    vim.ui.input({
      prompt = "File name or extension (.py, .cpp, .typst): ",
    }, function(input)
      if input == nil then
        return
      end

      if vim.trim(input) == "" then
        select_new_file_preset()
        return
      end

      if not create_new_file(input) then
        vim.notify("Could not create file from input: " .. input, vim.log.levels.WARN)
      end
    end)
  end, {})
end

local function dashboard_palette()
  local theme = vim.g.colors_name or ""
  local palettes = {
    ["gruvbox-material"] = {
      header = "#d8a657",
      desc = "#ddc7a1",
      icon = "#e78a4e",
      key = "#ea6962",
      special = "#7daea3",
      footer = "#a9b665",
    },
    gruvbox = {
      header = "#fabd2f",
      desc = "#ebdbb2",
      icon = "#fe8019",
      key = "#fb4934",
      special = "#83a598",
      footer = "#8ec07c",
    },
    ["catppuccin-latte"] = {
      header = "#dc8a78",
      desc = "#4c4f69",
      icon = "#fe640b",
      key = "#d20f39",
      special = "#179299",
      footer = "#40a02b",
    },
    dayfox = {
      header = "#b26f16",
      desc = "#3d2b5a",
      icon = "#c46339",
      key = "#d03032",
      special = "#287980",
      footer = "#6f894e",
    },
    dawnfox = {
      header = "#b26f16",
      desc = "#4f4a45",
      icon = "#c46339",
      key = "#b3434e",
      special = "#2c6f77",
      footer = "#577f63",
    },
    ["ayu-light"] = {
      header = "#c17d11",
      desc = "#5c6773",
      icon = "#ff9940",
      key = "#f07171",
      special = "#399ee6",
      footer = "#86b300",
    },
    github_light = {
      header = "#9a6700",
      desc = "#24292f",
      icon = "#bc4c00",
      key = "#cf222e",
      special = "#0969da",
      footer = "#1a7f37",
    },
    ["rose-pine-dawn"] = {
      header = "#b4637a",
      desc = "#575279",
      icon = "#ea9d34",
      key = "#d7827e",
      special = "#56949f",
      footer = "#286983",
    },
    PaperColor = {
      header = "#af8700",
      desc = "#444444",
      icon = "#d75f00",
      key = "#d70000",
      special = "#0087af",
      footer = "#5f8700",
    },
    edge = {
      header = "#db8e3e",
      desc = "#4b505b",
      icon = "#e57c46",
      key = "#bf616a",
      special = "#5e81ac",
      footer = "#7cb66d",
    },
    solarized = {
      header = "#b58900",
      desc = "#586e75",
      icon = "#cb4b16",
      key = "#dc322f",
      special = "#268bd2",
      footer = "#859900",
    },
  }

  return palettes[theme] or {
    header = "#7aa2f7",
    desc = "#c0caf5",
    icon = "#ff9e64",
    key = "#f7768e",
    special = "#7dcfff",
    footer = "#9ece6a",
  }
end

local function setup_dashboard_highlights()
  local p = dashboard_palette()
  vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = p.header, bold = true })
  vim.api.nvim_set_hl(0, "SnacksDashboardDesc", { fg = p.desc })
  vim.api.nvim_set_hl(0, "SnacksDashboardIcon", { fg = p.icon })
  vim.api.nvim_set_hl(0, "SnacksDashboardKey", { fg = p.key, bold = true })
  vim.api.nvim_set_hl(0, "SnacksDashboardSpecial", { fg = p.special, italic = true })
  vim.api.nvim_set_hl(0, "SnacksDashboardFooter", { fg = p.footer, italic = true })
end

ensure_dashboard_new_file_command()

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    setup_dashboard_highlights()
    vim.schedule(function()
      local ok, snacks = pcall(require, "snacks")
      if ok and snacks.dashboard then
        snacks.dashboard.update()
      end
    end)
  end,
})
setup_dashboard_highlights()

local normalize_dir

local function dashboard_refresh()
  vim.cmd("redrawstatus")
  local ok, snacks = pcall(require, "snacks")
  if ok then
    snacks.dashboard.update()
  end
end

local function navigate_to_dir(dir)
  local target = normalize_dir(dir)
  vim.cmd("cd " .. vim.fn.fnameescape(target))
  dashboard_refresh()
end

local header = [[
██████╗ ██╗   ██╗██████╗  █████╗ ███╗   ███╗██╗   ██╗██████╗  █████╗
██╔══██╗██║   ██║██╔══██╗██╔══██╗████╗ ████║██║   ██║██╔══██╗██╔══██╗
██║  ██║██║   ██║██║  ██║██║  ██║██╔████╔██║██║   ██║██║  ██║██║  ██║
██████╔╝██║   ██║██████╔╝███████║██║╚██╔╝██║██║   ██║██████╔╝███████║
██╔═══╝ ██║   ██║██╔═══╝ ██╔══██║██║ ╚═╝ ██║██║   ██║██╔═══╝ ██╔══██║
██║     ╚██████╔╝██║     ██║  ██║██║     ██║╚██████╔╝██║     ██║  ██║
╚═╝      ╚═════╝ ╚═╝     ╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝     ╚═╝  ╚═╝
]]

local function in_git_repo()
  local ok, snacks = pcall(require, "snacks")
  return ok and snacks.git.get_root() ~= nil
end

local function discover_repo_dirs()
  local home = vim.loop.os_homedir()
  local roots = {
    home .. "/GitHub",
    home .. "/projects",
    home .. "/work",
    home .. "/code",
    home .. "/dev",
    home .. "/src",
  }

  local seen = {}
  local repos = {}
  for _, root in ipairs(roots) do
    if vim.fn.isdirectory(root) == 1 then
      local cmd = string.format(
        "find %q -mindepth 1 -maxdepth 5 -type d -name .git -prune 2>/dev/null | sed 's#/.git##'",
        root
      )
      local lines = vim.fn.systemlist({ "sh", "-c", cmd })
      for _, dir in ipairs(lines) do
        if dir ~= ""
            and not dir:match("/%.cache/")
            and not dir:match("/%.local/")
            and not dir:match("/node_modules/")
            and not seen[dir]
        then
          seen[dir] = true
          table.insert(repos, dir)
        end
      end
    end
  end

  return repos
end

normalize_dir = function(dir)
  return (vim.fn.fnamemodify(dir, ":p"):gsub("/+$", ""))
end

local function repo_last_commit_ts(dir)
  local out = vim.fn.systemlist({ "git", "-C", dir, "log", "-1", "--format=%ct" })
  local ts = tonumber(out[1] or "")
  return ts or 0
end

local function oldfiles_repo_rank()
  local rank = {}
  local ok, snacks = pcall(require, "snacks")
  if not ok then
    return rank
  end

  local score = 1000000
  for file in snacks.dashboard.oldfiles() do
    local root = snacks.git.get_root(file)
    if root then
      local key = normalize_dir(root)
      if not rank[key] then
        rank[key] = score
        score = score - 1
      end
    end
  end
  return rank
end

local function featured_repos(limit)
  local repos = discover_repo_dirs()
  local opened_rank = oldfiles_repo_rank()

  table.sort(repos, function(a, b)
    local na, nb = normalize_dir(a), normalize_dir(b)
    local oa, ob = opened_rank[na] or 0, opened_rank[nb] or 0
    if oa ~= ob then
      return oa > ob
    end

    local ta, tb = repo_last_commit_ts(a), repo_last_commit_ts(b)
    if ta ~= tb then
      return ta > tb
    end

    return na < nb
  end)

  return vim.list_slice(repos, 1, limit)
end

local current_featured_repos = featured_repos(5)

local function repository_dashboard_items()
  local keys = { "!", "@", "#", "$", "%" }
  local labels = { "Shift+1", "Shift+2", "Shift+3", "Shift+4", "Shift+5" }
  local dirs = vim.list_slice(current_featured_repos, 1, #keys)
  local items = {}

  for i, dir in ipairs(dirs) do
    local key = keys[i]
    items[#items + 1] = {
      file = dir,
      icon = " ",
      key = key,
      label = labels[i],
      autokey = false,
      action = function()
        navigate_to_dir(dir)
      end,
    }
  end

  return vim.list_extend({
    pane = 2,
    icon = " ",
    title = "Git Repos",
    enabled = function()
      return not in_git_repo()
    end,
    indent = 2,
    padding = 1,
  }, items)
end

local function recent_files_dashboard_items(limit)
  local max_items = limit or 10
  return function()
    local items = {}
    local seen = {}

    local function add_file(path)
      if not path or path == "" then
        return false
      end
      local normalized = normalize_dir(path)
      if normalized == "" or seen[normalized] then
        return false
      end
      seen[normalized] = true
      items[#items + 1] = {
        file = normalized,
        icon = "file",
        action = function()
          local dir = normalize_dir(vim.fn.fnamemodify(normalized, ":h"))
          vim.cmd("cd " .. vim.fn.fnameescape(dir))
          if open_existing_buffer_or_edit(normalized) then
            vim.cmd("redrawstatus")
          end
        end,
        autokey = true,
      }
      return #items >= max_items
    end

    local ok, snacks = pcall(require, "snacks")
    if ok then
      for file in snacks.dashboard.oldfiles() do
        if add_file(file) then
          break
        end
      end
    end

    if #items == 0 then
      for _, file in ipairs(vim.v.oldfiles or {}) do
        if add_file(file) then
          break
        end
      end
    end

    return vim.list_extend({
      icon = " ",
      title = "Recent files",
      indent = 2,
      padding = 1,
    }, items)
  end
end

local function dashboard_value_list(title, icon, value, padding)
  return {
    pane = 1,
    icon = icon,
    title = title,
    indent = 2,
    padding = padding or 1,
    { text = value, indent = 4, padding = 0 },
  }
end

local function cwd_dashboard_item()
  return function()
    local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
    local theme = vim.g.colors_name or "none"
    return {
      dashboard_value_list("cwd", " ", cwd, 1),
      dashboard_value_list("theme", "󰸌 ", theme, 0),
    }
  end
end

return {
  animate = { enabled = true },
  dashboard = {
    enabled = true,
    width = 64,
    pane_gap = 3,
    autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
    preset = {
      header = header,
      keys = {
        { icon = " ", key = "e", desc = "New file", action = ":DashboardNewFile" },
        { icon = " ", key = "f", desc = "Find file", action = ":Telescope find_files" },
        { icon = " ", key = "r", desc = "Recent files", action = ":Telescope oldfiles" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
    },
    sections = {
      { section = "header", padding = 3 },
      { section = "keys", gap = 1, padding = 2 },
      recent_files_dashboard_items(5),
      cwd_dashboard_item(),
      { section = "startup", padding = 2 },
    },
  },
  scroll = { enabled = true },
}
