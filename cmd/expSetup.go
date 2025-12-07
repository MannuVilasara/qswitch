/*
Copyright © 2025 Manpreet Singh <mannuvilasara@gmail.com>
*/
package cmd

import (
	"qswitch/utils"

	"github.com/spf13/cobra"
)

// expSetupCmd represents the expSetup command
var expSetupCmd = &cobra.Command{
	Use:   "exp-setup",
	Short: "Experimental setup",
	Long:  `Perform the initial setup for qswitch.`,
	Run: func(cmd *cobra.Command, args []string) {
		config := utils.LoadConfig()
		force, _ := cmd.Flags().GetBool("force")
		utils.Setup(config, force)
	},
}

func init() {
	rootCmd.AddCommand(expSetupCmd)
	expSetupCmd.Flags().Bool("force", false, "Force setup even if already completed")
}
