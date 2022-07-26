# nvim-lilypond-suite

This is a plugin (Neovim only) for **LilyPond** with updated syntax and dictionary for auto-completion. This repository also contains an ftplugin for **LaTeX** files which allows embedded LilyPond syntax highlighting, and makeprg which support `lilypond-book` or `lyluatex` package out of the box.

## FEATURES

* **Updated syntax file** using the last [Pygments syntax highlighter for LilyPond](https://github.com/pygments/pygments/blob/master/pygments/lexers/_lilypond_builtins.py)
* **Asynchronous :make** - compile in background without freezing Neovim
* **mp3 player in floating window** (LilyPond only) - convert and play midi file while writing score (using `mpv`, `fluidsynth` & `ffmpeg`)
* **Simple ftplugin for LilyPond** with `makeprg`, correct `errorformat`
* **ftplugin for TeX files** whith detect and allows embedded LilyPond syntax, adaptive `makeprg` function for `lyluatex` or `lilypond-book`, correct `errorformat`
* **Easy Point & Click configuration**

<p align="center">
<img src="https://github.com/martineausimon/nvim-lilypond-suite/blob/main/screenshoot.png">
</p>

* [Installation](#Installation)
	* nvim-lilypond-suite
	* Dependences
* [Mappings](#Mappings)
	* Commands
	* Player mappings
* [Settings](#Settings)
	* QuickFix
	* Recommended highlightings
	* Recommended settings for Auto-completion
	* Point & click configuration
* [LaTex](#LaTex)
	* Clean log files on exit
	* Tricks for lilypond-book
* [License](#License)

---

## INSTALLATION

### nvim-lilypond-suite

* Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'martineausimon/nvim-lilypond-suite',
  requires = { 'MunifTanjim/nui.nvim' }
}
```

* Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'martineausimon/nvim-lilypond-suite'
Plug 'MunifTanjim/nui.nvim'
```

### Dependences

If you want to use the mp3/midi player, you'll need to install the following packages :

* Install and configure `fluidsynth` (e.g. on [Arch](https://wiki.archlinux.org/title/FluidSynth) with `soundfont-fluid`)

```bash
sudo pacman -S fluidsynth soundfont-fluid
```

* Specify a default soundfont

```bash
sudo ln -s /usr/share/soundfonts/FluidR3_GM.sf2 /usr/share/soundfonts/default.sf2
```
* Install `mpv` and `ffmpeg`

```bash
sudo pacman -S mpv ffmpeg
```

## MAPPINGS

### Commands

* LilyPond files :

| Command       | Default mappings | Description                                            |
| ---           | ---              | ---                                                    |
| `:LilyPlayer` | `<F3>`           | Convert midi file to mp3 and play in a floating window |
|               | `<F4>`           | Insert current version                                 |
| `:LilyCmp`    | `<F5>`           | Save & compile pdf                                     |
| `:Viewer`     | `<F6>`           | Open %.pdf                                             |

* LaTex files :

| Command       | Default mappings | Description                                            |
| ---           | ---              | ---                                                    |
| `:ToggleSyn`  | `<F3>`           | Enable or disable LilyPond embed syntax                |
| `:TexCmp`     | `<F5>`           | Save & compile pdf                                     |
| `:Viewer`     | `<F6>`           | Open %.pdf                                             |

### Player mappings (LilyPond only)

| Key         | Description                                     |
| ---         | ---                                             |
| `<A-Space>` | Switch between player and LilyPond buffers      |
| `q`         | Exit player                                     |
| `p`         | Play / Pause                                    |
| `<A-l>`     | Loop start/stop/clean                           |
| `h`         | Seek backward 5 sec                             |
| `<S-h>`     | Seek backward 1 sec                             |
| `l`         | Seek forward 5 sec                              |
| `<S-l>`     | Seek forward 1 sec                              |
| `{` and `}` | Halve/double current playback speed             |
| `j` and `k` | Decrease/increase current playback speed by 10% |
| `[` and `]` | Decrease/increase current playback speed by 10% |

## SETTINGS

### QuickFix

This plugin have no defaults for `QuickFixCmdPost` event. You can configure your `init.lua` using an autocommand, e.g. :

```lua
vim.api.nvim_create_autocmd( 'QuickFixCmdPost', { 
	command = "cwindow",
	pattern = "*"
})
```
### Recommended highlightings

```lua
local hi = vim.api.nvim_set_hl

hi(0, 'Keyword',        {ctermfg = "yellow",       bold = true})
hi(0, 'Tag',            {ctermfg = "blue"})
hi(0, 'Label',          {ctermfg = "lightYellow"})
hi(0, 'StorageClass',   {ctermfg = "lightGreen",   bold = true})
hi(0, 'SpecialComment', {ctermfg = "lightCyan"})
hi(0, 'PreCondit',      {ctermfg = "cyan"})
```
### Recommended settings for Auto-completion

Install [coc.nvim](https://github.com/neoclide/coc.nvim) and `coc-dictionary` & `coc-tabnine` : works out of the box !

#### My config for coc.nvim

* In my `init.lua` :

```lua
require('cocSettings')
```

* In `~/.config/nvim/lua/cocSettings.lua` :

```lua
function escape_keycode(keycode)
	return vim.api.nvim_replace_termcodes(keycode, true, true, true)
end

local function check_back_space()
	local col = vim.fn.col(".") - 1
	return col <= 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

function tab_completion()
	if vim.fn.pumvisible() > 0 then
		return escape_keycode("<C-n>")
	end
	if check_back_space() then
		return escape_keycode("<TAB>")
	end
	return vim.fn["coc#refresh"]()
end

function shift_tab_completion()
	if vim.fn.pumvisible() > 0 then
		return escape_keycode("<C-p>")
	else
		return escape_keycode("<C-h>")
	end
end

key = vim.api.nvim_set_keymap

if vim.fn.exists("*complete_info") then
	key(
		"i", "<CR>", 
		"complete_info(['selected'])['selected'] != -1 ?" ..
		"'<C-y>' : '<C-G>u<CR>'", 
		{silent = true, expr = true, noremap = true}
	)
end

key("i", "<TAB>",   "v:lua.tab_completion()",       { expr = true })
key("i", "<S-TAB>", "v:lua.shift_tab_completion()", { expr = true })

vim.o.completeopt = "menu,menuone,noselect"
vim.o.shortmess   = vim.o.shortmess .. "c"
```
If you want to use another completion plugin like [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) with [uga-rosa/cmp-dictionary](https://github.com/uga-rosa/cmp-dictionary), vim-lilypond-suite uses the following dictionary files :

```bash
$LILYDICTPATH/grobs
$LILYDICTPATH/keywords
$LILYDICTPATH/musicFunctions
$LILYDICTPATH/articulations
$LILYDICTPATH/grobProperties
$LILYDICTPATH/paperVariables
$LILYDICTPATH/headerVariables
$LILYDICTPATH/contextProperties
$LILYDICTPATH/clefs
$LILYDICTPATH/repeatTypes
$LILYDICTPATH/languageNames
$LILYDICTPATH/accidentalsStyles
$LILYDICTPATH/scales
$LILYDICTPATH/musicCommands
$LILYDICTPATH/markupCommands
$LILYDICTPATH/contextsCmd
$LILYDICTPATH/dynamics
$LILYDICTPATH/contexts
$LILYDICTPATH/translators
```

### My Neovim settings for Point & Click

Recommended pdf viewer : [zathura](https://pwmt.org/projects/zathura/) with [zathura-pdf-mupdf plugin](https://pwmt.org/projects/zathura-pdf-mupdf/)

Add this line to `~/.config/zathura/zathurarc` :

	set synctex-editor-command "lilypond-invoke-editor %s"

Install [neovim-remote](https://github.com/mhinz/neovim-remote) and add this line to `~/.profile` :

```bash
export LYEDITOR="nvr +:'call cursor(%(line)s,%(char)s)' %(file)s"
```

Follow the instructions on the [LilyPond website](https://lilypond.org/doc/v2.23/Documentation/usage/configuring-the-system-for-point-and-click#) to configure the system and create `lilypond-invoke-editor.desktop`

Reboot or reload with `. ~/.profile`

## LaTex

This plugin works with `lilypond-book` by default if the `.tex` file contains `\begin{lilypond}`. To use `lyluatex`, just add `\usepackage{lyluatex}` to your preamble. 

Syntax highlighting can be slow with embedded LilyPond, you can use `<F3>` to activate or deactivate it.

### Clean log files on exit

Add this line to your `init.lua` to remove log files on exit :

```lua
vim.g.nvls_clean_tex_files = 1
```

### Tricks for lilypond-book

Add this lines to your preamble to avoid the padding on the left side and keep the score justified :

```tex
\def\preLilyPondExample{\hspace*{-3mm}}
\newcommand{\betweenLilyPondSystem}[1]{\linebreak\hspace*{-3mm}}
```

Adjust space between systems using this line (in `\renewcommand` or `\newcommand`) :

```tex
{\betweenLilyPondSystem}[1]{\vspace{5mm}\linebreak\hspace*{-3mm}}
```


## LICENSE

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
