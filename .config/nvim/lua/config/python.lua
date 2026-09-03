local M = {}
local uv = vim.uv or vim.loop

local is_windows = uv.os_uname().sysname == "Windows_NT"

local function path_join(...)
  return table.concat({ ... }, is_windows and "\\" or "/")
end

local function file_exists(path)
  return uv.fs_stat(path) ~= nil
end

local function is_dir(path)
  local stat = uv.fs_stat(path)
  return stat and stat.type == "directory" or false
end

local function python_in_venv(venv_dir)
  local python_path = is_windows and path_join(venv_dir, "Scripts", "python.exe") or path_join(venv_dir, "bin", "python")
  if file_exists(python_path) then
    return python_path
  end
  return nil
end

function M.get_project_root(bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr or 0)
  local start = file ~= "" and vim.fs.dirname(file) or vim.fn.getcwd()
  local markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "poetry.lock", ".git" }

  if vim.fs.root then
    return vim.fs.root(start, markers) or vim.fn.getcwd()
  end

  local found = vim.fs.find(markers, { path = start, upward = true, stop = uv.os_homedir(), limit = 1 })
  if #found > 0 then
    return vim.fs.dirname(found[1])
  end

  return vim.fn.getcwd()
end

function M.get_system_python()
  local python3 = vim.fn.exepath("python3")
  if python3 ~= "" then
    return python3
  end
  local python = vim.fn.exepath("python")
  if python ~= "" then
    return python
  end
  return nil
end

function M.get_venv_dir(opts)
  opts = opts or {}
  local root = opts.root or M.get_project_root(opts.bufnr)

  local env_venv = vim.env.VIRTUAL_ENV
  if env_venv and env_venv ~= "" and is_dir(env_venv) and python_in_venv(env_venv) then
    return env_venv
  end

  for _, name in ipairs({ ".venv", "venv", ".env", "env" }) do
    local candidate = path_join(root, name)
    if is_dir(candidate) and python_in_venv(candidate) then
      return candidate
    end
  end

  return nil
end

function M.get_python(opts)
  local venv_dir = M.get_venv_dir(opts)
  if venv_dir then
    return python_in_venv(venv_dir)
  end
  return M.get_system_python()
end

return M
