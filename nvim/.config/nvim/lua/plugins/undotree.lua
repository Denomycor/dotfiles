return {
	"mbbill/undotree",
	keys = {
		{ "<leader>u", vim.cmd.UndotreeToggle, desc = "Undotree" },
	},
	init = function()
		vim.g.undotree_SetFocusWhenToggle = 1
	end,
}
