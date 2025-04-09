" Search with ag and load results into quickfix
function! ag#quickfix(...)
  if !executable('ag')
    echohl ErrorMsg
    echo "The Silver Searcher (ag) is not installed"
    echohl None
    return
  endif

  let search_term = a:0 > 0 ? a:1 : input('Search for: ')
  if empty(search_term)
    return
  endif

  let search_cmd = 'ag --vimgrep ' . shellescape(search_term)
  let results = system(search_cmd)

  if v:shell_error
    echohl ErrorMsg
    if empty(results)
      echo "No results found for: " . search_term
    else
      echo "Search failed: " . results
    endif
    echohl None
    return
  endif

  if empty(results)
    echohl WarningMsg
    echo "No results found for: " . search_term
    echohl None
    return
  endif

  cexpr results
  cwindow
  redraw!
endfunction 