--[[
-- Table that implements input methods
-- in stdin
--]]
local stdin_input = {}

--[[
-- Method to get the move from the current player
--]]
stdin_input.get_move = function(self)
  local row, col = io.read("*n", "*n")
  return row, col
end

return stdin_input
