local wezterm = require 'wezterm'

return {
  -- Set initial window size (columns x rows)
  initial_cols = 100,
  initial_rows = 25,

  -- Font and size
  font = wezterm.font('Maple Mono Normal NF CN', {weight = 'DemiBold'}),
  font_size = 18.0,
  harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },

  -- Optional: nice window padding
  window_padding = {
    left = 8,
    right = 8,
    top = 4,
    bottom = 4,
  },
}
