-- Typst helpers and keymaps
local M = {}
local stop_watch_typst
local function is_typst_path(path)
  return path:match("%.typ$") or path:match("%.typst$")
end

local function remember_typst_file(file)
  if is_typst_path(file) then
    vim.g.typst_last_file = file
  end
end

local function get_typst_file()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("No file to run", vim.log.levels.WARN)
    return nil
  end
  if not is_typst_path(file) then
    vim.notify("Not a Typst file", vim.log.levels.WARN)
    return nil
  end
  remember_typst_file(file)
  return file
end

local function get_pdf_path(typst_file)
  local source_dir = vim.fn.fnamemodify(typst_file, ":p:h")
  local output_dir = source_dir .. "/pdf"
  return output_dir .. "/" .. vim.fn.fnamemodify(typst_file, ":t:r") .. ".pdf"
end

local function ensure_pdf_dir(typst_file)
  local pdf_dir = vim.fn.fnamemodify(get_pdf_path(typst_file), ":h")
  vim.fn.mkdir(pdf_dir, "p")
  return pdf_dir
end

local function ensure_typst()
  if vim.fn.executable("typst") ~= 1 then
    vim.notify("typst not found in PATH", vim.log.levels.ERROR)
    return false
  end
  return true
end

local function compile_typst()
  if not ensure_typst() then
    return
  end

  local file = get_typst_file()
  if not file then
    return
  end

  ensure_pdf_dir(file)
  local pdf = get_pdf_path(file)
  local output = vim.fn.system({ "typst", "compile", file, pdf })
  if vim.v.shell_error ~= 0 then
    vim.notify("Typst compile failed: " .. output, vim.log.levels.ERROR)
    return
  end

  vim.notify("Typst compiled: " .. pdf, vim.log.levels.INFO)
end

local function preview_typst()
  if not ensure_typst() then
    return
  end

  local file = get_typst_file()
  if not file then
    return
  end

  ensure_pdf_dir(file)
  local pdf = get_pdf_path(file)
  local output = vim.fn.system({ "typst", "compile", file, pdf })
  if vim.v.shell_error ~= 0 then
    vim.notify("Typst compile failed: " .. output, vim.log.levels.ERROR)
    return
  end

  if vim.fn.executable("zathura") ~= 1 then
    vim.notify("zathura not found in PATH", vim.log.levels.ERROR)
    return
  end

  vim.fn.jobstart({ "zathura", pdf }, { detach = true })
  vim.notify("Typst preview: " .. pdf, vim.log.levels.INFO)
end

local function escape_pgrep_pattern(text)
  return text:gsub("([\\.^$*+?()\\[%]{}|])", "\\%1")
end

