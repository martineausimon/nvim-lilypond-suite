if exists('b:current_syntax')
  finish 
endif

if !exists('g:nvls_language')
  let g:nvls_language = "default"
endif

let s:keepcpo= &cpo
set cpo&vim

setlocal mps+=<:>

syn case match

syn cluster lilyMatchGroup contains=
  \lilyMatcher,
  \lilyPitch,
  \lilyFunction,
  \lilyString,
  \lilyComment,
  \lilyNumber,
  \lilySpecial,
  \lilyDynamic,
  \lilySchemeReg,
  \lilyMarkupReg,
  \lilyMarkup,
  \lilyScheme,
  \lilyBoolean,
  \lilyLyrics,
  \lilyArgument,
  \lilyContext,
  \lilyGrob,
  \lilyTranslator,
  \lilyClef,
  \lilyAccidentalsStyle,
  \lilyRepeatType,
  \lilyPitchLanguageName,
  \lilyDefineVar,
  \Error

syn region lilyMatcher  
  \ matchgroup=Delimiter
  \ start="{"
  \ skip="\\\\\|\\[<>]"
  \ end="}"
  \ contains=@lilyMatchGroup 
  \ nextgroup=lilyArticulation
  \ fold

syn region lilyMatcher  
  \ matchgroup=Delimiter
  \ start="\["
  \ end="]"
  \ contains=@lilyMatchGroup
  \ fold

syn region lilyMatcher  
  \ matchgroup=Delimiter 
  \ start="<" 
  \ skip="\\\\\|\\[{<>}]" 
  \ end=">" 
  \ contains=@lilyMatchGroup 
  \ fold

if g:nvls_language != "nohl"
  syn match  lilyFing "\s\{}\(\-\|[(\)]\|[(^)]\|[(_)]\)\d\+" contained nextgroup=lilyFing
endif

syn match  lilyChordBass "\/" contained containedin=@lilyPitchGroup nextgroup=lilyPitch

syn match lilyMarkup   "[-_^]\?\\\a\(\a\|\-\)\{}\a\+"
syn match lilyFunction "[-_^]\?\\\a\(\a\|\-\)\{}\a\+"
syn match lilyFunction "[-_^]\?\(\\tweak\|\\set\)\s\+" nextgroup=lilyVar,lilyContext
syn match lilyDynamic "[-_^]\?\\\(cr\|cresc\|decr\|decresc\|dim\|endcr\|endcresc\|enddecr\|enddecresc\|enddim\|f\|ff\|fff\|ffff\|fffff\|fp\|fz\|mf\|mp\|n\|p\|pp\|ppp\|pppp\|ppppp\|rfz\|sf\|sff\|sfp\|sfz\|sp\|spp\)\(\A\|\n\)"me=e-1

syn cluster lilyPitchGroup contains=
  \lilyPitch,lilyRythm,lilyChordStart,lilyChordNat,lilyChordExt

if g:nvls_language == "français"
  syn match lilyPitch "\<\(la\|si\|do\|re\|ré\|mi\|fa\|sol\|la\|s\|R\|r\)\(dd\|bb\|x\|sd\|sb\|dsd\|bsb\|d\|b\)\{}\(\'\+\|\,\+\)\{}\(?\|!\)\="
    \ nextgroup=lilyRythm
elseif g:nvls_language == "english"
  syn match lilyPitch "\<\([a-g]\|s\|R\|r\)\(ss\|ff\|x\|qs\|qf\|tqs\|tqf\|s\|f\|\-flatflat\|\-sharpsharp\|\-flat\|\-sharp\)\{}\(\'\+\|\,\+\)\{}\(?\|!\)\="
    \ nextgroup=lilyRythm
elseif g:nvls_language == "nohl"
else
  syn match lilyPitch "\<\([a-g]\|s\|R\|r\)\(isis\|eses\|eh\|ih\|eseh\|isih\|is\|es\)\{}\(\'\+\|\,\+\)\{}\(?\|!\)\="
    \ nextgroup=lilyRythm
endif

