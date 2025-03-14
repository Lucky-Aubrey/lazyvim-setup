return {
  "theHamsta/nvim-dap-virtual-text",
  lazy = true,
  config = function()
    require("nvim-dap-virtual-text").setup()
    vim.cmd("highlight! NvimDapVirtualText guifg=#7c6f64 gui=italic")
  end,
}
