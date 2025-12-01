set -l flavours "ii caelestia noctalia"

complete -c qswitch --erase

complete -c qswitch -f -a "$flavours" -d "Available flavours"

complete -c qswitch -l help -d "Show help"
complete -c qswitch -s h -d "Show help"
complete -c qswitch -l list -d "List available flavours"
