package utils

import (
	"fmt"
)

func ShowSetupMessage() {
	fmt.Println(`
⚠️  qswitch Setup Required

This appears to be your first time running qswitch.

This tool requires proper setup to work correctly.
please run qswitch exp-setup to set it up.

After setup, you can run qswitch normally.

To bypass this message (not recommended), use the --itrustmyself flag.`)
}

func Help(config Config) {
	fmt.Println(`Usage:
  qswitch <flavour>       Switch to a specific flavour
  qswitch                 Cycle to the next flavour

Available flavours:`)
	for _, f := range config.Flavours {
		fmt.Println("  " + f)
	}
	fmt.Println(`
Options:
  --help, -h             Show this help message
  --list                 List available flavours
  --current              Show current flavour
  --panel                Toggle panel
  apply --current        Apply current flavour configuration
  --itrustmyself         Bypass setup check (use with caution)
  --switch-keybinds      Switch only keybinds for a flavour`)
}