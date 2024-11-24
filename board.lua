--[[
-- Table that holds the game board
-- size: the size of the board
-- cells: the cells of the board
--]]
local board = {}

board.new = function(self, b)
  if not b.size or not b.cells then
    b.size = 3
    b.cells = {
      {"-", "-", "-"},
      {"-", "-", "-"},
      {"-", "-", "-"}
    }
  end

  b.move = {
    count = 0,
    last = { row = nil, col = nil },
    -- TODO: make it generic for any board size
    row_ctrl = { 0, 0, 0 },
    col_ctrl = { 0, 0, 0 },
    diag_ctrl = { 0 },
    anti_diag_ctrl = { 0 },
  }

  setmetatable(b, self)
  self.__index = self

  return b
end

--[[
-- Method to verify if the board is a draw
-- ]]
board.is_draw = function(self)
  return self.move_count == self.size * self.size
end

--[[
-- Method to verify if the board has a winner
-- If we know the last move was made by the current player, we can
-- check only the row, column and diagonal that the last move was made
--]]
board.has_winner = function(self, symbol)
  local row = self.move.last.row
  local col = self.move.last.col
  local winner_value = self.size

  if symbol == 'o' then
    winner_value = -self.size
  end

  return self.move.row_ctrl[row] == winner_value or
    self.move.col_ctrl[col] == winner_value or
    self.move.diag_ctrl[1] == winner_value or
    self.move.anti_diag_ctrl[1] == winner_value
end

--[[
-- Method to validate the move
--]]
board.validate_move = function(self, row, col)
  if row <= 0 or row > self.size then return false end
  if col <= 0 or col > self.size then return false end
  if self.cells[row][col] ~= "-" then return false end

  return true
end

--[[
-- Method to update the last move
--]]
board.update_last_move = function(self, row, col)
  self.move.last.row = row
  self.move.last.col = col
end

--[[
-- Method to update the move count
--]]
board.update_move_count = function(self)
  self.move.count = self.move.count + 1
end

--[[
-- Method to update the move control maps
-- The control maps are used to check if the current player won the game
-- by checking the rows, columns, diagonal and anti-diagonal
-- The control maps are updated by adding 1 for player 1 and subtracting 1 for player 2
-- When the control map value is equal to the board size, the player 1 wins
--]]
board.update_move_ctrl = function(self, row, col, symbol)
  local value = 1
  if symbol == 'o' then
    value = -1
  end

  self.move.row_ctrl[row] = self.move.row_ctrl[row] + value
  self.move.col_ctrl[col] = self.move.col_ctrl[col] + value

  if row == col then
    self.move.diag_ctrl[1] = self.move.diag_ctrl[1] + value
  end

  if row + col == self.size + 1 then
    self.move.anti_diag_ctrl[1] = self.move.anti_diag_ctrl[1] + value
  end
end

--[[
-- Method to update the board cells
--]]
board.update_cells = function(self, row, col, symbol)
  self.cells[row][col] = symbol
end

--[[
-- Method to update the game board and auxiliar data
--]]
board.update = function(self, move, symbol)
  self:update_last_move(move.row, move.col)
  self:update_move_count()
  self:update_move_ctrl(move.row, move.col, symbol)
  self:update_cells(move.row, move.col, symbol)
end

return board
