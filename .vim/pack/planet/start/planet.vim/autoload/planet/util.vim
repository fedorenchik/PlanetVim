vim9script

com -bar -nargs=? -range=1 -addr=windows Resize exe Resize(<q-mods>, <q-count>, <q-args>)

def Resize(mods = '', count = '', args = ''): string
    var new_args: string = args
    if args =~ '\d\+%'
        var what: number = mods =~ 'vertical' ? &columns : &lines
        var Rep = (m: list<string>): number => m[1]->str2nr() * what / 100
        new_args = args->substitute('\(\d\+\)%', Rep, '')
    endif
    return mods .. ' :' .. count .. 'resize ' .. new_args
enddef
