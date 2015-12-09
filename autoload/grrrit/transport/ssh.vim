

func! grrrit#transport#ssh#query(query, ...)
    " let changes_json = split(s:raw_json, "\n")
    " let changes      = []
    " for change_json in changes_json
    "     let change = webapi#json#decode(change_json)
    "     call add(changes, change)
    " endfor

    let changes = grrrit#transport#ssh#get(
                \   'query',
                \   '--current-patch-set project:ndn OR project:ndn/oneoffs limit:' . g:grrrit#changesperpage
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

    let raw_json = grrrit#transport#ssh#raw(a:cmd, '--format json ' . a:args)
    " PPmsg raw_json

    let changes = []
    for change_json in raw_json
        let change = webapi#json#decode(change_json)
        call add(changes, change)
    endfor

    return changes
endfunc

func! grrrit#transport#ssh#raw(cmd, args)

    let shell_cmd = 'ssh ' . g:grrrit#ssh_host . ' gerrit ' . a:cmd . ' ' . a:args
    echom shell_cmd

    return systemlist(shell_cmd)
endfunc


" for review:
"   ssh g:grrrit#ssh_host gerrit review 26794,1 --verified +1 --code-review +2 --submit
" dispatch#compile_command(0, "ssh ndngit gerrit review --code-review +2 " . fugitive#repo().rev_parse(fugitive#repo().head()), 1)
" fugitive#buffer().commit()
" dispatch#compile_command(0, "ssh ndngit gerrit review --code-review +2 " . fugitive#buffer().commit(), 1)

func! grrrit#transport#ssh#approve(change)

    " TODO FIXME stop bypassing our own transport bits here...
    " call grrrit#transport#ssh#get()
    " call dispatch#compile_command(0, "ssh ndngit gerrit review --code-review +2 " . fugitive#buffer().commit(), 1)
    echom "+2'ing " . a:change
    call dispatch#compile_command(0, "ssh ndngit gerrit review --code-review +2 " . a:change, 1)
endfunc

