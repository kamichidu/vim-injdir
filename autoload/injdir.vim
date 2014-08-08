" The MIT License (MIT)
"
" Copyright (c) 2014 kamichidu
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.
let s:save_cpo= &cpo
set cpo&vim

let s:V= vital#of('injdir')
let s:L= s:V.import('Data.List')
let s:S= s:V.import('Data.String')

let s:vital_modules= {
\   'Data.List': s:L,
\   'Data.String': s:S,
\}
unlet s:V

function! injdir#vital(module)
    if has_key(s:vital_modules, a:module)
        return s:vital_modules[a:module]
    else
        throw printf("injdir: module not found `%s'", a:module)
    endif
endfunction

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

let s:inject= {
\   'expr_parser': injdir#expr_parser#new(),
\}

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
            let lines= readfile(template_dir . '/' . relpath . '/' . file)

            call writefile(self.expr_parser.parse(lines), file)
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
