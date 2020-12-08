test:
	@gvim --noplugin -u DEFAULTS -c "set nocp" -c "set rtp+=$$(pwd)" -c "runtime! plugin/calculator.vim" -u t/calculator.vim -c "call g:RunAllTests()" -c q -f

gui-test:
	gvim --noplugin -u DEFAULTS -c "set nocp" -c "set rtp+=$$(pwd)" -c "runtime! plugin/calculator.vim" -c "Calculator"
