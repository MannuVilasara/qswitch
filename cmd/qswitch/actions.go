package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

func applyKeybinds(flavour string, config Config) {
	// Handle keybinds
	qswitchDir := filepath.Join(os.Getenv("HOME"), ".config", "qswitch")
	os.MkdirAll(qswitchDir, 0755)
	keybindsFile := filepath.Join(qswitchDir, "qswitch.conf")

	var contentParts []string

	// Check for unbinds if enabled
	if config.Unbinds && config.Keybinds[flavour] != "default" {
		unbindsPath := filepath.Join(os.Getenv("HOME"), ".config", "qswitch", "keybinds", "unbinds.conf")
		if _, err := os.Stat(unbindsPath); err == nil {
			contentParts = append(contentParts, "source="+unbindsPath)
		}
	}

	// Add flavour keybinds
	if config.Keybinds[flavour] == "default" {
		contentParts = append(contentParts, "# Default")
	} else {
		contentParts = append(contentParts, "source="+filepath.Join(os.Getenv("HOME"), ".config", "qswitch", "keybinds", config.Keybinds[flavour]))
	}

	// Add QuickSwitchPanel keybind
	contentParts = append(contentParts, "bind=Super+Alt, P, exec, qswitch --panel")

	content := strings.Join(contentParts, "\n")
	os.WriteFile(keybindsFile, []byte(content), 0644)
}

func applyFlavour(flavour string, config Config) {
	// kill old qs
	exec.Command("pkill", "-x", "qs").Run()

	// start new one
	exec.Command("hyprctl", "dispatch", "exec", "qs -c "+flavour).Run()

	applyKeybinds(flavour, config)
}

// togglePanel opens the panel if not running, closes it if running
func togglePanel() {
	// Check if panel is already running by reading PID file
	pidData, err := os.ReadFile(panelPidFile)
	if err == nil {
		pid := strings.TrimSpace(string(pidData))
		// Check if process is still running
		checkCmd := exec.Command("kill", "-0", pid)
		if checkCmd.Run() == nil {
			// Process is running, kill it
			exec.Command("kill", pid).Run()
			os.Remove(panelPidFile)
			return
		}
	}

	// Panel not running, start it
	cmd := exec.Command("qs", "-p", "/etc/xdg/quickshell/qswitch/QuickSwitchPanel.qml")
	cmd.Start()
	if cmd.Process != nil {
		os.WriteFile(panelPidFile, []byte(fmt.Sprintf("%d", cmd.Process.Pid)), 0644)
	}
}

func cycle(config Config) {
	current := readState()

	// Find the first installed flavour for fallback
	firstInstalled := ""
	for _, f := range config.Flavours {
		if isFlavourInstalled(f) {
			firstInstalled = f
			break
		}
	}

	if firstInstalled == "" {
		fmt.Println("No installed flavours found.")
		return
	}

	if current == "" {
		writeState(firstInstalled)
		applyFlavour(firstInstalled, config)
		fmt.Println("Switched to", firstInstalled)
		return
	}

	// Find current index and cycle to next installed flavour
	currentIdx := -1
	for i, f := range config.Flavours {
		if f == current {
			currentIdx = i
			break
		}
	}

	if currentIdx == -1 {
		// Current not found, use first installed
		writeState(firstInstalled)
		applyFlavour(firstInstalled, config)
		fmt.Println("Switched to", firstInstalled)
		return
	}

	// Find next installed flavour
	for i := 1; i <= len(config.Flavours); i++ {
		nextIdx := (currentIdx + i) % len(config.Flavours)
		next := config.Flavours[nextIdx]
		if isFlavourInstalled(next) {
			writeState(next)
			applyFlavour(next, config)
			fmt.Println("Switched to", next)
			return
		}
	}

	fmt.Println("No other installed flavours to switch to.")
}

func setup(force bool) {
	// Check if state file exists
	if _, err := os.Stat(stateFile); err == nil && !force {
		fmt.Println("Setup already completed (state file exists).")
		return
	}

	// Create state file if it doesn't exist
	if err := os.WriteFile(stateFile, []byte(""), 0644); err != nil {
		fmt.Printf("Error creating state file: %v\n", err)
	}

	keybindsFile := filepath.Join(os.Getenv("HOME"), ".config", "qswitch", "qswitch.conf")
	content := "bind=Super+Alt, P, exec, qswitch --panel"
	os.WriteFile(keybindsFile, []byte(content), 0644)
	hyprlandFile := filepath.Join(os.Getenv("HOME"), ".config", "hypr", "hyprland.conf")

	// Check if already sourced
	hyprContent, err := os.ReadFile(hyprlandFile)
	if err == nil {
		if strings.Contains(string(hyprContent), "source=~/.config/qswitch/qswitch.conf") {
			fmt.Println("Setup completed (already sourced)")
			return
		}
	}

	f, err := os.OpenFile(hyprlandFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		fmt.Println("Error opening hyprland.conf:", err)
		return
	}
	defer f.Close()
	f.WriteString("\nsource=~/.config/qswitch/qswitch.conf\n")
	fmt.Println("Setup completed")
}
