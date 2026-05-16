

hl.unbind("SUPER + SHIFT + N")
hl.bind("SUPER + Tab", hl.dsp.exec_cmd("dms ipc call spotlight toggle"))
hl.bind("SUPER + N", hl.dsp.exec_cmd("dms ipc call widget toggle controlCenterButton"))
hl.bind("SUPER + A", hl.dsp.exec_cmd("dms ipc call widget toggle clock"))
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("dms ipc call notepad toggle"))

hl.bind("CTRL + SUPER + T", hl.dsp.exec_cmd("dms ipc call dankdash wallpaper"))
hl.bind("SUPER + V", hl.dsp.exec_cmd("dms ipc call clipboard toggle"))
hl.bind("SUPER + J", hl.dsp.exec_cmd("dms ipc call bar toggle index 0"))
hl.bind("SUPER + L", hl.dsp.exec_cmd("$dms ipc call lock lock"))
hl.bind("SUPER + I", hl.dsp.exec_cmd("dms ipc call settings toggle"))

