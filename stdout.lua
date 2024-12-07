--[[
-- Table that implements display methods
-- in stdout
--]]
local stdout_display = {}

--[[
-- Method to clear the screen
-- ref: https://stackoverflow.com/questions/23187310/how-do-i-clear-the-console-in-a-lua-program
--]]
stdout_display._clear = function(self)
  io.write("\027[H\027[2J")
end

--[[
-- Method to display the game board
--]]
stdout_display._board = function(self, b)
  for i = 1, b.size do
    io.write(table.concat(b.cells[i], " "), "\n")
  end
end

--[[
-- Method to notify the current player turn
--]]
stdout_display._player_turn = function(self, current_player)
  io.write("Player " .. current_player .. " turn\n")
end

--[[
-- Method to display invalid move message
--]]
stdout_display.invalid_move = function(self, row, col)
  io.write("Invalid move: ", row, ' ', col, "\n")
end

--[[
-- Method to ask the current player move
--]]
stdout_display.ask_move = function(self)
  io.write("Enter row and collumn to play (e.g. 1 1): ")
end

--[[
-- Method to display the game state
--]]
stdout_display.show = function(self, current_player, b)
  self:_clear()
  self:_board(b)
  self:_player_turn(current_player)
end

--[[
-- Method to display finish screen
--]]
stdout_display.finish_screen = function(self, b, winner)
  self:_clear()
  self:_board(b)

  if winner then
    io.write("Player " .. winner.symbol .. " wins!\n")
  else
    io.write("It's a draw!\n")
  end
end

return stdout_display
