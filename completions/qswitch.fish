complete -c qswitch --erase

complete -c qswitch -f -a "(qswitch --list)" -d "Available flavours"

complete -c qswitch -l help -d "Show help"
complete -c qswitch -s h -d "Show help"
complete -c qswitch -l list -d "List available flavours"
complete -c qswitch -l current -d "Show current flavour"
complete -c qswitch -l panel -d "Toggle panel"

# apply subcommand
complete -c qswitch -n apply -f -a "--current" -d "Apply current flavour"
