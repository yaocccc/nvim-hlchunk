let s:hlchunk_chars=get(g:, 'hlchunk_chars', ['─', '─', '╭', '│', '╰', '─', '>'])
let s:opt = {'virt_text_pos': 'overlay', 'hl_mode': 'replace'}

func! s:getpairpos() " [int, int]
    let c = getline('.')[col('.') - 1]
    let l:beg = searchpair('{', '', '}', 'znWb' . (c == '{' ? 'c' : ''))
    let l:end = searchpair('{', '', '}', 'znW' . (c == '}' ? 'c' : ''))
    return [beg, end]
endf

func! s:getchars(len, char)
    let result = ''
    for idx in range(1, a:len)
        let result = result . a:char
    endfor
    return result
endf

func! s:get_scrolled()
    let virt_col = nvim_eval_statusline("%v", {}).str - 1
    let screen_col = screencol() - get(b:, 'hlchunk_textoff', getwininfo(win_getid())[0].textoff) - win_screenpos(0)[1]
    return virt_col - screen_col
endf

func! hlchunk#hl_chunk(...)
    call hlchunk#clear_hl_chunk()
    let s:ns = nvim_create_namespace('hlchunk')

    let [beg, end] = s:getpairpos()
    if beg == end | return | endif
    if beg == 0 || end == 0 | return | endif

    " 避免渲染行数过长造成的卡顿 - 只渲染屏幕展示行+-50行的区域
    let [startl, endl] = end - beg > 100
        \ ? [max([beg, line('w0') - 50]), min([end, line('w$') + 50])]
        \ : [beg, end]

    " 解析起始位置
    let space_text = s:getchars(&shiftwidth, ' ')
    let [beg_line, end_line] = [getline(beg), getline(end)]
    let [beg_line, end_line] = [substitute(beg_line, '\v^(\s*).*', '\1', ''), substitute(end_line, '\v^(\s*).*', '\1', '')]
    let [beg_line, end_line] = [substitute(beg_line, '\t', space_text, 'g'), substitute(end_line, '\t', space_text, 'g')]
    let [beg_space_len, end_space_len] = [len(beg_line), len(end_line)]
    let space_len = min([beg_space_len - &shiftwidth, end_space_len - &shiftwidth])
    let space_len = max([space_len, 0])
    let s:opt.virt_text_win_col = space_len - s:get_scrolled()
    if s:opt.virt_text_win_col < 0 | return | endif

    " 渲染beg行
    if beg_space_len == 1
        let s:virt_text = s:hlchunk_chars[2]
        let s:opt.virt_text = [[s:virt_text, 'HLIndentLine']]
        call nvim_buf_set_extmark(0, s:ns, beg - 1, 0, s:opt)
    endif
    if beg_space_len >= 2
        let s:virt_text = s:hlchunk_chars[2] . s:getchars(beg_space_len - 2 - space_len, s:hlchunk_chars[1]) . s:hlchunk_chars[0]
        let s:opt.virt_text = [[s:virt_text, 'HLIndentLine']]
        call nvim_buf_set_extmark(0, s:ns, beg - 1, 0, s:opt)
    endif

    " 渲染end行
    if end_space_len == 1
        let s:virt_text = s:hlchunk_chars[4]
        let s:opt.virt_text = [[s:virt_text, 'HLIndentLine']]
        call nvim_buf_set_extmark(0, s:ns, end - 1, 0, s:opt)
    endif
    if end_space_len >= 2
        let s:virt_text = s:hlchunk_chars[4] . s:getchars(end_space_len - 2 - space_len, s:hlchunk_chars[5]) . s:hlchunk_chars[6]
        let s:opt.virt_text = [[s:virt_text, 'HLIndentLine']]
        call nvim_buf_set_extmark(0, s:ns, end - 1, 0, s:opt)
    endif

    " 渲染中间行
    for idx in range(startl + 1, endl - 1)
        let current_line = getline(idx)
        let current_line = substitute(current_line, '\t', space_text, 'g')
        if current_line[space_len] =~ '\s' || len(current_line) <= space_len
            let s:opt.virt_text = [[s:hlchunk_chars[3], 'HLIndentLine']]
            call nvim_buf_set_extmark(0, s:ns, idx - 1, 0, s:opt)
        endif
    endfor
endf

func! hlchunk#clear_hl_chunk(...)
    if exists('s:ns')
        call nvim_buf_clear_namespace(0, s:ns, 0, -1)
    endif
endf
