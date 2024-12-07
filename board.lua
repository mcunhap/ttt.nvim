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

  if not b.move then
    b.move = {
      count = 0,
      last = { row = -1, col = -1 },
      -- TODO: make it generic for any board size
      row_ctrl = { 0, 0, 0 },
      col_ctrl = { 0, 0, 0 },
      diag_ctrl = { 0 },
      anti_diag_ctrl = { 0 },
    }
  end

  b.last_state = {}

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
-- Method to update the game board and auxiliar data
--]]
board.update = function(self, row, col, symbol)
  self:save_last_state()

  -- update last move
  self.move.last.row = row
  self.move.last.col = col

  -- update move count
  self.move.count = self.move.count + 1

  -- update cells
  self.cells[row][col] = symbol

  self:update_move_ctrl(row, col, symbol)
end

board.save_last_state = function(self)
  self.last_state = {
    cells = self.cells,
    move = {
      count = self.move.count,
      last = { row = self.move.last.row, col = self.move.last.col },
      row_ctrl = { self.move.row_ctrl[1], self.move.row_ctrl[2], self.move.row_ctrl[3] },
      col_ctrl = { self.move.col_ctrl[1], self.move.col_ctrl[2], self.move.col_ctrl[3] },
      diag_ctrl = { self.move.diag_ctrl[1] },
      anti_diag_ctrl = { self.move.anti_diag_ctrl[1] }
    }
  }
end

board.recovery_last_state = function(self)
  self.cells = self.last_state.cells
  self.move = {
    count = self.last_state.move.count,
    last = { row = self.last_state.move.last.row, col = self.last_state.move.last.col },
    row_ctrl = { self.last_state.move.row_ctrl[1], self.last_state.move.row_ctrl[2], self.last_state.move.row_ctrl[3] },
    col_ctrl = { self.last_state.move.col_ctrl[1], self.last_state.move.col_ctrl[2], self.last_state.move.col_ctrl[3] },
    diag_ctrl = { self.last_state.move.diag_ctrl[1] },
    anti_diag_ctrl = { self.last_state.move.anti_diag_ctrl[1] }
  }
end

board.stats = function(self)
  print("Move count: " .. self.move.count)
  print("Last move: " .. self.move.last.row .. ", " .. self.move.last.col)
  print("Row control: " .. self.move.row_ctrl[1] .. ", " .. self.move.row_ctrl[2] .. ", " .. self.move.row_ctrl[3])
  print("Col control: " .. self.move.col_ctrl[1] .. ", " .. self.move.col_ctrl[2] .. ", " .. self.move.col_ctrl[3])
  print("Diag control: " .. self.move.diag_ctrl[1])
  print("Anti diag control: " .. self.move.anti_diag_ctrl[1])
  print("*****")
  for i = 1, self.size do
    print(table.concat(self.cells[i], " "))
  end
  print("*****")
end

return board
