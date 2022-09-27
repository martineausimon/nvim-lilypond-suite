# nvim-lilypond-suite

This is a plugin (Neovim only) for **LilyPond** with fast syntax highlighting and dictionary for auto-completion. This repository also contains an ftplugin for **LaTeX** files which allows embedded LilyPond syntax highlighting, and makeprg which support `lilypond-book` or `lyluatex` package out of the box.

## FEATURES

* **Better syntax file for LilyPond**
* **Asynchronous :make** - compile in background without freezing Neovim
* **mp3 player in floating window** (LilyPond only) - convert and play midi file while writing score (using `mpv`, `fluidsynth` & `ffmpeg`)
* **Simple ftplugin for LilyPond** with `makeprg`, correct `errorformat`
* **Compile only main file when working on multiple files project** (LilyPond only)
* **ftplugin for TeX files** whith detect and allows embedded LilyPond syntax, adaptive `makeprg` function for `lyluatex` or `lilypond-book`, correct `errorformat`
* **Easy auto-completion and Point & Click configuration**

<p align="center">
<img src="https://user-images.githubusercontent.com/89019438/191845626-4ba6224c-46c3-484f-a355-5cf10a66889f.png">
</p>

* [Installation](#installation)
  * [nvim-lilypond-suite](#nvim-lilypond-suite-plugin)
  * [Dependences](#dependences)
* [Settings](#settings)
  * [Configuration](#configuration)
  * [Mappings](#mappings)
    * [Commands](#commands)
    * [Player mappings](#player-mappings-lilypond-only)
  * [Lighter syntax highlighting](#lighter-syntax-highlighting)
  * [Highlight pitches for others languages](#highlight-pitches-for-others-languages)
  * [QuickFix](#quickfix)
  * [Multiple files projects](#multiple-files-projects)
  * [Recommended highlightings](#recommended-highlightings)
  * [Recommended settings for Auto-completion](#recommended-settings-for-auto-completion)
  * [Point & click configuration](#my-neovim-settings-for-point-click)
* [LaTex](#latex)
  * [Clean log files on exit](#clean-log-files-on-exit)
  * [Tricks for lilypond-book](#tricks-for-lilypond-book)
* [License](#License)

---

## INSTALLATION

### nvim-lilypond-suite plugin

> **⚠ This plugin requires Nvim >= 0.7**

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

## SETTINGS

### Configuration

Nvim-lilypond-suite is configurable, here is the default configuration that you can copy-paste and modify in your init.lua :

```lua
require('nvls').setup({
  lilypond = {
    mappings = {
      player = "<F3>",
      compile = "<F5>",
      open_pdf = "<F6>",
      switch_buffers = "<A-Space>",
      insert_version = "<F4>"
    },
    options = {
      pitches_language = "default"
    },
  },
  latex = {
    mappings = {
      compile = "<F5>",
      open_pdf = "<F6>",
      lilypond_syntax = "<F3>"
    },
    options = {
      clean_logs = false
    },
  },
  player = {
    mappings = {
      quit = "q",
      play_pause = "p",
      loop = "<A-l>",
      backward = "h",
      small_backward = "<S-h>",
      forward = "l",
      small_forward = "<S-l>",
      decrease_speed = "j",
      increase_speed = "k",
      halve_speed = "<S-j>",
      double_speed = "<S-k>"
    },
    options = {
      row = "2%",
      col = "99%",
      width = "37",
      height = "1",
      border_style = "single"
    },
  },
})
```

### Mappings

#### Commands

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

#### Player mappings (LilyPond only)

| Key             | Description                                     |
| ---             | ---                                             |
| `<A-Space>`     | Switch between player and LilyPond buffers      |
| `q` and `<Esc>` | Exit player                                     |
| `p`             | Play / Pause                                    |
| `<A-l>`         | Loop start/stop/clean                           |
| `h`             | Seek backward 5 sec                             |
| `<S-h>`         | Seek backward 1 sec                             |
| `l`             | Seek forward 5 sec                              |
| `<S-l>`         | Seek forward 1 sec                              |
| `{` and `}`     | Halve/double current playback speed             |
| `j` and `k`     | Decrease/increase current playback speed by 10% |
| `[` and `]`     | Decrease/increase current playback speed by 10% |


#### Lighter syntax highlighting

Since the last big update [7df532e](https://github.com/martineausimon/nvim-lilypond-suite/commit/7df532ef0476299b03cc72e3160e13c7ae54488c), I changed my method for syntax highlighting and avoided word lists as much as possible, for more lightness.

Recommended settings in `init.lua` :

```lua
vim.api.nvim_create_autocmd('BufEnter', { 
  command = "syntax sync fromstart",
  pattern = { '*.ly', '*.ily' }
})
```

### Highlight pitches for others languages

If you use others languages for pitch names, you can configure nvim-lilypond-suite to highlight the right words with `pitches_language` option in [`require('nvls').setup()`](#configuration)

>For now, only *english*, *français* and *default* highlights are availables.  
>TODO : create pitches pattern for other languages

### QuickFix

This plugin have no defaults for `QuickFixCmdPost` event. You can configure your `init.lua` using an autocommand, e.g. :

```lua
vim.api.nvim_create_autocmd( 'QuickFixCmdPost', { 
  command = "cwindow",
  pattern = "*"
})
```

### Multiple files projects

When working on a multiple files project, with `\include`d sources in a main file, only the file called `main.ly` is selected for compilation, open pdf and play midi. Two others options are availables to define a custom main file (see discussion with [niveK77pur](https://github.com/martineausimon/nvim-lilypond-suite/issues?q=is%3Aissue+is%3Aopen+author%3AniveK77pur) on [issue #3](https://github.com/martineausimon/nvim-lilypond-suite/issues/3) :

#### using a local vimrc file

If you already use a plugin like [exrc.nvim](https://github.com/MunifTanjim/exrc.nvim) to work with local nvim config files, I recommend using this variable to define a custom main lilypond file :

```lua
vim.g.nvls_main_file = "/complete/path/to/custom/main/file.ly"
```

This variable is never overwrited by the plugin, be careful to not open severals projects already using this variable in the same nvim session, and always open files from working directory.

#### using .lilyrc config file

You can define a custom main file by creating a `.lilyrc` file in the project directory containing this variable (in lua only) :

```lua
vim.g.nvls_main = "/complete/path/to/custom/main/file.ly"
```

This one is called on each command (compile, open, play midi file), and should work if you open differents projects with differents main files in the same nvim session, even if you call files from another directory.

### Recommended highlightings

```lua
local hi = vim.api.nvim_set_hl

hi(0, 'Keyword',        {ctermfg = "yellow",       bold = true})
hi(0, 'Tag',            {ctermfg = "blue"})
hi(0, 'Label',          {ctermfg = "lightYellow"})
hi(0, 'SpecialComment', {ctermfg = "lightCyan"})
hi(0, 'SpecialChar',    {ctermfg = "lightMagenta", bold = true})
hi(0, 'PreCondit',      {ctermfg = "cyan"})
```
### Recommended settings for Auto-completion

Install [coc.nvim](https://github.com/neoclide/coc.nvim) and `coc-dictionary` & `coc-tabnine` : works out of the box !

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

```bash
set synctex-editor-command "lilypond-invoke-editor %s"
```

Install [neovim-remote](https://github.com/mhinz/neovim-remote) and add this line to `~/.profile` (or `~/.bashrc`) :

```bash
export LYEDITOR="nvr -s +:'dr %(file)s | call cursor(%(line)s,%(char)s+1)'"
```

>Alternate `custom text editor` command, for [Okular](https://github.com/KDE/okular) :
>```bash
>nvr +:'dr %f | call cursor(%l,%c+1)'
>```

Follow the instructions on the [LilyPond website](https://lilypond.org/doc/v2.23/Documentation/usage/configuring-the-system-for-point-and-click#) to configure the system and create `lilypond-invoke-editor.desktop`

Reboot or reload session

## LaTex

This plugin works with `lilypond-book` by default if the `.tex` file contains `\begin{lilypond}`. To use `lyluatex`, just add `\usepackage{lyluatex}` to your preamble. 

>NOTE : `lyluatex` package does not allow files containing spaces, and does not allow compiling in a directory other than the working directory

Syntax highlighting can be slow with embedded LilyPond, you can use `<F3>` to activate or deactivate it.

### Clean log files on exit

Define `true` to `clean_logs` option in [`require('nvls').setup()`](#configuration)

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
