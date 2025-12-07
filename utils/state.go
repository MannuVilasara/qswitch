package utils

import (
	"os"
	"path/filepath"
	"strings"
)

var stateFile = os.Getenv("HOME") + "/.switch_state"
var panelPidFile = os.Getenv("HOME") + "/.qswitch_panel_pid"

func ReadState() string {
	data, err := os.ReadFile(stateFile)
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(data))
}

func WriteState(f string) { os.WriteFile(stateFile, []byte(f), 0644) }

// IsFlavourInstalled checks if a flavour configuration exists
// A flavour is installed if it has a directory in /etc/xdg/quickshell/<flavour>
// or ~/.config/quickshell/<flavour>
func IsFlavourInstalled(flavour string) bool {
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

// CheckFirstRun checks if state file exists
// Returns true if setup is needed (never run before)
func CheckFirstRun() bool {
	// Skip check if user has already run qswitch before (state file exists)
	if _, err := os.Stat(stateFile); err == nil {
		return false
	}
	return true
}