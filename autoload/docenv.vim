
function! docenv#init() abort
  if filereadable('.docenv.json') && (docenv#is_config_changed() != 0)
    silent execute '!mkdir -p ' . g:docenv_shims_dir
    let g:config = docenv#load_config()
    call docenv#collect_apps()
    call docenv#rebuild_shims()
  endif
endfunction

function! docenv#collect_apps() abort
  for [l:app, l:config] in items(g:config)
    call add(g:apps, l:app)
  endfor
endfunction

function! docenv#is_config_changed() abort
  silent call system('md5sum --status  --check '. g:docenv_shims_dir . '/hash.md5')
  return v:shell_error
endfunction

function! docenv#rebuild_shims() abort
    call docenv#cleanup()
    silent execute '!rm ' . g:docenv_shims_dir . '/*'
    silent execute '!mkdir -p ' . g:docenv_shims_dir

    for [l:container_name, l:config] in items(g:config)
      let l:name = 'dockerenv-' . l:container_name
      if has_key(l:config, 'args')
        let l:additional_args = l:config['args']
      else
        let l:additional_args = []
      endif

      if has_key(l:config, 'cmd')
        let l:cmd = l:config['cmd']
      else
        let l:cmd = '/bin/bash'
      endif

      for l:app_name in l:config['apps']
        call docenv#create_shim(l:app_name, l:container_name, l:config['image'], l:additional_args, l:cmd)
      endfor
    endfor
    call system('md5sum .docenv.json > ' .g:docenv_shims_dir . '/hash.md5')
endfunction

function! docenv#create_shim(app_name, container_name, image, args, cmd) abort
  let l:container_name = a:container_name . '-' . g:salt
  let l:shim = [
    \ '#!/usr/bin/env bash',
    \ 'if [ -z "$(docker ps --filter name=' . l:container_name . ' --quiet)" ]',
    \ 'then',
    \ '  docker run --detach --tty --interactive --rm \',
    \ '    --user $(id -u):$(id -g) \',
    \ '    --mount="type=bind,src=$(pwd),dst=/dockerenv" \',
    \ '    --workdir=/dockerenv \',
    \ '    --name=' . l:container_name . ' \',
    \ '    ' . a:image . ' ' . a:cmd,
    \ 'fi',
    \ 'docker exec ' . l:container_name . ' ' . a:app_name . ' "$@"']

  for l:arg in a:args
    call insert(l:shim, '    ' . l:arg . ' \', -3)
  endfor

  call writefile( l:shim, g:docenv_shims_dir . '/' . a:app_name, '')
  silent execute '!chmod 700 ' . g:docenv_shims_dir . '/' . a:app_name

endfunction

function! docenv#cleanup() abort
    execute system('docker stop $(docker ps --filter=name=' . g:salt . ' -q)')
endfunction

function! docenv#load_config() abort
  return eval(join(readfile('.docenv.json'), ' '))
endfunction
