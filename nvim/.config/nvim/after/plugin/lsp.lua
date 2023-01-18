local status_ok, lsp = pcall(require, 'lsp-zero')

if not status_ok then
	return
end

lsp.preset('recommended')

lsp.ensure_installed({
	'tsserver',
	'eslint',
	'sumneko_lua',
	'vimls'
})

lsp.nvim_workspace()

lsp.setup()

