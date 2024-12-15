local ui = require('ttt.ui')
local board = require('ttt.board')
local ai = require('ttt.ai')

-- -------------------
-- Tic Tac Toe game
-- -------------------

--[[
-- Players representation in the game
-- player_1 always starts the game
--]]
local player_1 = 'x'
local player_2 = 'o'

--[[
-- Table that holds the module
--]]
local M = {}

--[[
-- Method to create a new game
--
-- Game contains:
-- @board: the game board
-- @current_player: the player that is playing
-- @ui: the ui module
-- @winner: the player that won the game
-- @draw: boolean that indicates if the game is a draw
-- @return: the new game
--]]
M.new = function(self)
  local o = {
    board = board:new(),
    current_player = player_1,

    ui = ui:new(),

    winner = nil,
    draw = false
  }

  setmetatable(o, self)
  self.__index = self
  return o
end

--[[
-- Method to verify if game is over by draw or win
--
-- @return: boolean indicating if the game is over
--]]
M._is_over = function(self)
  if self.board:has_winner(self.current_player) then
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
    return
  end

  self.current_player = player_1
end

--[[
-- Method to verify if game is over
-- and show the winner screen
--
-- @return: boolean indicating if the game is over
--]]
M._over = function(self)
  if not self:_is_over() then return false end

  if self.winner then
    self.ui:winner_screen(self.board, self.winner)
    return true
  end

  self.ui:draw_screen(self.board)
  return true
end

--[[
-- Method to handle player turn
--]]
M._player_turn = function(self)
  local position = self.ui:get_valid_position()
  if position.error then return end

  local row, col = position.row, position.col

  self.board:update(row, col, self.current_player)
end

--[[
-- Method to handle ai turn
--]]
M._ai_turn = function(self)
  local ai_module = ai:new(self.board)
  local row, col = ai_module:get_move(self.current_player)

  self.board:update(row, col, self.current_player)
end

--[[
-- Method to start the game
--]]
M.start = function(self)
  local game = self:new()
  game.ui:open_win()

  game.ui:set_game_keymaps({
    ["<CR>"] = function()
      if game:_is_over() then return end

      game:_player_turn(game)
      if game:_over(game) then return end
      game:_switch_player()

      game:_ai_turn(game)
      if game:_over(game) then return end
      game:_switch_player()

      game.ui:draw(game.current_player, game.board)
    end,
    ["<ESC>"] = function()
      game.ui:close_win()
      game.ui:delete_buffer()
    end,
    ["q"] = function()
      game.ui:close_win()
      game.ui:delete_buffer()
    end,
  })

  game.ui:draw(game.current_player, game.board)
end

return M
