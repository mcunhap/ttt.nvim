--[[
-- Table that holds the game board
-- size: the size of the board
-- cells: the cells of the board
--]]
local board = {}

--[[
-- Method to create a new board
--
-- @return: the new board
--]]
board.new = function(self)
  local b = {}

  b.size = 3
  b.cells = {
    {"-", "-", "-"},
    {"-", "-", "-"},
    {"-", "-", "-"}
  }

  b.move = {
    count = 0,
    last = { row = -1, col = -1 },
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
--
-- @return: boolean indicating if the board is a draw
-- ]]
board.is_draw = function(self)
  return self.move.count == self.size * self.size
end

--[[
-- Method to verify if the board has a winner
-- If we know the last move was made by the current player, we can
-- check only the row, column and diagonal that the last move was made
--
-- @symbol: the symbol to check for
-- @return: boolean indicating if the board has a winner
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
--
-- @row: the row of the move
-- @col: the column of the move
-- @return: boolean indicating if the move is valid
--]]
board.validate_move = function(self, row, col)
  if row <= 0 or row > self.size then return false end
  if col <= 0 or col > self.size then return false end
  if self.cells[row][col] ~= "-" then return false end

  return true
end

--[[
-- Method to update the last move
--
-- @row: the row of the move
-- @col: the column of the move
--]]
board.update_last_move = function(self, row, col)
  self.move.last.row = row
  self.move.last.col = col
end

--[[
-- Method to update the move control maps
-- The control maps are used to check if the current player won the game
-- by checking the rows, columns, diagonal and anti-diagonal
-- The control maps are updated by adding 1 for player 1 and subtracting 1 for player 2
-- When the control map value is equal to the board size, the player 1 wins
--
-- @row: the row of the move
-- @col: the column of the move
-- @symbol: the symbol of the player
-- @return: boolean indicating if the move is valid
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
-- Method to update the game board and auxiliar data
--
-- @row: the row of the move
-- @col: the column of the move
-- @symbol: the symbol of the player
--]]
board.update = function(self, row, col, symbol)
  -- update last move
  self.move.last.row = row
  self.move.last.col = col

  -- update move count
  self.move.count = self.move.count + 1

  -- update cells
  self.cells[row][col] = symbol

  self:update_move_ctrl(row, col, symbol)
end

return board
