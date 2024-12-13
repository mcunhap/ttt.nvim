if !has('nvim-0.7')
  echoerr "[ttt] Neovim version 0.7 or above is required!"
endif

command! -nargs=0 TTT :lua require('ttt'):start()
