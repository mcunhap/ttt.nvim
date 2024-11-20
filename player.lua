--[[
-- Table that implements player methods
--]]
local player = {}

--[[
-- Method to create a new player
-- symbol: the symbol of the player
-- input: table with input methods
--]]
player.new = function(self, symbol, input)
  local p = {
    symbol = symbol,
    input = input
  }
  setmetatable(p, self)
  self.__index = self
  return p
end

--[[
-- Method to get the move from the current player
--]]
player.get_move = function(self)
  return self.input:get_move()
end

return player
