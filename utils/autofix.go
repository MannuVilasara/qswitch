// this file checks and applies autofix for known issues
package utils

import (
	"fmt"
	"os"
	"path/filepath"
)

var qswitchCacheDir = filepath.Join(os.Getenv("HOME"), ".cache", "qswitch")
var hyprlandFile = filepath.Join(os.Getenv("HOME"), ".config", "hypr", "hyprland.conf")
var qswitchDir = filepath.Join(os.Getenv("HOME"), ".config", "qswitch")

// ApplyAutofix checks for known issues and applies fixes

func ApplyAutofix() {
	fmt.Println("Checking for autofixes...")

	fmt.Print(qswitchCacheDir, "\n", hyprlandFile, "\n", qswitchDir)
}
