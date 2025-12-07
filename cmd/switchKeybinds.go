/*
Copyright © 2025 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"fmt"

	"qswitch/utils"

	"github.com/spf13/cobra"
)

// switchKeybindsCmd represents the switchKeybinds command
var switchKeybindsCmd = &cobra.Command{
	Use:   "switch-keybinds [flavour]",
	Short: "Switch only keybinds for a flavour",
	Long:  `Apply keybinds for a specific flavour without switching the flavour itself.`,
	Args:  cobra.ExactArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		config := utils.LoadConfig()
		flavour := args[0]
		if !utils.IsValidFlavour(flavour, config) {
			fmt.Println("Unknown flavour:", flavour)
			return
		}
		utils.ApplyKeybinds(flavour, config)
		fmt.Println("Switched keybinds to", flavour)
	},
}

func init() {
	rootCmd.AddCommand(switchKeybindsCmd)
}
