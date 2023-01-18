local status_ok, catppuccin = pcall(require, 'catppuccin')

if not status_ok then
	vim.cmd.colorscheme 'default'
	vim.cmd.set "background=dark"

	return
end

catppuccin.setup({
	integrations = {
		harpoon = true,
		telescope = true
	}
})

vim.cmd.colorscheme 'catppuccin'

