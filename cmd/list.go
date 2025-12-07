/*
Copyright © 2025 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"encoding/json"
	"fmt"

	"qswitch/utils"

	"github.com/spf13/cobra"
)

// listCmd represents the list command
var listCmd = &cobra.Command{
	Use:   "list",
	Short: "List available flavours",
	Long:  `List all available flavours configured in the config.`,
	Run: func(cmd *cobra.Command, args []string) {
		config := utils.LoadConfig()
		status, _ := cmd.Flags().GetBool("status")
		if status {
			type FlavourStatus struct {
				Name      string `json:"name"`
				Installed bool   `json:"installed"`
			}
			var statuses []FlavourStatus
			for _, f := range config.Flavours {
				statuses = append(statuses, FlavourStatus{
					Name:      f,
					Installed: utils.IsFlavourInstalled(f),
				})
			}
			jsonData, _ := json.Marshal(statuses)
			fmt.Println(string(jsonData))
		} else {
			for _, f := range config.Flavours {
				fmt.Println(f)
			}
		}
	},
}

func init() {
	rootCmd.AddCommand(listCmd)
	listCmd.Flags().BoolP("status", "s", false, "Show installation status in JSON format")
}
