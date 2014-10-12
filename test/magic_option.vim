let s:suite = themis#suite('autonlsearch')
let s:assert = themis#helper('assert')

" Helper:
function! s:add_line(str)
    put! =a:str
endfunction
function! s:add_lines(lines)
    for line in reverse(a:lines)
        put! =line
    endfor
endfunction
function! s:get_pos_char()
    return getline('.')[col('.')-1]
endfunction


function! s:reset_buffer()
    normal! ggdG
    call s:add_lines(copy(s:line_texts))
    normal! Gddgg0zt
endfunction

function! s:suite.before()
    map /  <Plug>(incsearch-forward)
    map ?  <Plug>(incsearch-backward)
    map g/ <Plug>(incsearch-stay)
    let s:line_texts = [
    \      'default cursor pos'
    \   ,  'escape only when very magic: ()'
    \   , 'no need to escape when very nomagic: $dummy'
    \   , 'brace and dot matches only when magic: "{{"'
    \   , 'escaped dot and end-of-line matches only when no magic: ZZ'
    \ ]
    call s:reset_buffer()
endfunction

function! s:suite.before_each()
    :1
endfunction

function! s:suite.after()
    call s:reset_buffer()
    let g:incsearch#magic = '\m'
endfunction


function! s:suite.can_set_very_magic()
    let g:incsearch#magic = '\v'
    exec "normal" "/\\(\\)\<CR>"
    call s:assert.equals(getline('.'), s:line_texts[1])
endfunction

function! s:suite.can_set_very_nomagic()
    let g:incsearch#magic = '\V'
    exec "normal" "/\\($\\)dummy\<CR>"
    call s:assert.equals(getline('.'), s:line_texts[2])
endfunction

function! s:suite.can_set_magic()
    let g:incsearch#magic = '\m'
    exec "normal" "/{\.\<CR>"
    call s:assert.equals(getline('.'), s:line_texts[3])
endfunction

function! s:suite.can_set_nomagic()
    let g:incsearch#magic = '\M'
    exec "normal" "/X\.$\<CR>"
    call s:assert.equals(getline('.'), s:line_texts[4])
endfunction

function! s:suite.cannot_set_other_char()
    " considered as '\m'
    let g:incsearch#magic = '\a'
    exec "normal" "/{\.\<CR>"
    call s:assert.equals(getline('.'), s:line_texts[3])
endfunction
