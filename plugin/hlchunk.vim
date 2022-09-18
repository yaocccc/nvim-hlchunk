let s:timerid = -1
let s:delay = get(g:, 'hlchunk_time_delay', 50)
let s:hlchunk_files = get(g:, 'hlchunk_files', '*.ts,*.js,*.json,*.go,*.c')
let s:hlchunk_line_limit = get(g:, 'hlchunk_line_limit', 5000)
let s:hlchunk_col_limit = get(g:, 'hlchunk_col_limit', 500)
let s:hlchunk_hi_style = get(g:, 'hlchunk_hi_style', 'ctermfg=244')

exec('au CursorMoved,CursorMovedI,TextChanged,TextChangedI,TextChangedP ' .. s:hlchunk_files ..  ' call <SID>hlchunk()')
exec('au BufEnter,TextChanged,TextChangedI,TextChangedP ' .. s:hlchunk_files .. ' let b:hlchunk_enabled=<SID>check()')
exec('au BufEnter,BufRead,TextChanged,TextChangedI,TextChangedP ' .. s:hlchunk_files .. ' let b:hlchunk_textoff=getwininfo(win_getid())[0].textoff')
exec('au WinScrolled * call <SID>hlchunk()')
exec('hi HLIndentLine ' .. s:hlchunk_hi_style)

func s:hlchunk()
    if get(b:, 'hlchunk_enabled', 0) == 1
        call timer_stop(s:timerid)
        let s:timerid = timer_start(s:delay, 'hlchunk#hl_chunk', {'repeat': 1})
    else
        call hlchunk#clear_hl_chunk()
    endif
endf

func s:check()
    if line("$") > s:hlchunk_line_limit
        return 0
    endif
    for idx in range(1, line("$"))
        if len(getline(idx)) > s:hlchunk_col_limit
            return 0
        endif
    endfor
    return 1
endf
