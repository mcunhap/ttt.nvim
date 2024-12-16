# Tic Tac Toe in Neovim - ttt.nvim

This is a simple Tic Tac Toe game written in Lua for Neovim.

## Installation

You can install this plugin using your favorite plugin manager. For example, using [lazyvim](http://www.lazyvim.org/):

```vim
{ "mcunhap/ttt.nvim" }
```

## Usage

You can start the game by running the following command:

```vim
:TTT
```

The game will be displayed in a new buffer. You can play by moving the cursor to the cell you want to mark and pressing `Enter`.
To quit the game, press `q` or `ESC`.

The default configuration is to play against the computer with player 1 using `x` and player 2 `o`. You can change this by settings using `setup` function like this:

```vim
require('ttt').setup({
    player_1_symbol = '!',
    player_2_symbol = '?',

    play_against_computer = false,
})
```
