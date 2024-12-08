#!/usr/bin/env lua

local stdout_display = require('stdout')
local stdin_input = require('stdin')
local player = require('player')
local ai = require('ai')
local board = require('board')

-- -------------------
-- Tic Tac Toe game
-- -------------------

--[[
-- Board initialization
--]]
local b = board:new({
  size = 3,
  cells = {
    {"-", "-", "-"},
    {"-", "-", "-"},
    {"-", "-", "-"}
  }
})

--[[
-- AI input
--]]
local ai_input = ai:new(b)

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
  board = b,
  current_player = player_1,

  display = nil,

  winner = nil,
  draw = false
}

--[[
-- Method to verify if game is over by draw or win
--]]
game.is_over = function(self)
  if self.board:has_winner(self.current_player.symbol) then
    self.winner = self.current_player
    return true
  end

  self.draw = self.board:is_draw()
  if self.draw then return true end

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
-- Method to ask the current player move
--]]
game.ask_player_move = function(self)
  self.display:ask_move()
  local row, col = self.current_player:get_move(self.current_player.symbol)

  if not self.board:validate_move(row, col) then
    self.display:invalid_move(row, col)
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

  self.board:update(move.row, move.col, self.current_player.symbol)
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
play = function()
  game.display = stdout_display
  if not game.display then error("display methods not set") end

  while true do
    game.display:show(game.current_player.symbol, game.board)
    game:player_turn()

    if game:is_over() then
      game.display:finish_screen(game.board, game.winner)

      break
    end

    game:switch_player()
  end
end


-------------------------------
--- ^ GAME ^
--- v TESTING STUFF v
-------------------------------

-- play()

local buffer_display = require('buffer_display')
-- buffer_display:show(player_1.symbol, b)

local game_win = vim.api.nvim_open_win(buffer_display.game_buf, true, buffer_display.game_win_opts)
local input_win = vim.api.nvim_open_win(buffer_display.input_buf, true, buffer_display.input_win_opts)

vim.api.nvim_set_current_win(input_win)
vim.api.nvim_buf_set_lines(buffer_display.game_buf, 0, -1, false, {"1 2 3", "4 5 6", "7 8 9"})
vim.api.nvim_buf_set_lines(buffer_display.input_buf, 0, -1, false, {"Player x turn"})
