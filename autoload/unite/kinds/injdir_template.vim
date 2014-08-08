let s:save_cpo= &cpo
set cpo&vim

let s:expand= {
\   'is_quit': 1,
\   'is_selectable': 1,
\}

function! s:expand.func(candidate)
    let candidates= (type(a:candidate) == type([])) ? deepcopy(a:candidate) : [deepcopy(a:candidate)]

    for candidate in candidates
        let delegate= candidate.action__delegate

        call delegate.apply(candidate)
    endfor
endfunction

let s:template= {
\   'name': 'injdir/template',
\   'default_action': 'expand',
\   'action_table': {
\       'expand': s:expand,
\   },
\}

function! unite#kinds#injdir_template#define()
    return deepcopy(s:template)
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
