-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Escape jk
vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape" })
vim.keymap.set("v", "jk", "<Esc>", { desc = "Escape" })
vim.keymap.set("t", "jk", "<C-\\><C-n> ", { desc = "Escape" })

-- Debugging
vim.keymap.set({ "n", "v" }, "<Leader>dc", '<Cmd>lua require"dap".continue()<CR>', { desc = "continue" })
vim.keymap.set({ "n", "v" }, "<Leader>dl", '<Cmd>lua require"dap".run_last()<CR>', { desc = "run last" })
vim.keymap.set({ "n", "v" }, "<Leader>dq", '<Cmd>lua require"dap".terminate()<CR>', { desc = "terminate" })
vim.keymap.set({ "n", "v" }, "<Leader>dh", '<Cmd>lua require"dap".close()<CR>', { desc = "close" })
vim.keymap.set({ "n", "v" }, "<Leader>dn", '<Cmd>lua require"dap".step_over()<CR>', { desc = "step over" })
vim.keymap.set({ "n", "v" }, "<Leader>ds", '<Cmd>lua require"dap".step_into()<CR>', { desc = "step into" })
vim.keymap.set({ "n", "v" }, "<Leader>dS", '<Cmd>lua require"dap".step_out()<CR>', { desc = "step out" })
vim.keymap.set({ "n", "v" }, "<Leader>db", '<Cmd>lua require"dap".toggle_breakpoint()<CR>', { desc = "toggle br" })
vim.keymap.set(
  { "n", "v" },
  "<Leader>dB",
  '<Cmd>lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>',
  { desc = "set br condition" }
)
vim.keymap.set(
  { "n", "v" },
  "<Leader>dp",
  '<Cmd>lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>',
  { desc = "set log br" }
)
vim.keymap.set({ "n", "v" }, "<Leader>dr", '<Cmd>lua require"dap".repl.open()<CR>', { desc = "REPL open" })
vim.keymap.set({ "n", "v" }, "<Leader>dk", '<Cmd>lua require"dap".up()<CR>', { desc = "up callstack" })
vim.keymap.set({ "n", "v" }, "<Leader>dj", '<Cmd>lua require"dap".down()<CR>', { desc = "down callstack" })
vim.keymap.set({ "n", "v" }, "<Leader>di", '<Cmd>lua require"dap.ui.widgets".hover()<CR>', { desc = "info" })
vim.keymap.set({ "n", "v" }, "<Leader>df", "<Cmd>Telescope dap frames<CR>", { desc = "search frames" })
vim.keymap.set({ "n", "v" }, "<Leader>dC", "<Cmd>Telescope dap commands<CR>", { desc = "search commands" })
vim.keymap.set({ "n", "v" }, "<Leader>dL", "<Cmd>Telescope dap list_breakpoints<CR>", { desc = "search breakpoints" })

-- Function to get the list of Conda environments
local function get_conda_envs()
  local conda_envs_output = vim.fn.systemlist("conda env list")
  local env_paths = {}

  -- Parse the output of 'conda env list'
  for _, line in ipairs(conda_envs_output) do
    local env_name, env_path = string.match(line, "^(%S+)%s+(/%S+)")
    if env_name and env_path then
      table.insert(env_paths, { name = env_name, path = env_path })
    end
  end

  return env_paths
end

-- Function to prompt the user to select an environment
local function choose_conda_env()
  local env_paths = get_conda_envs()

  if #env_paths == 0 then
    print("No Conda environments found.")
    return nil
  end

  -- Construct a list for inputlist with index and environment name and path
  local choices = { "Select a Conda environment:" }
  for idx, env in ipairs(env_paths) do
    table.insert(choices, idx .. ": " .. env.name .. " (" .. env.path .. ")")
  end

  -- Prompt user to choose an environment
  local choice = vim.fn.inputlist(choices)

  if choice > 0 and choice <= #env_paths then
    return env_paths[choice].path
  else
    return nil
  end
end

-- Store selected environment to avoid prompting each time
local selected_env = nil

-- Function to run the current file in a terminal
local function run_current_file_in_terminal()
  local filepath = vim.fn.expand("%:p")
  if filepath == "" then
    print("No file is currently open.")
    return
  end

  local filetype = vim.bo.filetype

  local cmd = ""

  if filetype == "python" then
    -- If no selected_env, prompt the user to choose one
    if not selected_env then
      selected_env = choose_conda_env()
    end

    if selected_env then
      cmd = selected_env .. "/bin/python " .. vim.fn.shellescape(filepath)
    else
      -- Fallback to system Python
      cmd = "python " .. vim.fn.shellescape(filepath)
    end
  else
    -- For other filetypes, adjust the command accordingly
    cmd = vim.fn.shellescape(filepath)
  end

  -- Open a terminal and run the command
  vim.cmd("split | terminal " .. cmd)
  -- Alternatively, for a vertical split:
  -- vim.cmd("vsplit | terminal " .. cmd)
end

-- Map the function to a command and keybinding
vim.api.nvim_create_user_command("RunCurrentFile", run_current_file_in_terminal, {})
vim.keymap.set("n", "<leader>r", ":RunCurrentFile<CR>", { noremap = true, silent = true }, { desc = "Run in Python" })
