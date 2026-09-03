local dap = require("dap")
local dap_python = require("dap-python")
local python = require("config.python")

dap_python.setup(python.get_system_python() or "python")
dap_python.resolve_python = function()
  return python.get_python({ root = python.get_project_root(0) }) or "python"
end

local function resolve_cpp_adapter()
  local lldb_vscode = vim.fn.exepath("lldb-vscode")
  if lldb_vscode ~= "" then
    return {
      type = "executable",
      command = lldb_vscode,
      name = "lldb",
    }
  end

  return nil
end

local cpp_adapter = resolve_cpp_adapter()
if cpp_adapter then
  dap.adapters.cpp = cpp_adapter
  dap.adapters.c = cpp_adapter
  dap.adapters.rust = cpp_adapter

  local cpp_launch = {
    name = "Launch",
    type = "cpp",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  }

  dap.configurations.cpp = { cpp_launch }
  dap.configurations.c = { cpp_launch }
  dap.configurations.rust = { cpp_launch }
else
end

-- Keymaps for DAP
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug continue" })
vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Debug step over" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Debug step into" })
vim.keymap.set("n", "<leader>du", dap.step_out, { desc = "Debug step out" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug toggle breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug conditional breakpoint" })
vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug REPL" })
vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Debug run last" })
