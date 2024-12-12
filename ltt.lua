local ui = require('ui')
local player = require('player')
local ai = require('ai')
local board = require('board')

-- -------------------
-- Tic Tac Toe game
-- -------------------

--[[
-- AI input
--]]
local ai_input = ai:new(board:new())

--[[
-- Players representation in the game
-- player_1 always starts the game
--]]
local player_1 = player:new("x", ui)
local player_2 = player:new("o", ai_input)

--[[
-- Table that holds the module
--]]
local M = {}

--[[
-- Method to create a new game
-- Game contains:
-- - board: the game board
-- - current_player: the player that is playing
-- - ui: the ui module
-- - winner: the player that won the game
-- - draw: boolean that indicates if the game is a draw
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

M.start = function(self)
  local game = self:new()
  game.ui:open_win()

  game.ui:set_game_keymaps({
    ["<CR>"] = function()
      local position = game.ui:get_valid_position()
      if position.error then return end

      local row, col = position.row, position.col

      game.board:update(row, col, game.current_player.symbol)
      if game:_is_over() then
        if game.winner then
          game.ui:winner_screen(game.board, game.winner.symbol)
          return
        end

        game.ui:draw_screen(game.board)
        return
      end
      game:_switch_player()

      game.ui:draw(game.current_player.symbol, game.board)
    end,
    ["q"] = function()
      game.ui:close_win()
      game.ui:delete_buffer()
    end,
  })

  game.ui:draw(game.current_player.symbol, game.board)
end

-- M:start()
return M
