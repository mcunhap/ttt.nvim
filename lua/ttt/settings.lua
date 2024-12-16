--[[
-- Table that holds plugin settings
--]]
local settings = {}

--[[
-- Default settings
--]]
settings.DEFAULT_SETTINGS = {
  player_1_symbol = 'x',
  player_2_symbol = 'o',

  play_against_ai = true
}
settings.current = settings.DEFAULT_SETTINGS

--[[
-- Method to set the settings
-- @param opts: the settings to be set
--]]
settings.set = function(opts)
  settings.current = vim.tbl_deep_extend('force', vim.deepcopy(settings.current), opts)
end

return settings
