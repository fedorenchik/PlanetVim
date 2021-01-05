" Vim syntax file
" " Language: Yocto log files
" " Maintainer: Arnstein Kleven
syntax keyword yoctoError Error ERROR
syntax keyword yoctoDebug DEBUG
syntax keyword yoctoWarning WARNING NOTE

syntax match path "\v[\_\-\/a-zA-Z0-9]+\/\S+"
syntax match fatalError "\<FATAL ERROR\>"

highlight default link yoctoError ErrorMsg
highlight default link yoctoDebug Debug
highlight default link yoctoWarning warningmsg
highlight default link path Visual
highlight default link fatalError ErrorMsg
