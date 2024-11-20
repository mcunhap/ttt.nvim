#!/usr/bin/env lua
local stdout_display = require('./stdout')
local stdin_input = require('./stdin')
local player = require('./player')
local ai = require('./ai')

-- -------------------
-- Tic Tac Toe game
-- -------------------

--[[
-- Table that holds the game board
-- size: the size of the board
-- cells: the cells of the board
--]]
local board = {
  size = 3,
  cells = {
    {"-", "-", "-"},
    {"-", "-", "-"},
    {"-", "-", "-"}
  }
}

--[[
-- AI input
--]]
local ai_input = ai:new(board)

--[[
-- Players representation in the game
-- player_1 always starts the game
--]]
local player_1 = player:new("x", stdin_input)
local player_2 = player:new("o", ai_input)

--[[
-- Table that holds the game state
-- board: the game board
-- current_player: the player that is currently playing
-- move: the move information
--  count: the number of moves made
--  last: the last move made
--  row_ctrl: the control map for the rows
--  col_ctrl: the control map for the columns
--  diag_ctrl: the control map for the diagonal
--  anti_diag_ctrl: the control map for the anti-diagonal
-- display: the display methods
-- input: the input methods
--]]
local game = {
  board = board,
  current_player = player_1,

  move = {
    count = 0,
    last = { row = nil, col = nil },
    -- TODO: make it generic for any board size
    row_ctrl = { 0, 0, 0 },
    col_ctrl = { 0, 0, 0 },
    diag_ctrl = { 0 },
    anti_diag_ctrl = { 0 },
  },

  display = nil,

  winner = nil,
  draw = false
}

--[[
-- Method to verify and update if the board is a draw
-- ]]
game.check_draw = function(self)
  self.draw = self.move.count == self.board.size * self.board.size
end

--[[
-- Method to verify if the board has a winner
-- If we know the last move was made by the current player, we can
-- check only the row, column and diagonal that the last move was made
--]]
game.check_winner = function(self)
  local row = self.move.last.row
  local col = self.move.last.col
  local winner_value = self.board.size

  if self.current_player == player_2 then
    winner_value = -self.board.size
  end

  if self.move.row_ctrl[row] == winner_value or
    self.move.col_ctrl[col] == winner_value or
    self.move.diag_ctrl[1] == winner_value or
    self.move.anti_diag_ctrl[1] == winner_value then
    self.winner = self.current_player
  end
end

--[[
-- Method to verify if game is over by draw or win
--]]
game.is_over = function(self)
  game:check_draw()
  if self.draw then return true end

  game:check_winner()
  if self.winner then return true end

  return false
end

--[[
-- Method to switch current player
--]]
game.switch_player = function(self)
  if self.current_player == player_1 then
    self.current_player = player_2
  else
    self.current_player = player_1
  end
end

--[[
-- Method to validate the move
--]]
game.validate_move = function(self, row, col)
  if row <= 0 or row > self.board.size then return false end
  if col <= 0 or col > self.board.size then return false end
  if self.board.cells[row][col] ~= "-" then return false end

  return true
end

--[[
-- Method to update the last move
--]]
game.update_last_move = function(self, row, col)
  self.move.last.row = row
  self.move.last.col = col
end

--[[
-- Method to update the game board
--]]
game.update_board = function(self, row, col)
  self.board.cells[row][col] = self.current_player.symbol
end

--[[
-- Method to update the move count
--]]
game.update_move_count = function(self)
  self.move.count = self.move.count + 1
end

--[[
-- Method to update the move control maps
-- The control maps are used to check if the current player won the game
-- by checking the rows, columns, diagonal and anti-diagonal
-- The control maps are updated by adding 1 for player 1 and subtracting 1 for player 2
-- When the control map value is equal to the board size, the player 1 wins
--]]
game.update_move_ctrl = function(self, row, col)
  local value = 1
  if self.current_player == player_2 then
    value = -1
  end

  self.move.row_ctrl[row] = self.move.row_ctrl[row] + value
  self.move.col_ctrl[col] = self.move.col_ctrl[col] + value

  if row == col then
    self.move.diag_ctrl[1] = self.move.diag_ctrl[1] + value
  end

  if row + col == self.board.size + 1 then
    self.move.anti_diag_ctrl[1] = self.move.anti_diag_ctrl[1] + value
  end
end

--[[
-- Method to ask the current player move
--]]
game.ask_player_move = function(self)
  self.display.ask_move()
  local row, col = self.current_player:get_move()

  if not game:validate_move(row, col) then
    self.display.invalid_move()
    return nil
  end

  return { row = row, col = col }
end

--[[
-- Method to execute current player turn
--]]
game.player_turn = function(self)
  local move = nil

  while not move do
    move = game:ask_player_move()
  end

  game:update_last_move(move.row, move.col)
  game:update_move_count()
  game:update_move_ctrl(move.row, move.col)
  game:update_board(move.row, move.col)
end

--[[
-- 0. Display player turn
-- 1. Display the game board
-- 2. Execute player turn
--   2.1. Ask the current player to play
--   2.2. Validate the move
--    2.2.1. Go back to step 1.1 if the move is invalid
--    2.2.2. Follow the next steps if the move is valid
--   2.3. Update the game board
-- 3. Check if the game is over
--   3.1. If the game is over, display the finish message
--   3.2. Follow the next steps
-- 4. Switch the current player
-- 5. Clear the screen
--]]

game.display = stdout_display
if not game.display then error("display methods not set") end

while true do
  game.display.show(game.current_player.symbol, game.board)
  game:player_turn()

  if game:is_over() then
    game.display.finish_screen(game.board, game.winner)

    break
  end

  game:switch_player()
end
