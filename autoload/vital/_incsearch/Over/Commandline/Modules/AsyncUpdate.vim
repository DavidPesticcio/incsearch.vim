scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! s:_vital_loaded(V)
	let s:V = a:V
	let s:Base = s:V.import("Over.Commandline.Base")
endfunction


let s:module = {
\	"name" : "AsyncUpdate"
\}

function! s:module.on_enter(cmdline)
	function! a:cmdline.__update()
		call self.callevent("on_update")
		try
			if !getchar(1)
				return
			endif
			call self.__inputting()
		catch /^Vim:Interrupt$/
			call self.__input("\<C-c>")
		endtry

		call self.draw()
	endfunction
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

let s:___revitalizer_functions___ = {'_vital_loaded': s:___revitalizer_function___('s:_vital_loaded'),'make': s:___revitalizer_function___('s:make')}

unlet! s:___revitalizer_sid
delfunction s:___revitalizer_function___

function! vital#_incsearch#Over#Commandline#Modules#AsyncUpdate#import() abort
  return s:___revitalizer_functions___
endfunction
" ___Revitalizer___
