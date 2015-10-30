
func! grrrit#transport#ssh#query(query, ...)
    " let changes_json = split(s:raw_json, "\n")
    " let changes      = []
    " for change_json in changes_json
    "     let change = webapi#json#decode(change_json)
    "     call add(changes, change)
    " endfor

    let changes = grrrit#transport#ssh#get(
                \   'query',
                \   'project:ndn OR project:ndn/oneoffs limit:' . g:grrrit#changesperpage
                \)
    " last row is just a status
    call remove(changes, -1)

    " normalize
    for change in changes
        let change['updated'] = strftime("%Y-%m-%dT%H:%M:%SZ", change['lastUpdated'])
    endfor

    return changes
endfunc

" e.g.
" ssh g:grrrit#ssh_host gerrit query --current-patch-set --format json project:ndn limit:5
func! grrrit#transport#ssh#get(cmd, args)

    let shell_cmd = 'ssh ' . g:grrrit#ssh_host . ' gerrit ' . a:cmd . ' --format json ' . a:args
    echom shell_cmd

    let raw_json = systemlist(shell_cmd)
    " PPmsg raw_json

    let changes = []
    for change_json in raw_json
        let change = webapi#json#decode(change_json)
        call add(changes, change)
    endfor

    return changes
endfunc

" for review:
"   ssh g:grrrit#ssh_host gerrit review 26794,1 --verified +1 --code-review +2 --submit
