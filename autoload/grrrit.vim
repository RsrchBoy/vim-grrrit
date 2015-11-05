" FIXME No autoload guard here


let s:changesbuffer = 'Grrrit-Changes'

"# testing or not
" let g:grrrit#transport = 'fake'
let g:grrrit#transport = 'ssh'
" let g:grrrit#transport = 'rest'

" rest, ssh
" let g:grrrit#method = 'ssh'

let g:grrrit#changesperpage = 40

func! grrrit#query(query)
    " for now, just fake it out.
    " split and remove the last status element

    if g:grrrit#transport == 'fake'

        return grrrit#transport#fake#query(a:query)

        let l:raw_json = s:raw_json
    elseif g:grrrit#transport == 'rest'

        return grrrit#transport#rest#query(a:query)

    elseif g:grrrit#transport == 'ssh'

        return grrrit#transport#ssh#query(a:query)
    else
        " DIE here!
    endif

    let changes_json = split(l:raw_json, "\n")
    let changes      = []
    for change_json in changes_json
        let change = webapi#json#decode(change_json)
        call add(changes, change)
    endfor

    return changes
endfunc

func! grrrit#querystatusline(stats)

    return "Gerrit query stats: " . a:stats['rowCount']
                \ . " rows returned, "
                \ . a:stats['runTimeMilliseconds'] . "ms consumed"
endfunc


func! grrrit#changes() abort

    let l:query = '--current-patch-set project:ndn limit:5'

    exec ":silent tab new " . s:changesbuffer
    " tab split  s:changesbuffer

    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal modifiable

    call append(0, 'hi!')
    call append(line('$'), '')
    call append(line('$'), '** query was: ' . l:query)
    call append(line('$'), '')

    let b:GrrritChanges = {}

    " split and remove the last status element
    let changes = grrrit#query(l:query)
    let grr_statusline = changes[-1]
    call remove(changes, -1)

    for change in changes
        let b:GrrritChanges[line('$')] = change
        call append(line('$'), change['number']
                    \ . ' | ' . change['project']
                    \ . ' | ' . change['status']
                    \ . ' | ' . change['owner']['name']
                    \ . ' | ' . change['subject']
                    \ . ' | ' . change['updated']
                    \)
                    " \ . ' | ' . strftime("%Y-%m-%dT%H:%M:%SZ",change['lastUpdated'])
                    " \ . ' | ' . change['owner']['username']
                    " \ . ' | ' . (change['open'] ? 'open' : 'closed')
    endfor
    " :%Tabularize /|
    exec ":5," . line('$') . "Tabularize /|"

    " call append(line('$'), 'md5: ' . webapi#hmac#md5('one', 'two'))
    call append(line('$'), '')
    "# the following is only easy to get off of the ssh transport...
    " call append(line('$'), webapi#json#encode(grr_statusline))
    " call append(line('$'), grrrit#querystatusline(grr_statusline))

    setlocal nomodifiable
    setlocal ft=grrrit
    let b:grrrit_line = getline('.')

    "au CursorMoved <buffer> call grrrit#cursormoved()

    nmap <buffer> <silent> <CR> :echo grrrit#buffer#util#reviewnum()<CR>

    " FIXME temp until we're being used as a plugin
    " source ~/work/vim/vim-grrrit/syntax/grrrit.vim

endfunc

func! grrrit#cursormoved()

    echo b:grrrit_line
    if b:grrrit_line == getline('.')
        return
    endif
endfunc
