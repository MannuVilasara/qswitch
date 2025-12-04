complete -c qswitch --erase

complete -c qswitch -f -a "(qswitch --list)" -d "Available flavours"

complete -c qswitch -l help -d "Show help"
complete -c qswitch -s h -d "Show help"
complete -c qswitch -l list -d "List available flavours"
complete -c qswitch -l current -d "Show current flavour"
complete -c qswitch -l panel -d "Toggle panel"
complete -c qswitch -l itrustmyself -d "Bypass setup check"

# apply subcommand
complete -c qswitch -a "apply" -d "Apply configuration"
complete -c qswitch -n "__fish_seen_subcommand_from apply" -l current -d "Apply current flavour"
