/*
Copyright © 2025 Manpreet Singh <mannuvilasara@gmail.com>
*/
package cmd

import (
	"fmt"

	"qswitch/utils"

	"github.com/spf13/cobra"
)

// reloadCmd represents the reload command
var reloadCmd = &cobra.Command{
	Use:   "reload",
	Short: "Reload keybinds for current flavour",
	Long:  `Reload the keybinds configuration for the currently active flavour.`,
	Run: func(cmd *cobra.Command, args []string) {
		config := utils.LoadConfig()
		current := utils.ReadState()
		utils.ApplyKeybinds(current, config)
		fmt.Println("Config Reloaded")
	},
}

func init() {
	rootCmd.AddCommand(reloadCmd)
}
