local xenon = "qs -c xenon ipc call "

--  unbind = Super, T
hl.bind("SUPER + Tab", hl.dsp.exec_cmd(xenon .. "launcher toggle"))
hl.bind("SUPER + V", hl.dsp.exec_cmd(xenon .. "clipboard toggle"))
hl.bind("CTRL + SUPER + T", hl.dsp.exec_cmd(xenon .. "wallpaperpanel toggle"))
hl.bind("SUPER + A", hl.dsp.exec_cmd(xenon .. "sidePanel toggle"))
hl.bind("SUPER + CTRL + L", hl.dsp.exec_cmd(xenon .. "sidePanel toggleLock"))
hl.bind("SUPER + L", hl.dsp.exec_cmd(xenon .. "lock lock"))
--  bind = Super, T, exec, foot
