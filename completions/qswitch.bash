_qswitch_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local flavours="ii caelestia noctalia"

    COMPREPLY=( $(compgen -W "$flavours --help -h" -- "$cur") )
}

complete -F _qswitch_complete qswitch
