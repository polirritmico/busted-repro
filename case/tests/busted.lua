#!/usr/bin/env -S nvim -l

vim.env.LAZY_STDPATH = ".tests"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

-- Setup lazy.nvim
require("lazy.minit").busted({
  spec = {},
})


-- BUG: The path must be added to run the tests with local-lua-debugger.
-- As a workaround I've tried this, but it runs only on the non-dap strategy.
package.path = package.path .. ";" .. vim.uv.cwd() .. "/?.lua"
print("updated path:")
print(package.path)