syn match lilyClef "\<\(C\|F\|G\|G2\|GG\|alto\|altovarC\|baritone\|baritonevarC\|baritonevarF\|bass\|blackmensural-c1\|blackmensural-c2\|blackmensural-c3\|blackmensural-c4\|blackmensural-c5\|french\|hufnagel-do-fa\|hufnagel-do1\|hufnagel-do2\|hufnagel-do3\|hufnagel-fa1\|hufnagel-fa2\|kievan-do\|medicaea-do1\|medicaea-do2\|medicaea-do3\|medicaea-fa1\|medicaea-fa2\|mensural-c1\|mensural-c2\|mensural-c3\|mensural-c4\|mensural-c5\|mensural-f\|mensural-g\|mezzosoprano\|moderntab\|neomensural-c1\|neomensural-c2\|neomensural-c3\|neomensural-c4\|neomensural-c5\|percussion\|petrucci-c1\|petrucci-c2\|petrucci-c3\|petrucci-c4\|petrucci-c5\|petrucci-f\|petrucci-f2\|petrucci-f3\|petrucci-f4\|petrucci-f5\|petrucci-g\|petrucci-g1\|petrucci-g2\|soprano\|subbass\|tab\|tenor\|tenorG\|tenorvarC\|treble\|varC\|varbaritone\|varpercussion\|vaticana-do1\|vaticana-do2\|vaticana-do3\|vaticana-fa1\|vaticana-fa2\|violin\)\(\A\|\n\)"

syn match lilyRepeatType "\<\(percent\|segno\|tremolo\|unfold\|volta\)\(\A\|\n\)"

syn match lilyPitchLanguageNames "\<\(arabic\|catalan\|català\|deutsch\|english\|espanol\|español\|français\|italiano\|nederlands\|norsk\|portugues\|português\|suomi\|svenska\|vlaams\)\(\A\|\n\)"

syn match lilyAccidentalsStyle "\<\(choral-cautionary\|choral\|default\|dodecaphonic-first\|dodecaphonic-no-repeat\|dodecaphonic\|forget \|modern-cautionary\|modern-voice\|modern-voice-cautionary\|neo-modern-cautionary\|neo-modern-voice\|neo-modern-voice-cautionary\|neo-modern\|modern\|no-reset\|piano-cautionary\|piano\|teaching\|voice\)\(\A\|\n\)"


syn match lilyRythm "\(1024\|512\|256\|128\|64\|32\|16\|8\|4\|2\|1\)\=\.\{}"
  \ contained containedin=lilyPitch nextgroup=lilyArticulation,lilyFunction,lilyChordStart,lilyChordBass,lilyFing,lilySpecial,lilyDynamic,lilyMarkupReg

if g:nvls_language != "nohl"
  syn match lilyChordStart "\:" contained 
        \ containedin=@lilyPitchGroup
        \ nextgroup=lilyChordNat

  syn match lilyChordNat "\d\{,2}\(maj\|dim\|sus\|aug\|m\)\=\d\{,2}" contained 
        \ containedin=lilyChordStart 
        \ nextgroup=lilyChordExt,lilyChordBass

  syn match lilyChordExt "\.\([2-9]\|1[0-3]\)\(+\|\-\)\=" contained 
        \ containedin=lilyChordNat,lilyChordExt
        \ nextgroup=lilyChordExt,lilyChordBass
        \ contains=lilyDots
end

syn match lilyGrob     "\<\u\a\+\>" nextgroup=lilyVar

syn match lilyDefineVar "\a\(\a\|\-\|_\)\+\a\+\s\{}="he=e-1 contains=lilySpecial
syn match lilyVar "\.\{}\(\l\|\-\|X\|Y\)\{}\(X\|Y\|\l\)\+\(\A\|\n\)" contained nextgroup=lilyVar contains=lilyDots
syn match lilyDefineVar "\l\(\l\|\-\)\+\l\+\." contains=lilyDots nextgroup=lilyVar
syn match lilyDots "\." contained

syn match lilyContext "\(\\\|\<\)\(AncientRemoveEmptyStaffContext\|ChoirStaff\|ChordNames\|CueVoice\|Devnull\|DrumStaff\|DrumVoice\|Dynamics\|FiguredBass\|FretBoards\|Global\|GrandStaff\|GregorianTranscriptionStaff\|GregorianTranscriptionVoice\|KievanStaff\|KievanVoice\|Lyrics\|MensuralStaff\|MensuralVoice\|NoteNames\|NullVoice\|OneStaff\|PetrucciStaff\|PetrucciVoice\|PianoStaff\|RemoveEmptyDrumStaffContext\|RemoveEmptyRhythmicStaffContext\|RemoveEmptyStaffContext\|RemoveEmptyTabStaffContext\|RhythmicStaff\|Score\|Staff\|StaffGroup\|TabStaff\|TabVoice\|VaticanaStaff\|VaticanaVoice\|Voice\)\(\A\|\n\)"me=e-1 nextgroup=lilyDots

