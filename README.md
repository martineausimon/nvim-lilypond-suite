# nvim-lilypond-suite

This is a plugin ([Neovim](https://github.com/neovim/neovim) only) for writing [LilyPond](https://lilypond.org/index.html) scores, with asynchronous make, midi/MP3 player, "hyphenation" function for lyrics, fast syntax highlighting... This repository also contains an ftplugin for **LaTeX** files which allows embedded LilyPond syntax highlighting, and makeprg which support `lilypond-book` or `lyluatex` package out of the box.

## FEATURES

* **Better syntax file for LilyPond**
* **Asynchronous :make** - compile in background without freezing Neovim
* **mp3 player in floating window** (LilyPond only) - convert and play midi file while writing score (using `mpv`, `fluidsynth` & `ffmpeg`)
* **QuickPlayer** (LilyPond only) - convert and play only visual selection
* **Hyphenation** : automatically place hyphens ' **--** ' inside texts to make those texts usable as lyrics (LilyPond only)
* **Simple ftplugin for LilyPond** with `makeprg`, correct `errorformat`
* **Compile only main file when working on multiple files project** (LilyPond only)
* **ftplugin for TeX files** whith detect and allows embedded LilyPond syntax, adaptive `makeprg` function for `lyluatex` or `lilypond-book`, correct `errorformat`
* **Easy auto-completion and Point & Click configuration**

<p align="center">
<img src="https://user-images.githubusercontent.com/89019438/191845626-4ba6224c-46c3-484f-a355-5cf10a66889f.png">
</p>

## QUICK INSTALL WITH CONFIG

> **⚠ This plugin requires Nvim >= 0.7**

If you want to use all the functions (player, hyphenation for various languages...), please read the [installation section](https://github.com/martineausimon/nvim-lilypond-suite/wiki/Installation) in the wiki to install dependencies

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua 
use { 'martineausimon/nvim-lilypond-suite',
  config = function()
    require('nvls').setup({
      lilypond = {
        mappings = {
          player = "<F3>",
          compile = "<F5>",
          open_pdf = "<F6>",
          switch_buffers = "<A-Space>",
          insert_version = "<F4>",
          hyphenation = "<F12>",
          hyphenation_change_lang = "<F11>",
          insert_hyphen = "<leader>ih",
          add_hyphen = "<leader>ah",
          del_next_hyphen = "<leader>dh",
          del_prev_hyphen = "<leader>dH",
          del_selected_hyphen = "<leader>dh"
        },
        options = {
          pitches_language = "default",
          output = "pdf",
          main_file = "main.ly",
          main_folder = "%:p:h",
          hyphenation_language = "en_DEFAULT",
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
          border_style = "single",
          winhighlight = "Normal:Normal,FloatBorder:Normal"
        },
      },
    })
  end
}
```

## WIKI INDEX

* [Home](https://github.com/martineausimon/nvim-lilypond-suite/wiki)
* [1. Installation](https://github.com/martineausimon/nvim-lilypond-suite/wiki/1.-Installation)
* [2. Configuration](https://github.com/martineausimon/nvim-lilypond-suite/wiki/2.-Configuration)
* [3. Usage](https://github.com/martineausimon/nvim-lilypond-suite/wiki/3.-Usage)
* [4. Tips and tricks](https://github.com/martineausimon/nvim-lilypond-suite/wiki/4.-Tips-and-tricks)
