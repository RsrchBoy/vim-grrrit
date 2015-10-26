syn match vimNumber /^\d*/
" syn match Keyword /^\d*/


" syn region grrritLine start=/^\d\+/ end=/\D/ oneline
syn match grrritChangeNum /^\d\+/
syn match grrritSep /|/

syn keyword grrritStatus NEW MERGED ABANDONED open

hi default link grrritChangeNum vimNumber
hi default link grrritSep Error
hi default link grrritStatus Keyword
