function love.conf(t)
  t.identity = 'age-stuff'
  t.version = '11.1'
  t.accelerometerjoystick = false
  t.externalstorage = true
  t.gammacorrect = true

  local w = t.window
  w.title = "Tests"
  w.icon = nil
  w.width = 960
  w.height = 720
  w.minwidth = 320
  w.minheight = 240
  w.resizable = true
  w.fullscreentype = 'desktop'
  w.fullscreen = false
  w.usedpiscale = false
  w.hidpi = true
end
