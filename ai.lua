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

-- local board_copy = function(board)
--   local cells = {}
--   for i = 1, board.size do
--     cells[i] = {}
--     for j = 1, board.size do
--       cells[i][j] = board.cells[i][j]
--     end
--   end

--   return board:new({
--     size = board.size,
--     cells = cells,
--     move = {
--       count = board.move.count,
--       last = { row = board.move.last.row, col = board.move.last.col },
--       row_ctrl = { board.move.row_ctrl[1], board.move.row_ctrl[2], board.move.row_ctrl[3] },
--       col_ctrl = { board.move.col_ctrl[1], board.move.col_ctrl[2], board.move.col_ctrl[3] },
--       diag_ctrl = { board.move.diag_ctrl[1] },
--       anti_diag_ctrl = { board.move.anti_diag_ctrl[1] }
--     }
--   })
-- end

local function minimax(board, symbol)
  if board:is_draw() then return 0 end
  if board:has_winner('x') then return 1 end
  if board:has_winner('o') then return -1 end

  if symbol == 'x' then
    local best_score = -2

    for i = 1, board.size do
      for j = 1, board.size do
        if board:validate_move(i, j) then
          board:update(i, j, symbol)
          best_score = math.max(best_score, minimax(board, 'o'))
          board:update(i, j, "-")
        end
      end
    end

    return best_score
  end

  local best_score = 2

  for i = 1, board.size do
    for j = 1, board.size do
      if board:validate_move(i, j) then
        board:update(i, j, symbol)
        best_score = math.min(best_score, minimax(board, 'x'))
        board:update(i, j, "-")
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
        self.board:update(i, j, symbol)
        local score = minimax(self.board, symbol == 'x' and 'o' or 'x')
        self.board:update(i, j, "-")

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
