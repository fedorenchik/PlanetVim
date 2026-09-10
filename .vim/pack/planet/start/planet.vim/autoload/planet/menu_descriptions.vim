vim9script

# Ex commands are shown by menu_help. These explain actions whose interface is
# a key sequence, including operators which wait for the user's next motion.
const descriptions = {
  '.': 'Repeat the last text change, using a count if one was supplied.',
  '@:': 'Execute the most recently entered Ex command again.',
  '@@': 'Replay the macro that was executed most recently.',
  'q': 'Choose a register to start recording typed keys, or stop a recording.',
  '@': 'Choose a register whose recorded keys will be executed as a macro.',
  '"': 'Choose the register used by the next delete, yank or put operation.',
  'i': 'Enter Insert mode before the cursor.',
  'a': 'Enter Insert mode after the cursor.',
  'I': 'Enter Insert mode before the first nonblank character on this line.',
  'gI': 'Enter Insert mode in column one, before any indentation.',
  'A': 'Enter Insert mode after the last character on this line.',
  'gi': 'Return to the last insertion position and enter Insert mode.',
  'O': 'Create a line above this one and enter Insert mode there.',
  'o': 'Create a line below this one and enter Insert mode there.',
  'cc': 'Remove the current line contents and enter Insert mode.',
  'C': 'Replace the text from the cursor through the end of the line.',
  'R': 'Enter Replace mode; typing overwrites existing characters.',
  'gR': 'Enter Virtual Replace mode; typing preserves the display width of tabs.',
  'gq': 'Choose a motion or text object to format using the current formatting settings.',
  'gw': 'Choose text to format, keeping the cursor at its original position.',
  'gu': 'Choose a motion or text object whose letters will become lowercase.',
  'gU': 'Choose a motion or text object whose letters will become uppercase.',
  'g~': 'Choose a motion or text object whose letter case will be reversed.',
  'g?': 'Choose a motion or text object to transform with ROT13.',
  'g??': 'Apply the reversible ROT13 letter substitution to this line.',
  'g@': 'Choose a motion or text object to pass to the configured operatorfunc.',
  '!': 'Choose lines, then enter the shell command that will filter their contents.',
  '=': 'Choose a motion or text object to reindent using the current indent settings.',
  'gg=G': 'Reindent every line in the current buffer using its indent settings.',
  'J': 'Join this line with the next, adjusting the whitespace between them.',
  'gJ': 'Join this line with the next without adding or removing whitespace.',
  'gcc': 'Toggle a comment on the current line using the configured comment mapping.',
  'gC': 'Toggle the mapping that capitalizes letters as they are typed.',
  'N': 'Repeat the last search in the opposite direction.',
  'n': 'Repeat the last search in its original direction.',
  'gn': 'Find the next search match and select its text in Visual mode.',
  'gN': 'Find the previous search match and select its text in Visual mode.',
  '/<CR>': 'Repeat the last search toward the end of the buffer.',
  '?<CR>': 'Repeat the last search toward the start of the buffer.',
  '*': 'Search forward for the whole word under the cursor.',
  '#': 'Search backward for the whole word under the cursor.',
  'g*': 'Search forward for the cursor word, including matches inside longer words.',
  'g#': 'Search backward for the cursor word, including matches inside longer words.',
  '&': 'Repeat the last substitution on the current line without its previous flags.',
  'g&': 'Repeat the last substitution across the buffer with its previous flags.',
  'gv': 'Restore the previous Visual selection, including its selection type.',
  'v': 'Start a characterwise Visual selection at the cursor.',
  'V': 'Start a Visual selection of whole lines.',
  '<C-V>': 'Start a rectangular Visual selection of columns.',
  'gh': 'Start a characterwise Select selection; typing replaces the selection.',
  'gH': 'Start a linewise Select selection; typing replaces the selected lines.',
  'g<C-H>': 'Start a rectangular Select selection; typing replaces selected columns.',
  '<C-E>': 'Move the viewport one line toward the end of the buffer.',
  '<C-Y>': 'Move the viewport one line toward the start of the buffer.',
  'zt': 'Scroll to place the cursor line at the top of the window.',
  'zz': 'Scroll to place the cursor line in the middle of the window.',
  'zb': 'Scroll to place the cursor line at the bottom of the window.',
  '<C-O>': 'Jump to an older position in this window\x27s jump list.',
  '<TAB>': 'Jump to a newer position in this window\x27s jump list.',
  'g;': 'Go to the previous recorded change position in this buffer.',
  'g,': 'Go to the next recorded change position in this buffer.',
  'gg': 'Move to the first line of the buffer, or the supplied line number.',
  'G': 'Move to the last line of the buffer, or the supplied line number.',
  'gM': 'Move to the middle character of the current text line.',
  'gm': 'Move to the middle column of the visible screen line.',
  '(': 'Move backward to the start of a sentence.',
  ')': 'Move forward to the start of a sentence.',
  ',': 'Repeat the last f, t, F or T character search in the opposite direction.',
  ';': 'Repeat the last f, t, F or T character search in its original direction.',
  '`<': 'Jump to the exact position at the beginning of the last Visual selection.',
  '`>': 'Jump to the exact position at the end of the last Visual selection.',
  '`[': 'Jump to the beginning of the most recently changed or yanked text.',
  '`]': 'Jump to the end of the most recently changed or yanked text.',
  '{': 'Move backward to the beginning of a paragraph.',
  '}': 'Move forward to the beginning of a paragraph.',
  '[{': 'Find the previous unmatched opening brace enclosing the cursor.',
  ']}': 'Find the next unmatched closing brace enclosing the cursor.',
  '[(': 'Find the previous unmatched opening parenthesis enclosing the cursor.',
  '])': 'Find the next unmatched closing parenthesis enclosing the cursor.',
  '%': 'Jump between matching delimiters or pairs supported by the match mapping.',
  '[[': 'Move backward to a section start or an opening brace in column one.',
  ']]': 'Move forward to a section start or an opening brace in column one.',
  '[]': 'Move backward to a section end or a closing brace in column one.',
  '][': 'Move forward to a section end or a closing brace in column one.',
  'zH': 'Scroll the viewport horizontally half a screen to the left.',
  'zL': 'Scroll the viewport horizontally half a screen to the right.',
  'zh': 'Scroll the viewport horizontally one character to the left.',
  'zl': 'Scroll the viewport horizontally one character to the right.',
  'zs': 'Scroll horizontally to put the cursor at the left edge of the window.',
  'ze': 'Scroll horizontally to put the cursor at the right edge of the window.',
  'gd': 'Find the local declaration of the identifier under the cursor.',
  'gD': 'Find the declaration of the cursor identifier from the start of the file.',
  'gF': 'Open the file under the cursor and use its following line number if present.',
  'K': 'Look up the cursor word using the configured keywordprg.',
  'm': 'Choose a mark name to remember the current cursor position.',
  "'": 'Choose a mark and jump to the first nonblank character on its line.',
  '`': 'Choose a mark and jump to its exact line and column.',
  '``': 'Return to the exact position before the last jump.',
  '[`': 'Jump to the preceding lowercase mark, at its exact column.',
  ']`': 'Jump to the following lowercase mark, at its exact column.',
  'za': 'Open a closed fold at the cursor, or close an open fold.',
  'zA': 'Recursively open or close the folds at the cursor.',
  'zr': 'Increase foldlevel by one to reveal one more level of folded text.',
  'zm': 'Decrease foldlevel by one to hide one more level of folded text.',
  'zR': 'Raise foldlevel enough to show all folded text.',
  'zM': 'Set foldlevel to zero to close all folds.',
  'zv': 'Open just the folds needed to reveal the cursor line.',
  'zMzx': 'Close all folds, recalculate them and reveal the cursor line.',
  'zx': 'Recalculate folds, apply foldlevel and reveal the cursor line.',
  'zX': 'Recalculate folds and apply foldlevel without revealing the cursor line.',
  'zk': 'Move to the start of the previous fold.',
  'zj': 'Move to the start of the next fold.',
  'zf': 'Choose a motion or text object to enclose in a new fold.',
  'zd': 'Delete the fold at the cursor without deleting its text.',
  'zD': 'Delete the fold at the cursor and all nested folds, keeping their text.',
  'zE': 'Delete every fold in this window without deleting text.',
  'zuz': 'Apply the configured zuz mapping to update folds.',
  '[c': 'Jump to the preceding changed region in a diff window.',
  ']c': 'Jump to the following changed region in a diff window.',
  '[S': 'Move backward to a word marked as a spelling error.',
  ']S': 'Move forward to a word marked as a spelling error.',
  '[s': 'Move backward to an incorrect, rare or regional spelling.',
  ']s': 'Move forward to an incorrect, rare or regional spelling.',
  'z=': 'Show numbered spelling replacements for the word under the cursor.',
  '1z=': 'Replace the cursor word with the first spelling suggestion.',
  'zg': 'Add the cursor word to the persistent spelling word list as correct.',
  'zw': 'Mark the cursor word as incorrect in the persistent spelling word list.',
  'zG': 'Accept the cursor word for this Vim session only.',
  'zW': 'Mark the cursor word as incorrect for this Vim session only.',
  'zug': 'Remove the saved correct-word entry for the cursor word.',
  'zuw': 'Remove the saved incorrect or rare-word entry for the cursor word.',
  'zuG': 'Remove the session-only correct-word entry for the cursor word.',
  'zuW': 'Remove the session-only incorrect-word entry for the cursor word.',
  '<C-I>': 'Jump to a newer position in the current window jump list.',
  'q:': 'Open the command-line window to edit and execute an Ex command.',
  '"+d': 'Cut the selected text into the system clipboard register.',
  '"+y': 'Copy the selected text into the system clipboard register.',
  'y': 'Copy the selected text into the unnamed register.',
  '"_x"+gP': 'Replace the selected text with the clipboard, leaving the clipboard unchanged.',
  '"_x': 'Delete the selected text without changing the registers.',
  'w': 'Extend the selection forward to the start of the next word.',
  '<C-W>g<C-]>': 'Open the cursor word tag in a split, offering a choice when several tags match.',
  '<C-]>': 'Jump to the tag matching the word under the cursor.',
  'g<C-]>': 'Jump to the cursor word tag, offering a choice if several tags match.',
  'g]': 'List matching tags for the cursor word and choose which one to visit.',
  'q/': 'Open the command-line window to edit and execute a forward search.',
  'q?': 'Open the command-line window to edit and execute a backward search.',
  'g<TAB>': 'Switch to the most recently accessed tab page.',
  '<C-G>': 'Report the current file name, status and cursor position.',
  'g<C-G>': 'Report the cursor position and buffer totals in words, characters and bytes.',
  'g8': 'Show the hexadecimal UTF-8 bytes of the character under the cursor.',
  'ga': 'Show the numeric character code under the cursor in several bases.',
  'g<': 'Show the output from the previous command again.',
  'gQ': 'Enter Ex mode with command-line editing; use :visual to return.',
  'Q': 'Enter line-oriented Ex mode; use :visual to return.',
}

