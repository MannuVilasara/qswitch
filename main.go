
package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

var stateFile = os.Getenv("HOME") + "/.switch_state"
var flavours = []string{"ii", "caelestia", "noctalia"}

func help() {
	fmt.Println(`Usage:
  switch <flavour>       Switch to a specific flavour
  switch                 Cycle to the next flavour

Available flavours:
  ii, caelestia, noctalia

Options:
  --help, -h             Show this help message`)
}

func applyFlavour(flavour string) {
	// kill old qs
	exec.Command("pkill", "-x", "qs").Run()

	// start new one
	exec.Command("hyprctl", "dispatch", "exec", "qs -c "+flavour).Run()
}

func readState() string {
	data, err := os.ReadFile(stateFile)
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(data))
}

func writeState(f string) { os.WriteFile(stateFile, []byte(f), 0644) }

func cycle() {
	current := readState()

	if current == "" {
		writeState(flavours[0])
		applyFlavour(flavours[0])
		fmt.Println("Switched to", flavours[0])
		return
	}

	for i, f := range flavours {
		if f == current {
			next := flavours[(i+1)%len(flavours)]
			writeState(next)
			applyFlavour(next)
			fmt.Println("Switched to", next)
			return
		}
	}

	// fallback
	writeState(flavours[0])
	applyFlavour(flavours[0])
	fmt.Println("Switched to", flavours[0])
}

func isValidFlavour(name string) bool {
	for _, f := range flavours {
		if f == name {
			return true
		}
	}
	return false
}

func main() {
	args := os.Args[1:]

	if len(args) == 1 && (args[0] == "--help" || args[0] == "-h") {
		help()
		return
	}

	if len(args) == 0 {
		cycle()
		return
	}

	flavour := args[0]
	if !isValidFlavour(flavour) {
		fmt.Println("Unknown flavour:", flavour)
		fmt.Println("Run 'switch --help' to list flavours.")
		return
	}

	writeState(flavour)
	applyFlavour(flavour)
	fmt.Println("Switched to", flavour)
}
