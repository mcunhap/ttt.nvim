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

--[[
-- Method to create a new ui instance
-- UI contains:
-- @board_buf: buffer to display the game board
--
-- @return: ui instance
--]]
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
--
-- @b: the game board
--]]
ui._board = function(self, b)
  for i = 1, b.size do
    vim.api.nvim_buf_set_lines(self.board_buf, board_position.row + (i - 1), -1, false, {table.concat(b.cells[i], " ")})
  end
end

--[[
-- Method to notify the current player turn
--
-- @current_player: the current player
-- @b: the game board
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
-- Method to close the game window
--]]
ui.close_win = function(self)
  vim.api.nvim_win_close(self.board_win, true)
end

--[[
-- Method to hide the game window
--]]
ui.hide_win = function(self)
  vim.api.nvim_win_hide(self.board_win)
end

ui.delete_buffer = function(self)
  vim.api.nvim_buf_delete(self.board_buf, {force = true})
end

--[[
-- Method to display error
--
-- @message: the error message
--]]
ui.display_error = function(self, message)
  -- TODO: display message in board buffer
  print(message)
end

--[[
-- Method to draw the game state
--
-- @current_player: the current player
-- @b: the game board
--]]
ui.draw = function(self, current_player, b)
  self:_clear()
  self:_board(b)
  self:_player_turn(current_player, b)
end

--[[
-- Method to set keymaps for the game
--
-- @keymaps: the keymaps to be set
--           keymaps is a table with the following format:
--           {
--            ["<key>"] = "<action>"
--           }
--           where <key> is the key to be mapped
--           and <action> is the action to be performed
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
-- Method to get valid ui position
--
-- @return: a table with the following format:
--         {
--           row: the row position
--           col: the col position
--           error: a boolean indicating if there was an error
--         }
--]]
ui.get_valid_position = function(self)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))

  -- remember that cursor position is (1,0)-indexed
  -- this should be more "inteligent", but it will work for now
  -- since we have only one board configuration
  -- When we evolve board position configuration, we should
  -- make this more generic
  --
  -- make it valid rows and cols correctly
  -- when adjust board position configuration
  -- now its hardcoded for board with upper left position
  -- in row 1 and col 0 (remember that cursor is (1,0)-indexed)
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

  if not cursor_to_board.row[row] or not cursor_to_board.col[col] then
    self:display_error("Invalid board position")
    return {
      row = nil,
      col = nil,
      error = true
    }
  end

  local char = vim.api.nvim_buf_get_text(self.board_buf, row - 1, col, row - 1, col + 1, {})[1]
  if char ~= "-" then
    self:display_error("Invalid move")
    return {
      row = nil,
      col = nil,
      error = true
    }
  end

  return {
    row = cursor_to_board.row[row],
    col = cursor_to_board.col[col],
    error = false
  }
end

--[[
-- Method to display winner screen
--
-- @b: the game board
-- @winner: the winner player
--]]
ui.winner_screen = function(self, b, winner)
  self:_clear()
  self:_board(b)

  vim.api.nvim_buf_set_lines(self.board_buf, board_position.row + b.size + 1, -1, false, {"Player " .. winner .. " wins!"})
end

--[[
-- Method to display draw screen
--
-- @b: the game board
--]]
ui.draw_screen = function(self, b)
  self:_clear()
  self:_board(b)

  vim.api.nvim_buf_set_lines(self.board_buf, board_position.row + b.size + 1, -1, false, {"It's a draw!"})
end

return ui