export def Describe(rhs: string, path: string): string
  var keys = substitute(rhs, '<[^>]\+>', (m) => toupper(m[0]), 'g')
  if has_key(descriptions, keys)
    return substitute(descriptions[keys], '\\x27', "'", 'g')
  endif
  var object = matchlist(rhs, '^\(v\|d\|c\|y\|gq\)\?\([ia]\)\([wWsp"''`)\]}tz]\)$')
  if !empty(object)
    var verbs = {'v': 'Select', 'd': 'Delete', 'c': 'Replace', 'y': 'Yank', 'gq': 'Format', '': 'Use'}
    var nouns = {'w': 'word', 'W': 'whitespace-delimited WORD', 's': 'sentence', 'p': 'paragraph',
      '"': 'double-quoted text', "'": 'single-quoted text', '`': 'backtick-quoted text',
      ')': 'parenthesized block', ']': 'bracketed block', '}': 'braced block',
      't': 'tagged element', 'z': 'fold'}
    return verbs[object[1]] .. ' the ' .. nouns[object[3]] .. (object[2] ==# 'i'
      ? ' contents, excluding surrounding whitespace or delimiters.'
      : ', including its surrounding whitespace or delimiters.')
  endif
  if rhs =~# '^"+\%([g\[\]]\)\?[pP]$'
    return 'Put text from the system clipboard ' .. (rhs =~# 'P$' ? 'before' : 'after') .. ' the cursor'
      .. (rhs =~# 'g' ? ', leaving the cursor after the inserted text.'
      : rhs =~# '[\[\]]' ? ', adjusting indentation to match the current line.' : '.')
  endif
  if rhs =~# '^\[\|^\]'
    var direction = rhs[0] ==# '[' ? 'previous' : 'next'
    var suffix = strpart(rhs, 1)
    if index(['m', 'M', '/', '*', '#'], suffix) >= 0
      var target = {'m': 'method opening brace', 'M': 'method closing brace', '/': 'comment boundary',
        '*': 'comment boundary', '#': 'preprocessor conditional boundary'}[suffix]
      return 'Move to the ' .. direction .. ' ' .. target .. '.'
    endif
    if suffix =~# '^[iIdD]$' || suffix =~? '^<\%(Tab\|C-I\|C-D\)>$'
      return (suffix =~# '^[iIdD]$' ? 'Display' : 'Jump to') .. ' matching identifiers or definitions in this file and included files, '
        .. (direction ==# 'previous' ? 'searching from the start of the file.' : 'searching after the cursor.')
    endif
  endif
  # Mapped actions normally resolve to a command once plugins have loaded.
  # Keep a useful contextual tip while that mapping is unavailable or expr-based.
  var parts = split(path, '\.')
  var action = empty(parts) ? 'the selected action' : parts[-1]
  var context = len(parts) > 2 ? parts[-2] : 'the current editing context'
  return 'Use ' .. rhs .. ' to ' .. tolower(action) .. ' in ' .. context .. '; complete any requested motion, register or input.'
enddef
