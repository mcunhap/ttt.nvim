local settings = require('ttt.settings').current

--[[
-- Table that holds the ai module
--]]
local ai = {}

--[[
-- Method to create a new ai for a given board
--
-- @board - the board to play on
-- @return - the new ai
--]]
ai.new = function(self, board, symbol, opponent_symbol)
  local a = {
    board = board,
    symbol = symbol,
    opponent_symbol = opponent_symbol
  }
  setmetatable(a, self)
  self.__index = self
  return a
end

--[[
-- Method to check if the game is a draw
--
-- @board - the board to check
-- @return - boolean indicating if the game is a draw
--]]
local is_draw = function(board)
  for i = 1, board.size do
    for j = 1, board.size do
      if board.cells[i][j] == '-' then
        return false
      end
    end
  end

  return true
end

--[[
-- Method to check if the game has a winner
--
-- @board - the board to check
-- @symbol - the symbol to check for
-- @return - boolean indicating if the game has a winner
--]]
local has_winner = function(board, symbol)
  for i = 1, board.size do
    if board.cells[i][1] == board.cells[i][2] and board.cells[i][2] == board.cells[i][3] and board.cells[i][1] == symbol then
      return true
    end
  end

  for i = 1, board.size do
    if board.cells[1][i] == board.cells[2][i] and board.cells[2][i] == board.cells[3][i] and board.cells[1][i] == symbol then
      return true
    end
  end

  if board.cells[1][1] == board.cells[2][2] and board.cells[2][2] == board.cells[3][3] and board.cells[1][1] == symbol then
    return true
  end

  if board.cells[1][3] == board.cells[2][2] and board.cells[2][2] == board.cells[3][1] and board.cells[1][3] == symbol then
    return true
  end

  return false
end

--[[
-- Method to calculate the minimax score
--
-- @board - the board to calculate the score for
-- @symbol - the symbol to calculate the score for
-- @is_max - boolean to indicate if the current player is the maximizer
-- @return - the score
--]]
local function minimax(board, current_player, opponent, is_max)
  if is_draw(board) then return 0 end
  if has_winner(board, settings.player_2_symbol) then return 1 end
  if has_winner(board, settings.player_1_symbol) then return -1 end

  if is_max then
    local best_score = -2

    for i = 1, board.size do
      for j = 1, board.size do
        if board:validate_move(i, j) then
          board.cells[i][j] = current_player
          local score = minimax(board, opponent, current_player, false)
          board.cells[i][j] = '-'

          if score > best_score then
            best_score = score
          end
        end
      end
    end

    return best_score
  end

  local best_score = 2

  for i = 1, board.size do
    for j = 1, board.size do
      if board:validate_move(i, j) then
        board.cells[i][j] = current_player
        local score = minimax(board, opponent, current_player, true)
        board.cells[i][j] = '-'

        if score < best_score then
          best_score = score
        end
      end
    end
  end

  return best_score
end

--[[
-- Method to get the move for the ai
--
-- @ai_symbol - the symbol ai is playing
-- @human_symbol - the symbol human is playing
-- @return - the move row and the move col
--]]
ai.get_move = function(self)
  local best_score = -2
  local best_move = { -1, -1 }

  for i = 1, self.board.size do
    for j = 1, self.board.size do
      if self.board:validate_move(i, j) then
        self.board.cells[i][j] = self.symbol
        local score = minimax(self.board, self.opponent_symbol, self.symbol, false)
        self.board.cells[i][j] = '-'

        if score > best_score then
          best_score = score
          best_move = { i, j }
        end
      end
    end
  end

  return  best_move[1], best_move[2]
end

return ai
