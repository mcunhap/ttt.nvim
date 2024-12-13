local display = require("./stdout")

local ai = {}

ai.new = function(self, board)
  local a = {
    board = board
  }
  setmetatable(a, self)
  self.__index = self
  return a
end

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


local function minimax(board, symbol, is_max)
  if is_draw(board) then return 0 end
  if has_winner(board, 'o') then return 1 end
  if has_winner(board, 'x') then return -1 end

  if is_max then
    local best_score = -2

    for i = 1, board.size do
      for j = 1, board.size do
        if board:validate_move(i, j) then
          board.cells[i][j] = symbol
          local score = minimax(board, symbol == 'x' and 'o' or 'x', false)
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
        board.cells[i][j] = symbol
        local score = minimax(board, symbol == 'x' and 'o' or 'x', true)
        board.cells[i][j] = '-'

        if score < best_score then
          best_score = score
        end
      end
    end
  end

  return best_score
end

ai.get_move = function(self, symbol)
  local best_score = -2
  local best_move = { -1, -1 }

  for i = 1, self.board.size do
    for j = 1, self.board.size do
      if self.board:validate_move(i, j) then
        self.board.cells[i][j] = symbol
        local score = minimax(self.board, symbol == 'x' and 'o' or 'x', false)
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
