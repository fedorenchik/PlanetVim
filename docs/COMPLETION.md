# Completion in Linux GVim

Use **Edit → Complete** at the insertion point. In Normal mode an action enters
Insert mode after the cursor. The default suggestion policy does not choose an
item automatically: press CTRL-N/Down to choose, CTRL-Y/Enter to accept, or
CTRL-E to cancel. The menu also has Accept and Cancel actions. The existing
CapsLock shortcut remains available; Whole lines sends native CTRL-X CTRL-L
without remapping.

Try these sources in a scratch buffer:

- **Words / Current buffer words:** type `planetarium`, then `plan` on another
  line. Words follows `complete`; Current buffer searches only this buffer.
- **Whole lines:** type `unique completion line`, then `unique` on another line.
- **Filename:** type a directory or filename prefix, including `./` or `../`.
- **Dictionary:** set this buffer's `dictionary` to a word-list file and type a
  prefix. **Thesaurus:** set `thesaurus` to a file containing a line such as
  `fast quick rapid`, then complete `fast`. Writing's existing thesaurus remains.
- **Tags:** generate a tags file, set `tags` if it is elsewhere, and type a symbol
  prefix. **Included keywords / Included definitions:** in a C buffer include a
  header containing a word or `#define`, then complete its prefix. These use
  Vim's `include`, `path`, and `define` settings.
- **Vim commands:** complete `set wildo` to `set wildoptions`; this inserts text
  into the buffer, useful while writing a vimrc.
- **Omni:** attach a language server with `PlanetLspSetup` or configure `omnifunc`.
  **User function:** configure `completefunc` for a custom completion function.
  Missing functions are reported without inserting text.
- **Spelling:** enable `spell` and select an installed `spelllang`; complete a
  misspelled word such as `helo`.
- **Register contents:** yank a word, then complete its prefix elsewhere. This
  needs Vim 9.1.1408 or newer; older versions show upgrade/help guidance.

**Settings → Completion → Automatic** chooses asyncomplete, native Vim completion,
or off. Native requires the `autocomplete` option. Changing engine disables the
other engine in existing and new buffers; manual sources remain available.
Settings are saved in PlanetVim's preferences. Fuzzy and Preinsert are mutually
exclusive; the presets remove conflicting flags. Nearest applies to buffer
matches, and original fuzzy order (`nosort`) only matters with fuzzy enabled.
The documentation popup requires a completion source that supplies information.
Unsupported presets do not change the previous setting.

**Settings → Command-line Completion** offers Popup and Fuzzy while retaining
other `wildoptions` flags. **Search → Complete Search Pattern** starts `/` and
explains the currently configured completion key; it does not replace your key
choice. Search completion requires Vim 9.1.1490. Try `/plan<Tab>`, `?plan<Tab>`,
or `:s/plan<Tab>` on supported builds. CTRL-N/CTRL-P choose, CTRL-E cancels the
popup, and CTRL-V followed by Tab inserts a literal Tab instead of completing.
