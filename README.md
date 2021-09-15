# VIM HL CHUNK

hignlight chunk signcolumn plug of nvim

vim version: [vim-hlchunk](https://github.com/yaocccc/vim-hlchunk)

![sc](./screenshots/01.gif)

## OPTIONS

```options
  ENGLISH
    " what files are supported, default '*.ts,*.js,*.json,*.go,*.c'
      let g:hlchunk_files = '*.ts,*.js,*.json,*.go,*.c'
    " hlchunk indentline highlight
      au VimEnter * hi HLIndentLine ctermfg=244
    " delay default 50
      let g:hlchunk_time_delay = 50

  中文
    " 支持哪些文件 默认为 '*.ts,*.js,*.json,*.go,*.c'
      let g:hlchunk_files = '*.ts,*.js,*.json,*.go,*.c'
    " 缩进线的高亮
      au VimEnter * hi HLIndentLine ctermfg=244
    " 延时 默认为50
      let g:hlchunk_time_delay = 50
```
