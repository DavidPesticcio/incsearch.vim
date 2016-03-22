scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:module = {
\	"name" : "Paste"
\}

function! s:module.on_char_pre(cmdline)
	if a:cmdline.is_input("<Over>(paste)")
		let register = v:register == "" ? '"' : v:register
		call a:cmdline.insert(tr(getreg("*"), "\n", "\r"))
		call a:cmdline.setchar('')
	endif
endfunction


function! s:make()
	return deepcopy(s:module)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
" ___Revitalizer___
" NOTE: below code is generated by :Revitalize.
" Do not mofidify the code nor append new lines
if v:version > 703 || v:version == 703 && has('patch1170')
  function! s:___revitalizer_function___(fstr) abort
    return function(a:fstr)
  endfunction
else
  function! s:___revitalizer_SID() abort
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze____revitalizer_SID$')
  endfunction
  let s:___revitalizer_sid = '<SNR>' . s:___revitalizer_SID() . '_'
  function! s:___revitalizer_function___(fstr) abort
    return function(substitute(a:fstr, 's:', s:___revitalizer_sid, 'g'))
  endfunction
endif

let s:___revitalizer_functions___ = {'make': s:___revitalizer_function___('s:make')}

unlet! s:___revitalizer_sid
delfunction s:___revitalizer_function___

function! vital#_incsearch#Over#Commandline#Modules#Paste#import() abort
  return s:___revitalizer_functions___
endfunction
" ___Revitalizer___
