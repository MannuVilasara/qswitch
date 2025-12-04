package main

import (
	"os"
	"path/filepath"
	"strings"
)

var stateFile = os.Getenv("HOME") + "/.switch_state"
var panelPidFile = os.Getenv("HOME") + "/.qswitch_panel_pid"

func readState() string {
	data, err := os.ReadFile(stateFile)
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(data))
}

func writeState(f string) { os.WriteFile(stateFile, []byte(f), 0644) }

// isFlavourInstalled checks if a flavour configuration exists
// A flavour is installed if it has a directory in /etc/xdg/quickshell/<flavour>
// or ~/.config/quickshell/<flavour>
func isFlavourInstalled(flavour string) bool {
	// Check in ~/.config/quickshell/<flavour>
	userPath := filepath.Join(os.Getenv("HOME"), ".config", "quickshell", flavour)
	if _, err := os.Stat(userPath); err == nil {
		return true
	}

	// Check in /etc/xdg/quickshell/<flavour>
	systemPath := filepath.Join("/etc/xdg/quickshell", flavour)
	if _, err := os.Stat(systemPath); err == nil {
		return true
	}

	return false
}

// checkFirstRun checks if ii is not installed and no state file exists
// Returns true if setup is needed (ii not installed and never run before)
func checkFirstRun() bool {
	// Skip check if user has already run qswitch before (state file exists)
	if _, err := os.Stat(stateFile); err == nil {
		return false
	}
	return !isFlavourInstalled("ii")
}
