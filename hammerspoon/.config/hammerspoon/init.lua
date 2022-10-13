hs.hotkey.bind({"option"}, "`", function()
  local terminal = hs.application.find('kitty')

  if terminal and terminal:isFrontmost() then
    terminal:hide()
  else
    hs.application.open("/Applications/Kitty.app")
  end
end)

function terminalWatcher(appName, eventType, appObject)
  if (eventType == hs.application.watcher.deactivated) then
      if (appName == "Kitty") then
        local terminal = hs.application.find('kitty')
        terminal:hide()
      end
  end
end

local appWatcher = hs.application.watcher.new(terminalWatcher)
appWatcher:start()
