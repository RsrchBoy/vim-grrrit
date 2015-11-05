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
    elseif g:grrrit#transport == 'rest'
        return grrrit#transport#rest#query(a:query)
    elseif g:grrrit#transport == 'ssh'
        return grrrit#transport#ssh#query(a:query)
    else
        " DIE here!
    endif

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
    exec ":5," . line('$') . "Tabularize /|"

    call append(line('$'), '')

    setlocal nomodifiable
    setlocal ft=grrrit
    let b:grrrit_line = getline('.')

    nmap <buffer> <silent> <CR> :echo grrrit#buffer#util#reviewnum()<CR>

endfunc

" Approve the given change.  Note change can be '#####,#' or a commit sha1; a
" sha1 is most definitely recommended.
func! grrrit#approve(change)
    " only the ssh transport is enabled for this at the moment
    return grrrit#transport#ssh#approve(a:change)
endfunc

" Approve the commit being shown in the current buffer -- e.g. a fugutive
" revision buffer
func! grrrit#approvecurrent()
    call grrrit#approve(fugitive#buffer().commit())
endfunc