syn match lilyTranslator "\u\l\+\(_\)\w*\(engraver\|performer\|translator\)"

syn match  lilyScheme  "\(#['`]\?\|\$\)[^'\"(0-9 ]*[\n ]"ms=s+1
syn match  lilyBoolean "\(##f\|##t\|#f\|#t\)\(\A\|\n\)"
syn region lilyString  start=/"/  end=/"/   skip=/\\"/
syn region lilyComment start="%{" skip="%$" end="%}"
syn region lilyComment start="%\([^{]\|$\)" end="$"
syn match  lilyDynamic "\\[<!>\\]"

if g:nvls_language == "nohl"
  syn match  lilyNumber       "[-_^.]\?\(\-\.\|\)\d\+[.]\{,3}" nextgroup=lilyChordStart,lilyArticulation,lilyFing
else 
  syn match  lilyNumber       "[-_^.]\?\(\-\.\|\)\d\+[.]\?" nextgroup=@lilyMatchGroup,lilyChordStart,lilyArticulation,lilyFing
end
syn match  lilySpecial "[(~)]\|[(*)]\|[(=)]"

syn match  lilyArticulation "\s\{}[-_^][-_^+|>|.]"" contained nextgroup=lilyFing

syn match Error ">>"
syn match Error "}"
syn match Error "\l\+\d[',]\+"
syn match Error "\<\\tuplet\(\s\|\)\+{"me=e-1

syn include @Scheme syntax/scheme.vim
unlet b:current_syntax
syn region lilySchemeReg
  \ matchgroup=Delimiter 
  \ start="#['`]\?(" 
  \ end=")" 
  \ contains=@Scheme,lilyInScheme

syn region lilyInScheme
  \ matchgroup=Delimiter 
  \ start="#{" 
  \ end="#}"
  \ contained contains=@lilyMatchGroup,lilyInScheme

syn region lilyInScheme
  \ matchgroup=Delimiter 
  \ start="(" 
  \ end=")"
  \ contains=@Scheme,lilyInScheme

syn region lilyLyrics
  \ matchgroup=lilyLyrics
  \ start="\(\\addlyrics\s\+{\|\\lyricmode\s\+{\|\\lyricsto\s\+\"\+\l\+\"\+\s\+{\)"
  \ end="}"
  \ contains=ALLBUT,lilyGrob,@lilyPitchGroup,Error,lilyVar,lilyInnerMarkup

syn region lilyInnerLyrics 
  \ matchgroup=Delimiter 
  \ start="\({\|(\|<\)" end="\(}\|)\|>\)" 
  \ contained contains=ALLBUT,lilyGrob,@lilyPitchGroup,lilyVar,lilyInnerMarkup
  \ containedin=lilyLyrics

syn match lilyGrobsExcpt "LyricText"

syn region lilyMarkupReg
  \ matchgroup=lilyMarkup
  \ start="[-_^]\?\\markup\s\+{"
  \ end="}"
  \ contains=ALLBUT,lilyFunction,lilyInnerLyrics,@lilyPitchGroup,lilyVar,lilyArticulation

syn region lilyInnerMarkup
  \ matchgroup=Delimiter
  \ start="{" 
  \ end="}" 
  \ contained contains=ALLBUT,lilyFunction,lilyInnerLyrics,@lilyPitchGroup,lilyVar
  \ containedin=lilyMarkupReg

hi link lilyInnerLyrics       lilyLyrics
hi link lilyGrobsExcpt        lilyGrob

hi link lilyRepeatType        lilyArgument
hi link lilyPitchLanguageName lilyArgument
hi link lilyAccidentalsStyle  lilyArgument
hi link lilyClef              lilyArgument

hi link lilyDefineVar         lilyVar

hi link lilyNotesAttr         lilyPitch
hi link lilyAlt               lilyPitch
hi link lilyRythm             lilyPitch
hi link lilyDotted            lilyPitch

hi link lilyFing              lilySpecial
hi link lilyChordBass         lilySpecial
hi link lilyChordStart        lilySpecial
hi link lilyDots              lilySpecial

hi link lilyChordNat          lilyChord
hi link lilyChordExt          lilyChord

let b:current_syntax = "lilypond"

let &cpo = s:keepcpo
unlet s:keepcpo
