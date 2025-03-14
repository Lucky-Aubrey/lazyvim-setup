return {
  "rcarriga/nvim-dap-ui",
  dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
  lazy = true,
  -- init = function()
  -- WK({
  --   d = { name = "+debug", u = { '<Cmd>lua require"dapui".toggle()<CR>', "ui toggle" },
  --     e = { '<Cmd>lua require"dapui".eval()<CR>', "eval" },
  --     E = { '<Cmd>lua require"dapui".toggle()<CR>', "float element" },
  --   },
  -- }, { prefix = "<leader>" })
  -- WK({
  --   d = {
  --     name = "+debug",
  --     e = { '<Cmd>lua require"dapui".eval()<CR>', "eval" },
  --   },
  -- }, { prefix = "<leader>", mode = "v" })
  -- end,
  config = true,
}
