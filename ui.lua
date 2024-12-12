--[[
-- Table that holds floating window dimensions
--]]
local win_dimensions = {
  width = 15,
  height = 4
}

--[[
-- Table that holds the position of window
-- in relation to the editor window
--]]
local position_offset = {
  row = vim.api.nvim_win_get_height(0) / 2 - win_dimensions.height / 2,
  col = vim.api.nvim_win_get_width(0) / 2 - win_dimensions.width / 2,
}

--[[
-- Table that holds the board upeer left position
-- inside the floating window
--]]
local board_position = {
  -- TODO: make it work correctly for any position
  -- respecting the window dimensions
  row = 0,
  col = 0
}

--[[
-- Table that holds the window options
--]]
local board_win_opts = {
    relative = "editor",
    width = win_dimensions.width,
    height = win_dimensions.height,
    row = position_offset.row,
    col = position_offset.col,
    style = "minimal",
    border = "rounded"
}

--[[
-- Table that implements display methods
-- in vim ui
--]]
local ui = {}

ui.new = function(self)
  local board_buf = vim.api.nvim_create_buf(false, true)

  local b = {
    board_buf = board_buf
  }

  setmetatable(b, self)
  self.__index = self

  return b
end

--[[
-- Method to clear the screen
--]]
ui._clear = function(self)
  vim.api.nvim_buf_set_lines(self.board_buf, 0, -1, false, {})
end

--[[
-- Method to display the game board
--]]
ui._board = function(self, b)
  for i = 1, b.size do
    vim.api.nvim_buf_set_lines(self.board_buf, board_position.row + (i - 1), -1, false, {table.concat(b.cells[i], " ")})
  end
end

--[[
-- Method to notify the current player turn
--]]
ui._player_turn = function(self, current_player, b)
  vim.api.nvim_buf_set_lines(self.board_buf, board_position.row + b.size + 1, -1, false, {"Player " .. current_player .. " turn"})
end

--[[
-- Method to open the game window
--]]
ui.open_win = function(self)
  self.board_win = vim.api.nvim_open_win(self.board_buf, true, board_win_opts)
end

--[[
-- Method to display error
--]]
ui.display_error = function(self, message)
  -- TODO: display message in board buffer
  print(message)
end

--[[
-- Method to draw the game state
--]]
ui.draw = function(self, current_player, b)
  self:_clear()
  self:_board(b)
  self:_player_turn(current_player, b)
end

--[[
-- Method to set keymaps for the game
--]]
ui.set_game_keymaps = function(self, keymaps)
  for lhs, rhs in pairs(keymaps) do
    local callback = type(rhs) == 'function' and rhs or nil
    vim.api.nvim_buf_set_keymap(self.board_buf,
                                'n',
                                lhs,
                                callback and "" or rhs,
                                {noremap = true, silent = true, callback = callback})
  end
end

--[[
-- Method to get the cursor position
--]]
ui.get_cursor = function(self)
  return vim.api.nvim_win_get_cursor(0)
end

--[[
-- Method to verify if the cursor is in a valid board position
--]]
ui.cursor_in_valid_board_position = function(self, cursor)
  -- TODO: make it valid rows and cols correctly
  -- when adjust board position configuration
  -- now its hardcoded for board with upper left position
  -- in row 1 and col 0 (remember that cursor is (1,0)-indexed)
  local valid_rows = {
    [1] = true,
    [2] = true,
    [3] = true,
  }

  local valid_cols = {
    [0] = true,
    [2] = true,
    [4] = true,
  }

  local row, col = unpack(cursor)
  return valid_rows[row] and valid_cols[col]
end

--[[
-- Method to get the character under the cursor
--]]
ui.get_character_under_cursor = function(self, cursor)
  local row, col = unpack(cursor)
  return vim.api.nvim_buf_get_text(self.board_buf, row - 1, col, row - 1, col + 1, {})[1]
end

--[[
-- Method to convert cursor position to board position
-- Board can be placed in custom position inside a buffer
-- so we need to map which cursor position is related to which board position
--]]
ui.convert_cursor_to_board_position = function(self, cursor)
  local row, col = unpack(cursor)

  -- remember that cursor position is (1,0)-indexed
  -- this should be more "inteligent", but it will work for now
  -- since we have only one board configuration
  -- When we evolve board position configuration, we should
  -- make this more generic
  local cursor_to_board = {
    row = {
      [1] = 1,
      [2] = 2,
      [3] = 3
    },
    col = {
      [0] = 1,
      [2] = 2,
      [4] = 3
    }
  }

  return cursor_to_board.row[row], cursor_to_board.col[col]
end

--[[
-- Method to display winner screen
--]]
ui.winner_screen = function(self, b, winner)
  self:_clear()
  self:_board(b)

  vim.api.nvim_buf_set_lines(self.board_buf, board_position.row + b.size + 1, -1, false, {"Player " .. winner .. " wins!"})
end

--[[
-- Method to display draw screen
--]]
ui.draw_screen = function(self, b)
  self:_clear()
  self:_board(b)

  vim.api.nvim_buf_set_lines(self.board_buf, board_position.row + b.size + 1, -1, false, {"It's a draw!"})
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

return ui
