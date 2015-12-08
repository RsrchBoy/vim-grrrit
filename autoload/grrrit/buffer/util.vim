
func! grrrit#buffer#util#reviewnum()
    return strpart(getline("."), 0, stridx(getline("."), " "))
endfunc

func! grrrit#buffer#util#patchsetref()
    " return strpart(getline("."), 0, stridx(getline("."), " "))
    " let ref = grrrit#buffer#util#reviewnum()
    " let ref   = b:GrrritChanges[line('.')].['currentPatchSet'].['ref']
    let ref   = b:GrrritChanges[line('.')].currentPatchSet.ref
    " let ref   = b:GrrritChanges[line('.')]['currentPatchSet']['ref']
    return ref
endfunc

func! grrrit#buffer#util#patchset()
    let ref = grrrit#buffer#util#patchsetref()
    call Gitv_OpenGitCommand("show --no-color " . ref, 'new')
endfunc
