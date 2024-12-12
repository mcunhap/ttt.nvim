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
local game = {
  board = b,
  current_player = player_1,

  ui = ui:new(),

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

-- new game: create a new game with initial configuration displayed in a new game buffer
--    we should display the board and current player
-- make move: walk in buffer row and collumns and press some key to make a move in that position
--    we should validate the move: valid board position and empty cell
-- update board: update the board with the move made by the player
-- check winner: check if the current player won the game
-- check draw: check if the game is a draw
-- switch player: switch the current player if the game is not over

game.start = function(self)
  game.ui:open_win()

  game.ui:set_game_keymaps({
    ["<CR>"] = function()
      local cursor = game.ui:get_cursor()
      if not game.ui:cursor_in_valid_board_position(cursor) then
        game.ui:display_error("Invalid board position")
        return
      end

      local char = game.ui:get_character_under_cursor(cursor)
      if char ~= "-" then
        game.ui:display_error("Invalid move")
        return
      end

      local row, col = game.ui:convert_cursor_to_board_position(cursor)

      game.board:update(row, col, game.current_player.symbol)
      game:switch_player()
      if game:is_over() then
        if game.winner then
          game.ui:winner_screen(game.winner.symbol)
          return
        else
          print("It's a draw!")
        end
        return
      end

      game.ui:draw(game.current_player.symbol, game.board)

      -- game.current_player:make_move(game.board)
      -- game.ui:draw(game.current_player.symbol, game.board)
      -- game:switch_player()
    end
  })

  self.ui:draw(self.current_player.symbol, self.board)
end

game:start()
-- return game
