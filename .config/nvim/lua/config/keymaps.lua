-- Custom keymaps
local typst = require("config.typst")
local python = require("config.python")
local terminal = require("config.terminal")
local function rename_current_file()
  local old_path = vim.api.nvim_buf_get_name(0)
  if old_path == "" then
    vim.notify("No file to rename", vim.log.levels.WARN)
    return
  end

  local dir = vim.fn.fnamemodify(old_path, ":h")
  local old_name = vim.fn.fnamemodify(old_path, ":t")

  vim.ui.input({ prompt = "Rename to: ", default = old_name }, function(new_name)
    if not new_name or new_name == "" or new_name == old_name then
      return
    end

    local new_path = dir .. "/" .. new_name
    if vim.fn.filereadable(new_path) == 1 or vim.fn.isdirectory(new_path) == 1 then
      vim.notify("Target exists: " .. new_path, vim.log.levels.ERROR)
      return
    end

    if vim.bo.modified then
      vim.cmd("write")
    end

    if vim.fn.rename(old_path, new_path) ~= 0 then
      vim.notify("Rename failed: " .. (vim.v.errmsg or "unknown error"), vim.log.levels.ERROR)
      return
    end

    vim.api.nvim_buf_set_name(0, new_path)
    vim.cmd("silent! write")
    vim.notify("Renamed to: " .. new_name, vim.log.levels.INFO)
  end)
end

local function rename_current_buffer()
  local old_name = vim.api.nvim_buf_get_name(0)
  if old_name == "" then
    old_name = "[No Name]"
  end

  vim.ui.input({ prompt = "Buffer name: ", default = old_name }, function(new_name)
    if not new_name or new_name == "" or new_name == old_name then
      return
    end

    vim.cmd("file " .. vim.fn.fnameescape(new_name))
    vim.notify("Buffer renamed to: " .. new_name, vim.log.levels.INFO)
  end)
end

local function run_in_buffer_terminal(cmd, desc)
  local _, live_job = terminal.get_runner_job()
  if not live_job then
    terminal.open_runner()
  end

  if not terminal.send_to_runner(cmd) then
    return
  end

  vim.g.last_run_desc = desc or cmd
end

local function run_in_kitty_terminal(cmd, desc)
  if vim.fn.executable("kitty") ~= 1 then
    return run_in_buffer_terminal(cmd, desc)
  end

  local cwd = vim.fn.getcwd()
  local job_id = vim.fn.jobstart({ "kitty", "--working-directory", cwd, "--hold", "sh", "-lc", cmd }, { detach = true })
  if job_id <= 0 then
    return run_in_buffer_terminal(cmd, desc)
  end

  vim.g.last_run_job_id = job_id
  vim.g.last_run_desc = desc or cmd
end

local function run_in_terminal(cmd, desc)
  run_in_kitty_terminal(cmd, desc)
end

local function run_current_file_in_buffer()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("No file to run", vim.log.levels.WARN)
    return
  end

  local rel = vim.fn.fnamemodify(file, ":.")
  if rel:sub(1, 2) == ".." then
    vim.notify("File is outside current working directory", vim.log.levels.ERROR)
    return
  end

  if file:match("%.py$") then
    local python_exec = python.get_python({ root = python.get_project_root(0) })
    if not python_exec then
      vim.notify("Python not found in PATH", vim.log.levels.ERROR)
      return
    end

    local cmd = vim.fn.shellescape(python_exec) .. " " .. vim.fn.shellescape(rel)
    run_in_buffer_terminal(cmd, cmd)
    return
  end

  if file:match("%.c$") or file:match("%.cc$") or file:match("%.cpp$") or file:match("%.cxx$") then
    if vim.fn.executable("g++") ~= 1 then
      vim.notify("g++ not found in PATH", vim.log.levels.ERROR)
      return
    end

    local out_dir = "compile"
    local out = vim.fn.fnamemodify(file, ":t:r")
    local out_path = out_dir .. "/" .. out
    local cmd = string.format(
      "mkdir -p %s && g++ -std=c++20 -O0 -g %s -o %s && %s",
      vim.fn.shellescape(out_dir),
      vim.fn.shellescape(rel),
      vim.fn.shellescape(out_path),
      vim.fn.shellescape(out_path)
    )
    run_in_buffer_terminal(cmd, cmd)
    return
  end

  vim.notify("Buffer runner supports only Python and C/C++", vim.log.levels.WARN)
end

local function run_python_module_in_terminal()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("No file to run", vim.log.levels.WARN)
    return
  end
  if not file:match("%.py$") then
    vim.notify("Not a Python file", vim.log.levels.WARN)
    return
  end

  local rel = vim.fn.fnamemodify(file, ":.")
  if rel:sub(1, 2) == ".." then
    vim.notify("File is outside current working directory", vim.log.levels.ERROR)
    return
  end

  local python_exec = python.get_python({ root = python.get_project_root(0) })
  if not python_exec then
    vim.notify("Python not found in PATH", vim.log.levels.ERROR)
    return
  end

  local rel_escaped = vim.fn.shellescape(rel)
  local cmd = vim.fn.shellescape(python_exec) .. " " .. rel_escaped
  run_in_terminal(cmd, cmd)
