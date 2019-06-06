let g:docenv_shims_dir = './.docenv'
let g:docenv_initialized = 0
let g:apps = []
let g:salt = system('pwd | md5sum')[0:31]

let $PATH = g:docenv_shims_dir . ':' .$PATH

call docenv#init()

command DocenvRefresh call docenv#rebuild_shims()

augroup docenv
  autocmd!
  autocmd VimLeave * call docenv#cleanup()
augroup END
