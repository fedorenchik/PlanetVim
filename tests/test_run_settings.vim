let s:root = planet#project#Root()
let s:profile = {'name': 'first', 'argv': ['echo', 'literal argument'], 'cwd': ''}
call assert_equal(1, planet#run#SetProfiles([s:profile]))
let s:path = planet#paths#State('projects') .. '/' .. sha256(s:root) .. '.vim'
call assert_equal([s:profile], planet#storage#Read(s:path).profiles)
call assert_equal(1, planet#run#EditConfig())
call assert_equal(s:path, expand('%:p'))
let s:changed = deepcopy(s:profile)
let s:changed.name = 'edited in Vim'
let s:data = planet#storage#Read(s:path)
let s:data.profiles = [s:changed]
call planet#storage#Write(s:path, s:data)
edit!
write
call assert_equal([s:changed], planet#run#Project().profiles)
call setline(1, ['vim9script', 'export var config = {profiles: []}'])
silent 3,$delete _
write
call assert_equal([s:changed], planet#run#Project().profiles, 'invalid edits preserve active run profiles')
tabclose!
