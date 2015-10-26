
" fake out the call for the moment
let s:raw_json  = '{"project":"ndn","branch":"master","id":"Iecf0423821b729b8a296012f226b6ebde42b8f75","number":"26655","subject":"scanner: signature update","owner":{"name":"Michael Ballard","email":"michael.ballard@dreamhost.com","username":"micbal56"},"url":"https://git.newdream.net/26655","createdOn":1445901212,"lastUpdated":1445901578,"sortKey":"0038bb970000681f","open":true,"status":"NEW"}'
let s:raw_json .= "\n"
let s:raw_json .= '{"project":"ndn","branch":"vantiv","id":"Iaa7234f5359fc3e141fc5c41bddbac7acb877c7f","number":"26653","subject":"vantiv: pass void tests 1c-6c","owner":{"name":"Kyle Marsh","email":"kyle.marsh@dreamhost.com","username":"kylmar4"},"url":"https://git.newdream.net/26653","createdOn":1445899373,"lastUpdated":1445900456,"sortKey":"0038bb840000681d","open":true,"status":"NEW"}'
let s:raw_json .= "\n"
let s:raw_json .= '{"project":"ndn","branch":"vantiv","id":"I3ef8252751112ba10d835466513747d029c297b7","number":"26651","subject":"vantiv: pass sale tests 1-9","owner":{"name":"Kyle Marsh","email":"kyle.marsh@dreamhost.com","username":"kylmar4"},"url":"https://git.newdream.net/26651","createdOn":1445898883,"lastUpdated":1445900231,"sortKey":"0038bb810000681b","open":true,"status":"NEW"}'
let s:raw_json .= "\n"
let s:raw_json .= '{"project":"ndn","branch":"vantiv","id":"I502a42e8f4ef8702fc0f224dd2d0ce252f9ac5ff","number":"26650","subject":"vantiv: pass credit test 1b-5b","owner":{"name":"Kyle Marsh","email":"kyle.marsh@dreamhost.com","username":"kylmar4"},"url":"https://git.newdream.net/26650","createdOn":1445898883,"lastUpdated":1445900007,"sortKey":"0038bb7d0000681a","open":true,"status":"NEW"}'
let s:raw_json .= "\n"
let s:raw_json .= '{"project":"ndn","branch":"vantiv","id":"I4fbd9da2591bbb81452c1831e4b9620a2b2b9091","number":"26640","subject":"vantiv: update certification tests with names","owner":{"name":"Kyle Marsh","email":"kyle.marsh@dreamhost.com","username":"kylmar4"},"url":"https://git.newdream.net/26640","createdOn":1445885668,"lastUpdated":1445899782,"sortKey":"0038bb7900006810","open":true,"status":"NEW"}'
let s:raw_json .= "\n"
let s:raw_json .= '{"type":"stats","rowCount":5,"runTimeMilliseconds":585}'
let s:raw_json .= "\n"

" dummy, always returns from s:raw_json no matter what the query is
"
" ...mainly for offline testing, naturally.

func! grrrit#transport#fake#query(query, ...)
    let changes_json = split(s:raw_json, "\n")
    let changes      = []
    for change_json in changes_json
        let change = webapi#json#decode(change_json)
        call add(changes, change)
    endfor

    " last row is just a status
    call remove(changes, -1)

    " normalize
    for change in changes
        change['updated'] = strftime("%Y-%m-%dT%H:%M:%SZ", change['lastUpdated'])
    endfor

    return changes
endfunc
