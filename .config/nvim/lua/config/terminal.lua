local M = {}

local runner_state = {
  buf = nil,
  win = nil,
}

local function is_valid_buf(buf)
  return buf and vim.api.nvim_buf_is_valid(buf)
end

local function is_valid_win(win)
  return win and vim.api.nvim_win_is_valid(win)
end

local function close_runner()
  if is_valid_win(runner_state.win) then
    vim.api.nvim_win_close(runner_state.win, true)
  end
  runner_state.win = nil
end

local function apply_terminal_style(buf, win, filetype, title)
  vim.bo[buf].buflisted = false
  vim.bo[buf].filetype = filetype

  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].cursorline = false
  vim.wo[win].winfixbuf = true
  vim.wo[win].winblend = 6
  vim.wo[win].spell = false

  vim.api.nvim_set_hl(0, "RunnerFloat", { link = "NormalFloat" })
  vim.api.nvim_set_hl(0, "RunnerBorder", { link = "FloatBorder" })
  vim.api.nvim_set_hl(0, "RunnerTitle", { link = "Title" })

  vim.api.nvim_set_option_value("winhighlight", table.concat({
    "Normal:RunnerFloat",
    "FloatBorder:RunnerBorder",
    "FloatTitle:RunnerTitle",
  }, ","), { scope = "local", win = win })
end

local function open_floating_terminal(state, opts)
  local width = math.max(opts.min_width or 90, math.floor(vim.o.columns * (opts.width_ratio or 0.72)))
  local height = math.max(opts.min_height or 24, math.floor(vim.o.lines * (opts.height_ratio or 0.68)))
  local row = math.max(1, math.floor((vim.o.lines - height) / 2) - 1)
  local col = math.max(0, math.floor((vim.o.columns - width) / 2))

  local buf = state.buf
  if not is_valid_buf(buf) then
    buf = vim.api.nvim_create_buf(false, true)
  end

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = opts.title,
    title_pos = "center",
  })

  state.buf = buf
  state.win = win
  apply_terminal_style(buf, win, opts.filetype, opts.title)
  return buf, win
end

function M.open_runner()
  local buf, _ = open_floating_terminal(runner_state, {
    filetype = "runner",
    title = " runner ",
    width_ratio = 0.78,
    height_ratio = 0.62,
    min_width = 100,
    min_height = 18,
  })

  if vim.bo[buf].buftype ~= "terminal" then
    vim.fn.termopen(vim.o.shell, {
      on_exit = function()
        vim.schedule(function()
          if is_valid_buf(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
          runner_state.buf = nil
          runner_state.win = nil
        end)
      end,
    })

    vim.keymap.set("t", "q", close_runner, { buffer = buf, silent = true, nowait = true })
  end

  vim.cmd.startinsert()
  return buf
end

function M.get_runner_job()
  local buf = runner_state.buf
  if not is_valid_buf(buf) or vim.bo[buf].buftype ~= "terminal" then
    return nil, nil
  end

  local ok, job_id = pcall(vim.api.nvim_buf_get_var, buf, "terminal_job_id")
  if not ok or not job_id or vim.fn.jobwait({ job_id }, 0)[1] ~= -1 then
    return nil, nil
  end

  return buf, job_id
end

function M.send_to_runner(cmd)
  local buf, job_id = M.get_runner_job()
  if not buf or not job_id then
    buf = M.open_runner()
    _, job_id = M.get_runner_job()
  else
    if is_valid_win(runner_state.win) then
      vim.api.nvim_set_current_win(runner_state.win)
    else
      M.open_runner()
    end
  end

  if not job_id then
    vim.notify("Failed to open floating terminal", vim.log.levels.ERROR)
    return false
  end

  vim.fn.chansend(job_id, "clear\n")
  vim.fn.chansend(job_id, cmd .. "\n")
  vim.cmd.startinsert()
  return true
end

function M.stop_runner()
  local buf, job_id = M.get_runner_job()
  if not buf or not job_id then
    return false
  end

  vim.fn.jobstop(job_id)
  local wins = vim.fn.win_findbuf(buf)
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
  runner_state.buf = nil
  runner_state.win = nil
  return true
end

function M.setup()
  vim.api.nvim_create_autocmd("TermOpen", {
    callback = function(args)
      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = args.buf })
    end,
  })

  vim.api.nvim_create_autocmd("VimResized", {
    callback = function()
      if is_valid_win(runner_state.win) then
        close_runner()
        M.open_runner()
      end
    end,
  })
end

return M
