return { -- dap debugging {{{
  "mfussenegger/nvim-dap",
  lazy = true,
  dependencies = {
    "nvim-telescope/telescope-dap.nvim",
    "mfussenegger/nvim-dap-python",
    "theHamsta/nvim-dap-virtual-text",
    "rcarriga/nvim-dap-ui",
  },
  config = function()
    local dap = require("dap")
    vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "", linehl = "", numhl = "" })
    vim.fn.sign_define("DapStopped", { text = "🚏", texthl = "", linehl = "", numhl = "" })
    -- dap.defaults.fallback.terminal_win_cmd = "tabnew"
    -- dap.defaults.python.terminal_win_cmd = "belowright new"
    dap.defaults.fallback.focus_terminal = true

    local dap_python = require("dap-python")

    -- Function to get the list of Conda environments
    local function get_conda_envs()
      local conda_envs_output = vim.fn.systemlist("conda env list")
      local env_paths = {}

      -- Parse the output of 'conda env list'
      for _, line in ipairs(conda_envs_output) do
        local env_name, env_path = string.match(line, "^(%S+)%s+(/%S+)")
        if env_name and env_path then
          table.insert(env_paths, env_path)
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

      -- Construct a list for inputlist with index and environment path
      local choices = {}
      for idx, env_path in ipairs(env_paths) do
        table.insert(choices, idx .. ": " .. env_path)
      end

      -- Prompt user to choose an environment
      local choice = vim.fn.inputlist(choices)

      if choice > 0 and choice <= #env_paths then
        return env_paths[choice]
      else
        return nil
      end
    end

    -- Store selected environment to avoid prompting each time
    local selected_env = nil

    -- Modify dap-python to use the selected Conda environment
    dap_python.resolve_python = function()
      if not selected_env then
        selected_env = choose_conda_env()
      end

      if selected_env then
        return selected_env .. "/bin/python"
      else
        -- Fallback to system Python if no environment selected
        return vim.fn.system("which python"):gsub("\n", "")
      end
    end

    dap_python.test_runner = "pytest"
    dap_python.default_port = 38000

    dap.listeners.after.event_initialized["dapui_config"] = function()
      require("dapui").open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      require("dapui").close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      require("dapui").close()
    end
  end,
}
