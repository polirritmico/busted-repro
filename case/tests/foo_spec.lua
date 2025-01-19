describe("local-lua-debugger-vscode", function()
  it("should load helpers in the correct path", function()
    local foo = require("foo")
    local helpers = require("tests.helpers") -- failing point
    local output = helpers.read(foo.bar)
    assert("output: bar", output)
  end)

  it("this works", function()
    local foo = require("foo")
    local helpers = require("helpers")
    -- This works. With the cursor here use <space>4 and <space>5 to check it
    local output = helpers.read(foo.bar)
    assert("output: bar", output)
  end)
end)