local function zathura_running_for_pdf(pdf)
  if vim.fn.executable("pgrep") ~= 1 then
    return false
  end
  local pattern = "zathura%s+" .. escape_pgrep_pattern(pdf)
  local result = vim.fn.systemlist({ "pgrep", "-f", pattern })
  return (vim.v.shell_error == 0) and (#result > 0)
end

local function stop_zathura_for_pdf(pdf)
  if vim.fn.executable("pkill") == 1 and vim.fn.executable("pgrep") == 1 then
    local pattern = "zathura%s+" .. escape_pgrep_pattern(pdf)
    vim.fn.system({ "pkill", "-f", pattern })
  end
  if vim.g.typst_preview_job_id then
    vim.fn.jobstop(vim.g.typst_preview_job_id)
    vim.g.typst_preview_job_id = nil
  end
  if vim.g.typst_zathura_job_id then
    vim.fn.jobstop(vim.g.typst_zathura_job_id)
    vim.g.typst_zathura_job_id = nil
  end
end

local function stop_typst_for_current_buffer()
  local file = get_typst_file()
  if not file and type(vim.g.typst_last_file) == "string" and vim.g.typst_last_file ~= "" then
    file = vim.g.typst_last_file
  end
  if not file then
    return
  end

  if vim.g.typst_watch_job_id and vim.fn.jobwait({ vim.g.typst_watch_job_id }, 0)[1] == -1 then
    stop_watch_typst()
  end

  local pdf = get_pdf_path(file)
  stop_zathura_for_pdf(pdf)
end

local function toggle_preview_typst()
  if not ensure_typst() then
    return
  end

  local file = get_typst_file()
  if not file then
    return
  end
  remember_typst_file(file)

  local pdf = get_pdf_path(file)
  if zathura_running_for_pdf(pdf) then
    stop_zathura_for_pdf(pdf)
    vim.notify("Typst preview closed: " .. pdf, vim.log.levels.INFO)
    return
  end

  ensure_pdf_dir(file)
  local output = vim.fn.system({ "typst", "compile", file, pdf })
  if vim.v.shell_error ~= 0 then
    vim.notify("Typst compile failed: " .. output, vim.log.levels.ERROR)
    return
  end

  if vim.fn.executable("zathura") ~= 1 then
    vim.notify("zathura not found in PATH", vim.log.levels.ERROR)
    return
  end

  local job_id = vim.fn.jobstart({ "zathura", pdf }, { detach = true })
  if job_id > 0 then
    vim.g.typst_preview_job_id = job_id
  end
  vim.notify("Typst preview: " .. pdf, vim.log.levels.INFO)
end

local function watch_typst()
  if not ensure_typst() then
    return
  end

  local file = get_typst_file()
  if not file then
    return
  end

  if vim.g.typst_watch_job_id and vim.fn.jobwait({ vim.g.typst_watch_job_id }, 0)[1] == -1 then
    vim.notify("Typst watch already running", vim.log.levels.INFO)
    return
  end

  ensure_pdf_dir(file)
  local pdf = get_pdf_path(file)
  local cmd = { "typst", "watch", file, pdf }
  local job_id = vim.fn.jobstart(cmd, { detach = true })
  if job_id <= 0 then
    vim.notify("Failed to start typst watch", vim.log.levels.ERROR)
    return
  end

  vim.g.typst_watch_job_id = job_id
  if vim.fn.executable("zathura") == 1 then
    local zathura_running = false
    if vim.fn.executable("pgrep") == 1 then
      local result = vim.fn.systemlist({ "pgrep", "-f", "zathura " .. pdf })
      zathura_running = (vim.v.shell_error == 0) and (#result > 0)
    end
    if not zathura_running then
      local zathura_job_id = vim.fn.jobstart({ "zathura", pdf }, { detach = true })
      if zathura_job_id > 0 then
        vim.g.typst_zathura_job_id = zathura_job_id
      end
    end
  else
    vim.notify("zathura not found in PATH", vim.log.levels.WARN)
  end
  vim.notify("Typst watch started (real-time preview)", vim.log.levels.INFO)
end

stop_watch_typst = function()
  if not vim.g.typst_watch_job_id then
    vim.notify("Typst watch not running", vim.log.levels.INFO)
    return
  end

  vim.fn.jobstop(vim.g.typst_watch_job_id)
  vim.g.typst_watch_job_id = nil
  if vim.g.typst_zathura_job_id then
    vim.fn.jobstop(vim.g.typst_zathura_job_id)
    vim.g.typst_zathura_job_id = nil
  end
  vim.notify("Typst watch stopped", vim.log.levels.INFO)
end

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.typ", "*.typst" },
  callback = function()
    vim.bo.filetype = "typst"
  end,
})

local typst_autosave_timers = {}

local function schedule_typst_autosave(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  if vim.bo[bufnr].buftype ~= "" or not vim.bo[bufnr].modifiable or vim.bo[bufnr].readonly then
    return
  end
  if not is_typst_path(vim.api.nvim_buf_get_name(bufnr)) then
    return
  end

  if typst_autosave_timers[bufnr] then
    typst_autosave_timers[bufnr]:stop()
    typst_autosave_timers[bufnr]:close()
  end

  local timer = vim.loop.new_timer()
  typst_autosave_timers[bufnr] = timer
  timer:start(500, 0, function()
    timer:stop()
    timer:close()
    typst_autosave_timers[bufnr] = nil
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      if vim.bo[bufnr].modified and vim.bo[bufnr].modifiable and not vim.bo[bufnr].readonly then
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd("silent write")
        end)
      end
    end)
  end)
end

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave" }, {
  pattern = { "*.typ", "*.typst" },
  callback = function(args)
    schedule_typst_autosave(args.buf)
  end,
})

vim.api.nvim_create_autocmd("BufWipeout", {
  pattern = { "*.typ", "*.typst" },
  callback = function(args)
    local timer = typst_autosave_timers[args.buf]
    if timer then
      timer:stop()
      timer:close()
      typst_autosave_timers[args.buf] = nil
    end
  end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    if vim.g.typst_watch_job_id then
      vim.fn.jobstop(vim.g.typst_watch_job_id)
      vim.g.typst_watch_job_id = nil
    end
    if vim.g.typst_zathura_job_id then
      vim.fn.jobstop(vim.g.typst_zathura_job_id)
      vim.g.typst_zathura_job_id = nil
    end
  end,
})

local function toggle_watch_typst()
  if vim.g.typst_watch_job_id and vim.fn.jobwait({ vim.g.typst_watch_job_id }, 0)[1] == -1 then
    stop_watch_typst()
  else
    watch_typst()
  end
end

M.toggle_preview = toggle_preview_typst
M.toggle_watch = toggle_watch_typst
M.stop = stop_typst_for_current_buffer

return M
