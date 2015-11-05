
func! grrrit#buffer#util#reviewnum()
    return strpart(getline("."), 0, stridx(getline("."), " "))
endfunc

