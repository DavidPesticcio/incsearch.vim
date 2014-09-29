scriptencoding utf-8

let s:suite = themis#suite('error_warning_emulation')
let s:assert = themis#helper('assert')

map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)

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

" NOTE:
" :h v:errmsg
" :h v:warningmsg

function! s:suite.error_forward_backward()
    normal! ggdG
    call s:add_lines(['1pattern', '2pattern', '3pattern', '4pattern'])
    for keyseq in ['/', '?']
        normal! gg0
        let v:errmsg = 'old errormsg'
        call s:assert.equals(s:get_pos_char(), '1')
        normal! j
        call s:assert.equals(s:get_pos_char(), '2')
        " silent! exec "normal" keyseq . "びむぅぅぅぅ\<CR>"
        " call s:assert.equals(v:errmsg, 'E486: Pattern not found: びむぅぅぅぅ')
        silent! exec "normal" keyseq . "bbb\<CR>"
        call s:assert.equals(v:errmsg, 'E486: Pattern not found: bbb')
        " feedkeys()
        silent! exec "normal" keyseq . "aaa" . keyseq . "e\<CR>"
        call s:assert.equals(v:errmsg, 'E486: Pattern not found: aaa')
        " silent! exec "normal" keyseq . "びむぅぅぅぅ\\(\<CR>"
        silent! exec "normal" keyseq . "pattern\\(\<CR>"
        call s:assert.equals(v:errmsg, 'E54: Unmatched \(')
        silent! exec "normal" keyseq . "pattern\\)\<CR>"
        call s:assert.equals(v:errmsg, 'E55: Unmatched \)')
        silent! exec "normal" keyseq . "bbb\\zA\<CR>"
        " NOTE: Skip E867: (NFA) Unknown operator '\za' error
        if exists('&regexpengine') && &regexpengine != 1
            call s:assert.equals(v:errmsg, 'E383: Invalid search string: bbb\zA')
        else " old engine
            call s:assert.equals(v:errmsg, 'E68: Invalid character after \z')
        endif
    endfor
endfunction

function! s:suite.error_stay()
    normal! ggdG
    call s:add_lines(['1pattern', '2pattern', '3pattern', '4pattern'])
    normal! gg0
    let v:errmsg = 'old errormsg'
    call s:assert.equals(s:get_pos_char(), '1')
    normal! j
    call s:assert.equals(s:get_pos_char(), '2')
    exec "normal" "g/びむぅぅぅぅ\<CR>"
    call s:assert.equals(v:errmsg, 'E486: Pattern not found: びむぅぅぅぅ')
    " feedkeys()
    silent! exec "normal" "g/aaa/e\<CR>"
    call s:assert.equals(v:errmsg, 'E486: Pattern not found: aaa')
    exec "normal" "g/びむぅぅぅぅ\\(\<CR>"
    call s:assert.equals(v:errmsg, 'E54: Unmatched \(')
    exec "normal" "g/びむぅぅぅぅ\\)\<CR>"
    call s:assert.equals(v:errmsg, 'E55: Unmatched \)')
    exec "normal" "g/びむぅぅぅぅ\\zA\<CR>"
    " NOTE: Skip E867: (NFA) Unknown operator '\za' error
    if exists('&regexpengine') && &regexpengine != 1
        call s:assert.equals(v:errmsg, 'E383: Invalid search string: びむぅぅぅぅ\zA')
    else " old engine
        call s:assert.equals(v:errmsg, 'E68: Invalid character after \z')
    endif
endfunction

function! s:suite.two_error_E383_and_E367()
    if ! exists('&regexpengine')
        call s:assert.skip("Skip because vim version are too low to test it")
    endif
    " NOTE: incsearch doesn't support more than three errors unfortunately
    let g:incsearch#do_not_save_error_message_history = 0
    let v:errmsg = ''
    exec "normal" "/びむぅぅぅぅ\\zA\<CR>"
    let save_verbose = &verbose
    let &verbose = 0
    try
        redir => messages_text
        messages
        redir END
    finally
        let &verbose = save_verbose
    endtry
    let errmsgs = reverse(split(messages_text, "\n"))
    call s:assert.equals(v:errmsg, 'E383: Invalid search string: びむぅぅぅぅ\zA')
    call s:assert.equals(errmsgs[0], 'E383: Invalid search string: びむぅぅぅぅ\zA')
    call s:assert.equals(errmsgs[1], "E867: (NFA) Unknown operator '\\zA'")
    let g:incsearch#do_not_save_error_message_history = 1
endfunction

function! s:suite.nowrapscan_forward_error()
    set nowrapscan
    normal! ggdG
    call s:add_lines(['1pattern', '2pattern', '3pattern', '4pattern'])
    normal! gg0
    let v:errmsg = 'old errormsg'
    call s:assert.equals(s:get_pos_char(), '1')
    normal! j
    call s:assert.equals(s:get_pos_char(), '2')
    exec "normal" "/1pattern\<CR>"
    call s:assert.equals(v:errmsg, 'E385: search hit BOTTOM without match for: 1pattern')
    exec "normal" "/aaa\<CR>"
    call s:assert.equals(v:errmsg, 'E385: search hit BOTTOM without match for: aaa')
    silent! exec "normal" "/aaa/e\<CR>"
    call s:assert.equals(v:errmsg, 'E385: search hit BOTTOM without match for: aaa')
    set wrapscan&
endfunction

function! s:suite.nowrapscan_backward_error()
    set nowrapscan
    normal! ggdG
    call s:add_lines(['1pattern', '2pattern', '3pattern', '4pattern'])
    normal! Gdd0
    let v:errmsg = 'old errormsg'
    call s:assert.equals(s:get_pos_char(), '4')
    normal! k
    call s:assert.equals(s:get_pos_char(), '3')
    exec "normal" "?4pattern\<CR>"
    call s:assert.equals(v:errmsg, 'E384: search hit TOP without match for: 4pattern')
    exec "normal" "?aaa\<CR>"
    call s:assert.equals(v:errmsg, 'E384: search hit TOP without match for: aaa')
    silent! exec "normal" "?aaa?e\<CR>"
    call s:assert.equals(v:errmsg, 'E384: search hit TOP without match for: aaa')
    set wrapscan&
endfunction

function! s:suite.nowrapscan_stay_error()
    set nowrapscan
    normal! ggdG
    call s:add_lines(['1pattern', '2pattern', '3pattern', '4pattern'])
    normal! gg0
    let v:errmsg = 'old errormsg'
    call s:assert.equals(s:get_pos_char(), '1')
    normal! j
    call s:assert.equals(s:get_pos_char(), '2')
    exec "normal" "g/1pattern\<CR>"
    call s:assert.equals(v:errmsg, 'E385: search hit BOTTOM without match for: 1pattern')
    exec "normal" "g/aaa\<CR>"
    call s:assert.equals(v:errmsg, 'E385: search hit BOTTOM without match for: aaa')
    silent! exec "normal" "g/aaa/e\<CR>"
    call s:assert.equals(v:errmsg, 'E385: search hit BOTTOM without match for: aaa')
    set wrapscan&
endfunction


" Warning

function! s:suite.warning_forward()
    set wrapscan
    normal! ggdG
    call s:add_lines(['1pattern', '2pattern', '3pattern', '4pattern'])
    normal! gg0
    let v:warningmsg = 'old warning'
    call s:assert.equals(s:get_pos_char(), '1')
    normal! j
    call s:assert.equals(s:get_pos_char(), '2')
    exec "normal" "/3pattern\<CR>"
    call s:assert.equals(s:get_pos_char(), '3')
    call s:assert.equals(v:warningmsg, 'old warning')
    exec "normal" "/1pattern\<CR>"
    call s:assert.equals(s:get_pos_char(), '1')
    call s:assert.equals(v:warningmsg, 'search hit BOTTOM, continuing at TOP')
endfunction

function! s:suite.warning_backward()
    set wrapscan
    normal! ggdG
    call s:add_lines(['1pattern', '2pattern', '3pattern', '4pattern'])
    normal! G0dd0
    let v:warningmsg = 'old warning'
    call s:assert.equals(s:get_pos_char(), '4')
    normal! k
    call s:assert.equals(s:get_pos_char(), '3')
    exec "normal" "?2pattern\<CR>"
    call s:assert.equals(s:get_pos_char(), '2')
    call s:assert.equals(v:warningmsg, 'old warning')
    exec "normal" "?4pattern\<CR>"
    call s:assert.equals(s:get_pos_char(), '4')
    call s:assert.equals(v:warningmsg, 'search hit TOP, continuing at BOTTOM')
endfunction

function! s:suite.do_not_show_search_hit_TOP_or_BOTTOM_warning_with_stay()
    let g:incsearch#do_not_save_error_message_history = 1
    set wrapscan
    normal! ggdG
    call s:add_lines(['1pattern', '2pattern', '3pattern', '4pattern'])
    normal! gg0
    let v:warningmsg = 'old warning'
    call s:assert.equals(s:get_pos_char(), '1')
    normal! j
    call s:assert.equals(s:get_pos_char(), '2')
    exec "normal" "g/3pattern\<CR>"
    call s:assert.equals(s:get_pos_char(), '2')
    call s:assert.equals(v:warningmsg, 'old warning')
    exec "normal" "g/1pattern\<CR>"
    call s:assert.equals(s:get_pos_char(), '2')
    call s:assert.equals(v:warningmsg, 'old warning')
    let g:incsearch#do_not_save_error_message_history = 0
endfunction

function! s:suite.handle_shortmess()
    " :h shortmess
    set shortmess+=s
    set wrapscan
    call s:assert.match(&shortmess, 's')
    normal! ggdG
    call s:add_lines(['1pattern', '2pattern', '3pattern', '4pattern'])
    normal! gg0
    let v:warningmsg = 'old warning'
    call s:assert.equals(s:get_pos_char(), '1')
    normal! j
    call s:assert.equals(s:get_pos_char(), '2')
    exec "normal" "/3pattern\<CR>"
    call s:assert.equals(s:get_pos_char(), '3')
    call s:assert.equals(v:warningmsg, 'old warning')
    exec "normal" "/1pattern\<CR>"
    call s:assert.equals(s:get_pos_char(), '1')
    call s:assert.equals(v:warningmsg, 'old warning')
    set shortmess&
endfunction

