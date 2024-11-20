--[[
-- Table that implements display methods
-- in stdout
--]]
local stdout_display = {}

--[[
-- Method to clear the screen
-- ref: https://stackoverflow.com/questions/23187310/how-do-i-clear-the-console-in-a-lua-program
--]]
local clear = function()
  io.write("\027[H\027[2J")
end

--[[
-- Method to display the game board
--]]
local board = function(b)
  for i = 1, b.size do
    io.write(table.concat(b.cells[i], " "), "\n")
  end
end

--[[
-- Method to notify the current player turn
--]]
local player_turn = function(current_player)
  io.write("Player " .. current_player .. " turn\n")
end

--[[
-- Method to display invalid move message
--]]
stdout_display.invalid_move = function()
  io.write("Invalid move\n")
end

--[[
-- Method to ask the current player move
--]]
stdout_display.ask_move = function()
  io.write("Enter row and collumn to play (e.g. 1 1): ")
end

--[[
-- Method to display the game state
--]]
stdout_display.show = function(current_player, b)
  clear()
  board(b)
  player_turn(current_player)
end

--[[
-- Method to display finish screen
--]]
stdout_display.finish_screen = function(b, winner)
  clear()
  board(b)

  if winner then
    io.write("Player " .. winner.symbol .. " wins!\n")
  else
    io.write("It's a draw!\n")
  end
end

return stdout_display
