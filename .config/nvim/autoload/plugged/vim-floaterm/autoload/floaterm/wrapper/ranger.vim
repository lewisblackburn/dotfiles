" vim:sw=2:
" ============================================================================
" FileName: ranger.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! floaterm#wrapper#ranger#(cmd) abort
  let s:ranger_tmpfile = tempname()
  let original_dir = getcwd()
  lcd %:p:h

  let cmdlist = split(a:cmd)
  let cmd = 'ranger --choosefiles="' . s:ranger_tmpfile . '"'
  if len(cmdlist) > 1
    let cmd .= ' ' . join(cmdlist[1:], ' ')
  else
    if expand('%:p') != ''
      let cmd .= ' --selectfile="' . expand('%:p') . '"'
    else
    let cmd .= ' "' . getcwd() . '"'
    endif
  endif

  exe "lcd " . original_dir
  let cmd = [&shell, &shellcmdflag, cmd]
  return [cmd, {'on_exit': funcref('s:ranger_callback')}, v:false]
endfunction

function! s:ranger_callback(...) abort
  if filereadable(s:ranger_tmpfile)
    let filenames = readfile(s:ranger_tmpfile)
    if !empty(filenames)
      if has('nvim')
        call floaterm#window#hide(bufnr('%'))
      endif
      let locations = []
      for filename in filenames
        let dict = {'filename': fnamemodify(filename, ':p')}
        call add(locations, dict)
      endfor
      call floaterm#util#open(locations)
    endif
  endif
endfunction
