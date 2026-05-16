--  caelestia keybindings configuration file


hl.bind("SUPER + Tab", hl.dsp.global("caelestia:launcher"))
hl.bind("SUPER + catchall", hl.dsp.global("caelestia:launcherInterrupt"))
hl.bind("SUPER + mouse:272", hl.dsp.global("caelestia:launcherInterrupt"))
hl.bind("SUPER + mouse:273", hl.dsp.global("caelestia:launcherInterrupt"))
hl.bind("SUPER + mouse:274", hl.dsp.global("caelestia:launcherInterrupt"))
hl.bind("SUPER + mouse:275", hl.dsp.global("caelestia:launcherInterrupt"))
hl.bind("SUPER + mouse:276", hl.dsp.global("caelestia:launcherInterrupt"))
hl.bind("SUPER + mouse:277", hl.dsp.global("caelestia:launcherInterrupt"))
hl.bind("SUPER + mouse_up", hl.dsp.global("caelestia:launcherInterrupt"))
hl.bind("SUPER + mouse_down", hl.dsp.global("caelestia:launcherInterrupt"))
hl.bind("CTRL + SUPER + Space", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
hl.bind("CTRL + SUPER + Equal", hl.dsp.global("caelestia:mediaNext"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.global("caelestia:mediaNext"), { locked = true })
hl.bind("CTRL + SUPER + Minus", hl.dsp.global("caelestia:mediaPrev"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.global("caelestia:mediaPrev"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.global("caelestia:mediaStop"), { locked = true })
hl.bind("SUPER + CTRL + ALT + U", hl.dsp.exec_cmd("~/.local/bin/switch.sh"))
hl.bind("SUPER + V", hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard"))
hl.bind("SUPER + ALT + V", hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard -d"))
hl.bind("SUPER + Period", hl.dsp.exec_cmd("pkill fuzzel || caelestia emoji -p"))
--  bindl = Ctrl+Shift+Alt, V, exec, sleep 0.5s && ydotool type -d 1 "$(cliphist list | head -1 | cliphist decode)"  # Alternate paste
hl.bind("SUPER + A", hl.dsp.global("caelestia:showall"))
--  unbind= Super, C
hl.bind("SUPER + C", hl.dsp.global("caelestia:clearNotifs"))
