/*
Copyright © 2025 Manpreet Singh <mannuvilasara@gmail.com>
*/
package cmd

import (
	"qswitch/utils"

	"github.com/spf13/cobra"
)

// panelCmd represents the panel command
var panelCmd = &cobra.Command{
	Use:   "panel",
	Short: "Toggle the panel",
	Long:  `Toggle the QuickSwitchPanel on or off.`,
	Run: func(cmd *cobra.Command, args []string) {
		utils.TogglePanel()
	},
}

func init() {
	rootCmd.AddCommand(panelCmd)
}
