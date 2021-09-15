hi HLIndentLine ctermfg=244

let s:timerid = -1
let s:delay = get(g:, 'hlchunk_time_delay', 50)
let s:hlchunk_files = get(g:, 'hlchunk_files', '*.ts,*.js,*.json,*.go,*.c')

exec('au CursorMoved,CursorMovedI,TextChanged,TextChangedI,TextChangedP ' .. s:hlchunk_files ..  ' call <SID>hlchunk()')

func s:hlchunk()
    call timer_stop(s:timerid)
    let s:timerid = timer_start(s:delay, 'hlchunk#hl_chunk', {'repeat': 1})
endf
