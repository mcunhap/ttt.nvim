local ai = {}

ai.new = function(self, board)
  local a = {
    board = board
  }
  setmetatable(a, self)
  self.__index = self
  return a
end

local possible_moves = function(board)
  local moves = {}

  for i = 1, board.size do
    for j = 1, board.size do
      if board.cells[i][j] == "-" then
        table.insert(moves, {i, j})
      end
    end
  end

  return moves
end

ai.get_move = function(self)
  local moves = possible_moves(self.board)
  local move = moves[math.random(#moves)]

  return move[1], move[2]
end

return ai
