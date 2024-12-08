--[[
-- Table that implements display methods
-- in vim buffer
--]]
local win_dimensions = {
  game_display = {
    width = 15,
    height = 6
  },
  input_display = {
    width = 20,
    height = 2
  }
}

local position_offset = {
  row = vim.api.nvim_win_get_height(0) / 2 - (win_dimensions.game_display.height + win_dimensions.input_display.height) / 2,
  col = vim.api.nvim_win_get_width(0) / 2 - (win_dimensions.game_display.width + win_dimensions.input_display.width) / 2,
}

local buffer_display = {
  game_win_opts = {
    relative = "editor",
    width = win_dimensions.game_display.width,
    height = win_dimensions.game_display.height,
    row = position_offset.row,
    col = position_offset.col,
    style = "minimal",
    border = "rounded"
  },

  input_win_opts = {
    relative = "editor",
    width = win_dimensions.input_display.width,
    height = win_dimensions.input_display.height,
    row = position_offset.row,
    col = position_offset.col + win_dimensions.game_display.width + 2,
    style = "minimal",
    border = "rounded"
  },

  game_buf = vim.api.nvim_create_buf(false, true),
  input_buf = vim.api.nvim_create_buf(false, true)
}

--[[
-- Method to clear the screen
--]]
buffer_display._clear = function(self)
  vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, {})
end

--[[
-- Method to display the game board
--]]
buffer_display._board = function(self, b)
  for i = 1, b.size do
    vim.api.nvim_buf_set_lines(self.buf, -1, -1, false, {table.concat(b.cells[i], " ")})
  end
end

--[[
-- Method to notify the current player turn
--]]
buffer_display._player_turn = function(self, current_player)
  vim.api.nvim_buf_set_lines(self.buf, -1, -1, false, {"Player " .. current_player .. " turn"})
end

--[[
-- Method to display invalid move message
--]]
-- buffer_display.invalid_move = function(self, row, col)
--   vim.api.nvim_err_writeln("Invalid move: " .. row .. ' ' .. col)
-- end

--[[
-- Method to ask the current player move
--]]
-- buffer_display.ask_move = function(self)
--   vim.api.nvim_out_write("Enter row and collumn to play (e.g. 1 1): ")
-- end

--[[
-- Method to display the game state
--]]
buffer_display.show = function(self, current_player, b)
  game_win_opts = {
    relative = "editor",
    width = 15,
    height = 6,
    row = 5,
    col = 15,
    style = "minimal",
    border = "rounded"
  }
  game_win = vim.api.nvim_open_win(self.buf, true, game_win_opts)

  input_win_opts = {
    relative = "editor",
    width = 20,
    height = 2,
    row = 5,
    col = 15,
    style = "minimal",
    border = "rounded"
  }
  input_win = vim.api.nvim_open_win(self.buf, true, input_win_opts)

  self:_clear()
  self:_board(b)
  self:_player_turn(current_player)
end

--[[
-- Method to display finish screen
--]]
-- stdout_display.finish_screen = function(self, b, winner)
--   self:_clear()
--   self:_board(b)

--   if winner then
--     vim.api.nvim_out_write("Player " .. winner.symbol .. " wins!\n")
--   else
--     vim.api.nvim_out_write("It's a draw!\n")
--   end
-- end

return buffer_display
