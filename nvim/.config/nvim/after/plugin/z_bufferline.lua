local status_ok, bufferline = pcall(require, 'bufferline')

if not status_ok then
	return
end

bufferline.setup({
  options = {
--    highlights = require("catppuccin.groups.integrations.bufferline").get(),
    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        text_align = "center",
        separator = true
      }
    },
    show_close_icon = false,
    separator_style = "slant"
  }
})

