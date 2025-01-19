vim.env.LAZY_STDPATH = ".repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

---@diagnostic disable [missing-fields]
require("lazy.minit").repro({
  spec = {
    {
      "nvim-neotest/neotest",
      dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "MisanthropicBit/neotest-busted",
        { "mfussenegger/nvim-dap", version = "*" },
      },
      opts = {
        output = { open_on_run = true },
        busted = {
          busted_command = ".tests/data/nvim/lazy/busted/bin/busted",
          minimal_init = "tests/busted.lua",
          local_luarocks_only = true,
        },
      },
      config = function(_, opts)
        config_local_lua_dap()
        opts.adapters = { require("neotest-busted")(opts.busted) }
        require("neotest").setup(opts)

        local dap = require("dap")
        local base_path = vim.loop.cwd() .. "/local-lua-debugger-vscode/"
        dap.adapters["local-lua"] = {
          type = "executable",
          command = "node",
          args = { base_path .. "extension/debugAdapter.js" },
          enrich_config = function(config, on_config)
            if not config["extensionPath"] then
              local _config = vim.deepcopy(config)
              _config.extensionPath = base_path
              on_config(_config)
            else
              on_config(config)
            end
          end,
        }
        dap.configurations.lua = {
          {
            name = "Launch file (local-lua)",
            type = "local-lua",
            request = "launch",
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            program = {
              lua = "lua5.1", -- luajit
              file = "${file}",
            },
            args = {},
          },
        }
      end,
    },
  },
})

-------------------------------------------------------------------------------

vim.g.mapleader = " "
vim.opt.number = true
vim.cmd("cd case")

vim.api.nvim_create_user_command("RunCase", function()
  vim.cmd("make")
  vim.cmd("edit tests/foo_spec.lua")

  local dap = require("dap")
  local neotest = require("neotest")
  neotest.summary.toggle()
  neotest.output_panel.toggle()
end, {})

vim.notify("Use `:make lua-dap` to install the local-lua-debugger-vscode. Use `:RunCase` to set the environment")
