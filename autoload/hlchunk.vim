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

func! hlchunk#hl_chunk(...)
    if exists('s:ns')
        call nvim_buf_clear_namespace(0, s:ns, 0, -1)
    endif
    let s:ns = nvim_create_namespace('hlchunk')

    let [beg, end] = s:getpairpos()
    if beg == end | return | endif
    if beg == 0 || end == 0 | return | endif

    " 避免渲染行数过长造成的卡顿 - 只渲染屏幕展示行+-50行的区域
    let [startl, endl] = end - beg > 100
        \ ? [max([beg, line('w0') - 50]), min([end, line('w$') + 50])]
        \ : [beg, end]

    " 渲染beg行 end行
    let [lbeg, lend] = [getline(beg), getline(end)]
    let [sbeg, send] = [len(substitute(lbeg, '\v^(\s*).*', '\1', '')), len(substitute(lend, '\v^(\s*).*', '\1', ''))]

    let slen = min([sbeg - &shiftwidth, send - &shiftwidth])
    let slen = max([slen, 0])
    let s:opt.virt_text_win_col = slen

    if sbeg == 1
        let s:virt_text = '╭'
        let s:opt.virt_text = [[s:virt_text, 'HLIndentLine']]
        call nvim_buf_set_extmark(0, s:ns, beg - 1, 0, s:opt)
    endif
    if sbeg >= 2
        let s:virt_text = '╭' . s:getchars(sbeg - 1 - slen, '─')
        let s:opt.virt_text = [[s:virt_text, 'HLIndentLine']]
        call nvim_buf_set_extmark(0, s:ns, beg - 1, 0, s:opt)
    endif

    if send == 1
        let s:virt_text = '╰'
        let s:opt.virt_text = [[s:virt_text, 'HLIndentLine']]
        call nvim_buf_set_extmark(0, s:ns, end - 1, 0, s:opt)
    endif
    if send >= 2
        let s:virt_text = '╰' . s:getchars(send - 2 - slen, '─') . '>'
        let s:opt.virt_text = [[s:virt_text, 'HLIndentLine']]
        call nvim_buf_set_extmark(0, s:ns, end - 1, 0, s:opt)
    endif

    " 渲染中间行
    for idx in range(startl + 1, endl - 1)
        if getline(idx)[slen] == ' ' || len(getline(idx)) <= slen
            let s:opt.virt_text = [['│', 'HLIndentLine']]
            call nvim_buf_set_extmark(0, s:ns, idx - 1, 0, s:opt)
        endif
    endfor
endf
