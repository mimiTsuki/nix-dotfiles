local wezterm = require 'wezterm'

wezterm.on('toggle-opacity', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if not overrides.window_background_opacity then
    overrides.window_background_opacity = 0.8
  else
    overrides.window_background_opacity = nil
  end
  window:set_config_overrides(overrides)
end)

return {
  automatically_reload_config = true,
  use_ime = true,
  send_composed_key_when_left_alt_is_pressed = true,
  font = wezterm.font 'HackGen',
  font_size = 14.0,
  color_scheme = "Nord (Gogh)",
  colors = {
    background = '#1d1f21',
    tab_bar = {
      inactive_tab_edge = "none",
    },
  },
  keys = {
    { key = 'u', mods = 'SUPER',       action = wezterm.action.EmitEvent 'toggle-opacity' },
    { key = 'd', mods = 'SUPER',       action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { key = 'd', mods = 'SUPER|SHIFT', action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" } },
    { key = 'p', mods = 'SUPER',       action = wezterm.action.PaneSelect },
    { key = 'w', mods = 'SUPER',       action = wezterm.action.CloseCurrentPane { confirm = true } },
    {
      --tabの名前変更
      key = "m",
      mods = "CTRL",
      action = wezterm.action.PromptInputLine({
        description = "(wezterm) Set workspace title:",
        action = wezterm.action_callback(function(win, pane, line)
          if line then
            win:active_tab():set_title(line)
          end
        end),
      }),
    },
    -- コマンドパレット表示
    { key = "p", mods = "SUPER|SHIFT", action = wezterm.action.ActivateCommandPalette },
  },
  show_new_tab_button_in_tab_bar = false,
  show_tabs_in_tab_bar = true,
  window_decorations = "RESIZE",
}
