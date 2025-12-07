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