end

local function run_cpp_in_terminal()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("No file to run", vim.log.levels.WARN)
    return
  end
  if not file:match("%.c$") and not file:match("%.cc$") and not file:match("%.cpp$") and not file:match("%.cxx$") then
    vim.notify("Not a C/C++ file", vim.log.levels.WARN)
    return
  end

  if vim.fn.executable("g++") ~= 1 then
    vim.notify("g++ not found in PATH", vim.log.levels.ERROR)
    return
  end

  local rel = vim.fn.fnamemodify(file, ":.")
  if rel:sub(1, 2) == ".." then
    vim.notify("File is outside current working directory", vim.log.levels.ERROR)
    return
  end

  local out_dir = "compile"
  local out = vim.fn.fnamemodify(file, ":t:r")
  local out_path = out_dir .. "/" .. out
  local rel_escaped = vim.fn.shellescape(rel)
  local out_dir_escaped = vim.fn.shellescape(out_dir)
  local out_path_escaped = vim.fn.shellescape(out_path)
  local cmd = string.format(
    "mkdir -p %s && g++ -std=c++20 -O0 -g %s -o %s && %s",
    out_dir_escaped,
    rel_escaped,
    out_path_escaped,
    out_path_escaped
  )
  run_in_terminal(cmd, cmd)
end

local function run_current_file()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("No file to run", vim.log.levels.WARN)
    return
  end

  if file:match("%.py$") then
    run_python_module_in_terminal()
    return
  end

  if file:match("%.typ$") or file:match("%.typst$") then
    typst.toggle_watch()
    return
  end

  if file:match("%.c$") or file:match("%.cc$") or file:match("%.cpp$") or file:match("%.cxx$") then
    run_cpp_in_terminal()
    return
  end

  vim.notify("No runner for this file type", vim.log.levels.WARN)
end

local function open_dashboard()
  local ok, snacks = pcall(require, "snacks")
  if not ok or not snacks.dashboard then
    vim.notify("Dashboard is unavailable", vim.log.levels.WARN)
    return
  end
  snacks.dashboard.open()
end

vim.keymap.set("n", "<leader>fr", rename_current_file, { desc = "Rename file" })
vim.keymap.set("n", "<leader>br", rename_current_buffer, { desc = "Rename buffer" })
vim.keymap.set("n", "<leader>q", open_dashboard, { desc = "Open dashboard" })
vim.keymap.set("n", "<leader>r", run_current_file, { desc = "Run current file" })
vim.keymap.set("n", "<leader>R", run_current_file_in_buffer, { desc = "Run current file in floating terminal" })

local function stop_last_run()
  local file = vim.api.nvim_buf_get_name(0)
  if file ~= "" and (file:match("%.typ$") or file:match("%.typst$")) then
    typst.stop()
    vim.notify("Typst stopped", vim.log.levels.INFO)
    return
  end

  local term_buf, term_job = terminal.get_runner_job()
  if term_buf and term_job then
    terminal.stop_runner()
    local desc = vim.g.last_run_desc or "last run"
    vim.notify("Stopped: " .. desc, vim.log.levels.INFO)
    return
  end

  if vim.g.last_run_job_id and vim.fn.jobwait({ vim.g.last_run_job_id }, 0)[1] == -1 then
    vim.fn.jobstop(vim.g.last_run_job_id)
    local desc = vim.g.last_run_desc or "last job"
    vim.notify("Stopped: " .. desc, vim.log.levels.INFO)
    return
  end

  vim.notify("No running job to stop", vim.log.levels.WARN)
end

vim.keymap.set("n", "<leader>s", stop_last_run, { desc = "Stop current run" })

local function run_ruff_on_current_file()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("No file to lint", vim.log.levels.WARN)
    return
  end

  if not file:match("%.py$") then
    vim.notify("Ruff works with Python files", vim.log.levels.WARN)
    return
  end

  if vim.fn.executable("ruff") ~= 1 then
    vim.notify("ruff not found in PATH", vim.log.levels.ERROR)
    return
  end

  if vim.bo.modified then
    vim.cmd("write")
  end

  local check_output = vim.fn.system({ "ruff", "check", "--fix", file })
  if vim.v.shell_error ~= 0 then
    vim.notify("ruff check failed:\n" .. check_output, vim.log.levels.ERROR)
    return
  end

  local format_output = vim.fn.system({ "ruff", "format", file })
  if vim.v.shell_error ~= 0 then
    vim.notify("ruff format failed:\n" .. format_output, vim.log.levels.ERROR)
    return
  end

  vim.cmd("checktime")
  vim.notify("ruff: fixed and formatted", vim.log.levels.INFO)
end

vim.keymap.set("n", "<leader>dR", run_ruff_on_current_file, { desc = "Ruff fix + format" })

-- Comment shortcut in visual mode
vim.keymap.set("x", "/", function()
  require("config.comment").toggle_visual()
end, { desc = "Toggle comment selection" })

-- Keep selection after indenting in visual mode
vim.keymap.set("x", ">", ">gv", { desc = "Indent right and keep selection" })
vim.keymap.set("x", "<", "<gv", { desc = "Indent left and keep selection" })
