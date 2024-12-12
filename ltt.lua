local ui = require('ui')
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
local player_1 = player:new("x", ui)
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
-- ui: the ui methods
-- input: the input methods
--]]
local M = {
  board = b,
  current_player = player_1,

  ui = ui:new(),

  winner = nil,
  draw = false
}

--[[
-- Method to verify if game is over by draw or win
--]]
M._is_over = function(self)
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
M._switch_player = function(self)
  if self.current_player == player_1 then
    self.current_player = player_2
  else
    self.current_player = player_1
  end
end

--[[
-- Method to make a move. It is called when the player
-- makes a move, and it is responsible to update the
-- game state and the UI.
--]]
local make_move = function()
  local position = M.ui:get_valid_position()
  if position.error then return end

  local row, col = position.row, position.col

  M.board:update(row, col, M.current_player.symbol)
  if M:_is_over() then
    if M.winner then
      M.ui:winner_screen(M.board, M.winner.symbol)
      return
    end

    M.ui:draw_screen(M.board)
    return
  end
  M:_switch_player()

  M.ui:draw(M.current_player.symbol, M.board)
end

--[[
-- Method to quit the game
--]]
local quit = function()
  vim.api.nvim_win_close(M.ui.board_win, true)
end

M.start = function(self)
  self.ui:open_win()

  self.ui:set_game_keymaps({
    ["<CR>"] = make_move,
    ["q"] = quit
  })

  self.ui:draw(self.current_player.symbol, self.board)
end

return M
