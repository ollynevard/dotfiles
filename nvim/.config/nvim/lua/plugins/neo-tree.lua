--
-- File tree - https://github.com/nvim-neo-tree/neo-tree.nvim
--
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    -- Disable netrw - https://github.com/nvim-neo-tree/neo-tree.nvim/issues/983
    vim.g.loaded_netrw = 0
    vim.g.loaded_netrwPlugin = 0

    require("neo-tree").setup({
      close_if_last_window = true,
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
        },
      },
      event_handlers = {
        {
          event = "neo_tree_buffer_enter",
          handler = function()
            vim.o.showmode = false
            vim.o.ruler = false
            vim.o.laststatus = 0
            vim.o.showcmd = false
          end
        },
        {
          event = "neo_tree_buffer_leave",
          handler = function()
            vim.o.showmode = true
            vim.o.ruler = true
            vim.o.laststatus = 2
            vim.o.showcmd = true
          end
        },
      },
    })
    vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left toggle<CR>", {})
    vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", {})
  end,
}
