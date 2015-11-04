
func! grrrit#util#buffer#reviewnum()
    return strpart(getline("."), 0, stridx(getline("."), " "))
endfunc

