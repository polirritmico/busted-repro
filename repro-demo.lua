vim.env.LAZY_STDPATH = ".reprodemo"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

local function config_local_lua_dap()
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
        lua = "lua5.1", -- lua = "luajit",
        file = "${file}",
      },
      args = {},
    },
  }
end

Lvl = 3

---@diagnostic disable [missing-fields]
require("lazy.minit").repro({
  spec = {
    {
      "mfussenegger/nvim-dap",
      version = "*",
      -- stylua: ignore
      keys = {
        { "<leader>3", function()
            require("dap").continue()
            vim.notify("Use <space>3 again. After the error go to line 12", Lvl)
          end
        },
        { "<leader>5", function()
            require("dap").continue()
            vim.notify("The test pass. Now use <space>6 to see how the errors disappear with neotest.run.run(vim.fn.expand('%'))", 3)
          end
        },
      },
      config = config_local_lua_dap,
    },
    {
      "nvim-neotest/neotest",
      dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "MisanthropicBit/neotest-busted",
      },
      -- stylua: ignore
      keys = {
        { "<leader>1", function()
            require("neotest").run.run(vim.fn.expand("%"))
            vim.notify("Wait until finish (all ok). Use <space>2 to run the same now in debug mode (should stop on the breakpoint).", Lvl)
          end, desc = "neotest: Run all test in the current file"
        },
        { "<leader>2", function()
            require("neotest").run.run({strategy = "dap"})
            vim.notify("This line is going to fail. Use <space>3 twice to check the error.", Lvl)
          end, desc = "neotest: Debug nearest test"
        },
        { "<leader>4", function()
            vim.cmd("normal! 13gg")
            require("neotest").run.run({strategy = "dap"})
            vim.notify("This is going to work fine. Use <space>5 to check it.", Lvl)
          end, desc = "neotest: Debug nearest test"
        },
        { "<leader>6", function()
            require("neotest").run.run(vim.fn.expand("%"))
            vim.notify("And the fail is gone. Check the 'repro.lua' file for a regular repro environment or use the case itself.", 3)
          end,
        },
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
        opts.adapters = { require("neotest-busted")(opts.busted) }
        require("neotest").setup(opts)
      end,
    },
  },
})

-------------------------------------------------------------------------------

vim.g.mapleader = " "
vim.opt.number = true
vim.cmd("cd case")

vim.api.nvim_create_user_command("Make", function()
  if vim.fn.executable("npm") == 1 then
    vim.cmd("make lua-dap")
    vim.notify("Done. Use `:RunCase` to set the environment", Lvl)
  else
    vim.notify("npm is not available. Install local-lua-debugger-vscode manually", Lvl)
  end
end, {})

vim.api.nvim_create_user_command("RunCase", function()
  vim.cmd("make")
  vim.cmd("edit tests/foo_spec.lua")

  local dap = require("dap")
  local neotest = require("neotest")
  neotest.summary.toggle()
  neotest.output_panel.toggle()

  vim.cmd("normal! 13gg")
  dap.toggle_breakpoint()

  vim.cmd("normal! 4gg")
  dap.toggle_breakpoint()

  vim.notify("All set. Use <space>1 to execute neotest.run.run(vim.fn.expand('%')). Should work ok", Lvl)
end, {})

vim.notify("Use `:Make` and then `:RunCase` to set the environment", Lvl)
