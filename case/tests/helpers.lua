local H = {}

function H.read(fn)
  return "output: " .. fn()
end

return H
