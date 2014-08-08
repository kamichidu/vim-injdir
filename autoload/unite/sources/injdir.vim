let s:save_cpo= &cpo
set cpo&vim

let s:template= {
\   'name': 'injdir/template',
\   'sorters': ['sorter_word'],
\}

function! s:template.gather_candidates(args, context)
    let injdir_context= a:context.source__injdir_context
    let template_dir= injdir_context.config.template_dir

    if !isdirectory(template_dir)
        return []
    endif

    let directories= split(globpath(template_dir, '*'), '\%(\r\n\|\r\|\n\)')

    call filter(directories, 'fnamemodify(v:val, ":t") !=# "_" && isdirectory(v:val)')

    return map(directories, "
    \   {
    \       'word': fnamemodify(v:val, ':t'),
    \       'kind': 'injdir/template',
    \       'action__delegate': a:context.source__delegate,
    \       'action__relpath':  fnamemodify(v:val, ':t'),
    \   }
    \")
endfunction

function! unite#sources#injdir#define()
    return [deepcopy(s:template)]
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
