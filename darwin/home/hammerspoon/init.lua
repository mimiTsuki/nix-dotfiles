hs.hotkey.bind({"alt"}, "space", function()
  local wezterm = hs.application.find('com.github.wez.wezterm')
  if wezterm and wezterm:isFrontmost() then
    wezterm:hide()
  else
    hs.application.launchOrFocusByBundleID('com.github.wez.wezterm')
  end
end)
