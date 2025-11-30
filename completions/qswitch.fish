set -l flavours
if command -q qswitch
    set flavours (qswitch --help 2>/dev/null | awk '/Available flavours:/{flag=1; next} flag && /^  /{print $1} /^$/{exit}')
else
    set flavours ii caelestia noctalia
end

complete -c qswitch --erase

complete -c qswitch -f -a "$flavours" -d "Available flavours"

complete -c qswitch -l help -d "Show help"
complete -c qswitch -s h -d "Show help"
complete -c qswitch -l list -d "List available flavours"
