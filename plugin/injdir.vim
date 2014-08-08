let s:save_cpo= &cpo
set cpo&vim

if exists('g:loaded_injdir') && g:loaded_injdir
    finish
endif
let g:loaded_injdir= 1

" the template is placed on ~/.injdir/template/
" common template is ~/.injdir/template/_/
" other templates are ~/.injdir/template/{template name}/
" script is placed on ~/.injdir/scripts/
let g:injdir_config= get(g:, 'injdir_config', {})
let g:injdir_config.template_dir= get(g:injdir_config, 'template_dir', expand('~/.injdir/template/'))
let g:injdir_config.scripts_dir= get(g:injdir_config, 'scripts_dir', expand('~/.injdir/scripts/'))

command! InjdirSetup call injdir#setup()

let &cpo= s:save_cpo
unlet s:save_cpo
