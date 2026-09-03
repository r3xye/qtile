local M = {}

function M.setup()
  require("Comment").setup()
end

local function parse_commentstring()
  local cstr = vim.bo.commentstring
  local left, right = cstr:match("^(.*)%%s(.*)$")

  if not left and not right then
    vim.notify("Invalid commentstring: " .. cstr, vim.log.levels.WARN)
    return
  end

  return vim.trim(left or ""), vim.trim(right or "")
end

local function is_commented(line, left, right)
  local trimmed = vim.trim(line)
  if trimmed == "" then
    return true
  end

  local left_pat = vim.pesc(left)
  if right == "" then
    return line:match("^%s*" .. left_pat .. "%s?") ~= nil
  end

  local right_pat = vim.pesc(right)
  return line:match("^%s*" .. left_pat .. "%s?.-" .. right_pat .. "%s*$") ~= nil
end

local function comment_line(line, left, right)
  local indent, body = line:match("^(%s*)(.*)$")
  if body == "" then
    return line
  end

  if right == "" then
    return indent .. left .. " " .. body
  end

  return indent .. left .. " " .. body .. " " .. right
end

local function uncomment_line(line, left, right)
  local indent, body = line:match("^(%s*)(.*)$")
  if body == "" then
    return line
  end

  if right == "" then
    local uncommented = body:gsub("^" .. vim.pesc(left) .. "%s?", "", 1)
    return indent .. uncommented
  end

  local uncommented = body:gsub("^" .. vim.pesc(left) .. "%s?", "", 1)
  uncommented = uncommented:gsub("%s?" .. vim.pesc(right) .. "%s*$", "", 1)
  return indent .. uncommented
end

function M.toggle_visual()
  local left, right = parse_commentstring()
  if not left then
    return
  end

  local cursor_pos = vim.fn.getpos(".")
  local visual_pos = vim.fn.getpos("v")
  local start_row = visual_pos[2]
  local end_row = cursor_pos[2]
  if start_row < 1 or end_row < 1 then
    vim.notify("No visual selection found", vim.log.levels.WARN)
    return
  end

  if start_row > end_row then
    start_row, end_row = end_row, start_row
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
  local should_uncomment = true

  for _, line in ipairs(lines) do
    if vim.trim(line) ~= "" and not is_commented(line, left, right) then
      should_uncomment = false
      break
    end
  end

  for i, line in ipairs(lines) do
    if vim.trim(line) ~= "" then
      lines[i] = should_uncomment and uncomment_line(line, left, right) or comment_line(line, left, right)
    end
  end

  vim.api.nvim_buf_set_lines(0, start_row - 1, end_row, false, lines)
  vim.fn.setpos("'<", { 0, start_row, 1, 0 })
  vim.fn.setpos("'>", { 0, end_row, math.max(1, #lines[#lines]), 0 })
  vim.cmd("normal! gv")
  vim.fn.setpos(".", cursor_pos)
end

return M
