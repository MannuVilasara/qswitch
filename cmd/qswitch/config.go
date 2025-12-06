package main

import (
	"encoding/json"
	"os"
	"path/filepath"
)

type Config struct {
	Flavours []string          `json:"flavours"`
	Keybinds map[string]string `json:"keybinds"`
	Unbinds  bool              `json:"unbinds"`
}

var defaultConfig = Config{
	Flavours: []string{},
	Keybinds: map[string]string{},
	Unbinds: false,
}

func loadConfig() Config {
	configDir := filepath.Join(os.Getenv("HOME"), ".config", "qswitch")
	configPath := filepath.Join(configDir, "config.json")

	// Create dir if not exists
	os.MkdirAll(configDir, 0755)

	// Create keybinds dir
	keybindsDir := filepath.Join(configDir, "keybinds")
	os.MkdirAll(keybindsDir, 0755)

	// Read file
	data, err := os.ReadFile(configPath)
	if err != nil {
		// Create with default
		defaultData, _ := json.MarshalIndent(defaultConfig, "", "  ")
		os.WriteFile(configPath, defaultData, 0644)
		return defaultConfig
	}

	var config Config
	json.Unmarshal(data, &config)
	if config.Keybinds == nil {
		config.Keybinds = defaultConfig.Keybinds
		// Write back updated config
		updatedData, _ := json.MarshalIndent(config, "", "  ")
		os.WriteFile(configPath, updatedData, 0644)
	}
	return config
}

func isValidFlavour(name string, config Config) bool {
	for _, f := range config.Flavours {
		if f == name {
			return true
		}
	}
	return false
}
