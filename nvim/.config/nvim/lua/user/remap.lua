local set = vim.keymap.set

-- Modes
--  n: normal
--  i: insert
--  v: visual
--  x: visual block
--  t: term
--  c: command

set('n', '<leader>e', ':NvimTreeToggle<cr>')                                    -- Toggle nvim-tree 
set('v', 'J', ":m '>+1<CR>gv=gv")                                               -- Move highlighted line down 1 line
set('v', 'K', ":m '<-2<CR>gv=gv")                                               -- Move highlighted line up 1 line
set('n', 'J', "mzJ`z")                                                          -- Take following line and append it to current line separated by a space, leaving cursor in place
set('n', '<C-d>', "<C-d>zz")                                                    -- Jump half a page down and center cursor
set('n', '<C-u>', "<C-u>zz")                                                    -- Jump half a page up and center cursor
set('n', 'n', "nzzzv")                                                          -- Jump to next search term and center cursor
set('n', 'N', "Nzzzv")                                                          -- Jump to previous search term and center cursor
set('x', '<leader>p', '"_dp')                                                   -- Delete highlighted text to the void register and paste, preserving the previously yanked value
set({ 'n', 'v' }, '<leader>y', [["+y]])                                         -- Yank to the system clipboard
set('n', '<leader>Y', [["+Y]])                                                  -- Yank to the system clipboard
set({ 'n', 'v' }, '<leader>d', [["_d]])                                         -- Delete to the void register
set('n', '<leader>s', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])   -- Find and replace the word under the cursor
set('n', '<leader>x', '<cmd>!chmod +x %<CR>', { silent = true })                -- Make current file executable

-- Stay in visual mode when indenting
set('v', '<', '<gv')
set('v', '>', '>gv')

-- Better window navigation
set('n', '<C-h>', '<C-w>h')
set('n', '<C-j>', '<C-w>j')
set('n', '<C-k>', '<C-w>k')
set('n', '<C-l>', '<C-w>l')

-- Buffer navigation
set('n', '<C-b>[', ':bprev<CR>')
set('n', '<C-b>]', ':bnext<CR>')

-- Diagnostics
set('n', '<leader>do', ':lua vim.diagnostic.open_float()<CR>')
set('n', '<leader>d[', ':lua vim.diagnostic.goto_prev()<CR>')
set('n', '<leader>d]', ':lua vim.diagnostic.goto_next()<CR>')

-- Disable arrow keys to build muscle memory using hjkl
set('n', '<Left>', ':echoe "Use h"<CR>')
set('n', '<Down>', ':echoe "Use j"<CR>')
set('n', '<Up>', ':echoe "Use k"<CR>')
set('n', '<Right>', ':echoe "Use l"<CR>')
set('i', '<Left>', '<ESC>:echoe "Use h"<CR>')
set('i', '<Down>', '<ESC>:echoe "Use j"<CR>')
set('i', '<Up>', '<ESC>:echoe "Use k"<CR>')
set('i', '<Right>', '<ESC>:echoe "Use l"<CR>')

