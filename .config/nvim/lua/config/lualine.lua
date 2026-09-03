local function full_filepath()
  local path = vim.fn.expand("%:p")
  if path == "" then
    return "[No Name]"
  end
  return path
end

local function active_cwd()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
end

local function current_theme()
  return vim.g.colors_name or "none"
end

require("lualine").setup({
  options = {
    globalstatus = true,
    theme = "auto",
    component_separators = "|",
    section_separators = "",
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { { full_filepath, path = 1, shorting_target = 80 } },
    lualine_x = {
      { function() return "cwd:" end, padding = { left = 1, right = 0 } },
      { active_cwd, padding = { left = 0, right = 1 } },
      { function() return "theme:" end, padding = { left = 1, right = 0 } },
      { current_theme, padding = { left = 0, right = 1 } },
      "encoding",
      "fileformat",
      "filetype",
    },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
})
