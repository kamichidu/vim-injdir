let s:save_cpo= &cpo
set cpo&vim

let s:V= vital#of('vital')
let s:L= s:V.import('Data.List')
unlet s:V

let s:choose_template= {}

function! s:choose_template.apply(functors, context)
    let callback= {
    \   'functors': a:functors,
    \   'context': a:context,
    \}

    function! callback.apply(candidate)
        let self.context.relpath= a:candidate.action__relpath

        call s:L.shift(self.functors).apply(self.functors, self.context)
    endfunction

    call unite#start([['injdir/template']], {
    \   'source__injdir_context': a:context,
    \   'source__delegate': callback,
    \})
endfunction

let s:inject= {}

function! s:inject.apply(functors, context) abort
    let template_dir= a:context.config.template_dir
    let scripts_dir= a:context.config.scripts_dir
    let relpath= a:context.relpath

    let structure= self.get_structure(template_dir, relpath)
    let scripts= self.get_scripts(scripts_dir, relpath)

    " run before script
    echomsg 'running before scripts...'
    for script in scripts.before
        echomsg printf("run script: `%s'", script)
        let pipe= vimproc#popen2(script)

        while !pipe.stdout.eof
            echomsg pipe.stdout.read()
        endwhile

        call pipe.waitpid()
    endfor

    " copy directory and file structure
    echomsg 'creating directories...'
    for directory in structure.directories
        echomsg printf("create directory: `%s'", directory)
        if !isdirectory(directory)
            call mkdir(directory, 'p')
        endif
    endfor
    echomsg 'copying files...'
    for file in structure.files
        echomsg printf("copy file: `%s'", file)
        if !filereadable(file)
            call writefile(readfile(template_dir . '/' . relpath . '/' . file), file)
        endif
    endfor

    " run after script
    echomsg 'running after scripts...'
    for script in scripts.after
        echomsg printf("run script: `%s'", script)
        let pipe= vimproc#popen2(script)

        while !pipe.stdout.eof
            echomsg pipe.stdout.read()
        endwhile

        call pipe.waitpid()
    endfor

    call s:L.shift(a:functors).apply(a:functors, a:context)
endfunction

function! s:inject.get_structure(template_dir, relpath)
    let files= split(globpath(a:template_dir, a:relpath . '/**'), '\%(\r\n\|\r\|\n\)')
    let directories= filter(copy(files), 'isdirectory(v:val)')
    let files= filter(copy(files), 'filereadable(v:val)')

    let save_cwd= getcwd()
    try
        execute 'lcd' a:template_dir
        execute 'lcd' a:relpath

        let directories= map(directories, 'fnamemodify(v:val, ":.")')
        let files= map(files, 'fnamemodify(v:val, ":.")')

        return {
        \   'directories': directories,
        \   'files': files,
        \}
    finally
        execute 'lcd' save_cwd
    endtry
endfunction

function! s:inject.get_scripts(scripts_dir, relpath)
    let before_files= split(globpath(a:scripts_dir, a:relpath . '/before/*'), '\%(\r\n\|\r\|\n\)')
    let before_files= filter(copy(before_files), 'filereadable(v:val)')

    let after_files= split(globpath(a:scripts_dir, a:relpath . '/after/*'), '\%(\r\n\|\r\|\n\)')
    let after_files= filter(copy(after_files), 'filereadable(v:val)')

    return {
    \   'before': before_files,
    \   'after': after_files,
    \}
endfunction

let s:nop= {}

function! s:nop.apply(functors, context)
endfunction

function! injdir#setup()
    let functor= deepcopy(s:choose_template)
    let context= {
    \   'config': deepcopy(g:injdir_config),
    \}
    call functor.apply(
    \   [
    \       deepcopy(s:inject),
    \       deepcopy(s:nop),
    \   ],
    \   context
    \)
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
