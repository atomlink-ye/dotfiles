local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.font = wezterm.font('Maple Mono Normal NF CN', { weight = 'DemiBold' })
config.font_size = 18

config.initial_cols = 80
config.initial_rows = 20

return config
