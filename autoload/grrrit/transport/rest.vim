" Grrrit ssh transport
"
" Chris Weyl <cweyl@alumni.drew.edu> 2015

" with CURRENT_REVISION
"
 " {'_sortkey': '0038c63200006854',
 "  'branch': 'lets-encrypt',
 "  'created': '2015-10-28 19:55:26.000000000',
 "  'current_revision': '572c716287a9b6462136593c8001649cb54ba7aa',
 "  'id': 'Ic607f286b1534ef8fc84604ae7e78ba320be3e04',
 "  'number': 26708,
 "  'owner': {'name': 'Michael Ballard'},
 "  'project': 'ndn',
 "  'revisions':
 "  {'572c716287a9b6462136593c8001649cb54ba7aa':
 "   {'_number': 2, 'fetch': {'http': {'ref': 'refs/changes/08/26708/2', 'url': 'https://git.newdream.net/ndn'}, 'ssh': {'ref': 'refs/changes/08/26708/2', 'url': 'ssh://git.newdream.net:29418/ndn'}}}},
 "  'status': 'NEW',
 "  'subject': 'LetsEncrypt: JWK Thumbprint',
 "  'updated': '2015-10-28 20:34:34'},

" with LABELS, too
"
 " {'_sortkey': '0038c60d000066f3',
 "  'branch': 'lets-encrypt',
 "  'created': '2015-10-12 23:30:37.000000000',
 "  'current_revision': 'd5ac9b17467ab3020e69d653d01bbc18115547cd',
 "  'id': 'If424a0912929aee0345ab10d2113f1b0ed1ff866',
 "  'labels': {'Code-Review': {}, 'Verified': {'approved': {'name': 'Jenkins'}}},
 "  'number': 26355,
 "  'owner': {'name': 'Michael Ballard'},
 "  'project': 'ndn',
 "  'revisions':
 "  {'d5ac9b17467ab3020e69d653d01bbc18115547cd':
 "   {'_number': 14, 'fetch': {'http': {'ref': 'refs/changes/55/26355/14', 'url': 'https://git.newdream.net/ndn'}, 'ssh': {'ref': 'refs/changes/55/26355/14', 'url': 'ssh://git.newdream.net:29418/ndn'}}}},
 "  'status': 'NEW',
 "  'subject': 'LetsEncrypt: Preliminary implementation of JWS',
 "  'updated': '2015-10-28 19:57:14'},

" https://git.newdream.net/Documentation/rest-api.html#changes


func! grrrit#transport#rest#query(query, ...) abort

    let l:queryopts  = '/changes/?q=project:ndn&format=JSON&o=CURRENT_REVISION&o=LABELS'
    let l:queryopts .= '&n=' . g:grrrit#changesperpage

    let changes = grrrit#transport#rest#get(l:queryopts)

    for change in changes
        if get(change, '_number') != 0
            let change['number'] = change['_number']
            call remove(change, '_number')
        endif
        let change['updated'] = strpart(change['updated'], 0, strlen(change['updated'])-10)
    endfor
    " PPmsg changes

    return changes
endfunc

func! grrrit#transport#rest#get(query, ...) abort

    let l:rsp = s:getwithdigest(
                \   g:grrrit#userid,
                \   g:grrrit#passwd,
                \   g:grrrit#rest_url . a:query,
                \)

    let l:raw_json = l:rsp.content

    " There's this weird string before
    " the JSON.  I don't know what that's about, but we'll get rid of it.  If
    " anyone *does* know what it's about, you'll win my appreciation for
    " solving this mystery for me :)
    if l:raw_json =~ "^)]}'\n"
        let l:raw_json = strpart(l:raw_json, 5)
    endif

    " Gerrit returns JSON responses over REST in a containing array; this is
    " at variance with the JSON response to ssh-based queries

    let response = webapi#json#decode(l:raw_json)

    return response
endfunc

func! s:getwithdigest(userid, passwd, url) abort

    let l:rsp = webapi#http#get(
                \ a:url,
                \ {},
                \ {},
                \ 1,
                \ "--digest --user '" . g:grrrit#userid . ':' . g:grrrit#passwd . "'"
                \)

    return l:rsp
endfunc

