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
let s:S= s:V.import('Data.String')
let s:FP= s:V.import('System.Filepath')
unlet s:V

let s:injector= {
\   'attrs': {
\       'expr_parser': injdir#expr_parser#new(),
\       'logger': injdir#logger#new('injector'),
\   },
\}

function! s:injector.inject(from_path, to_path)
    let structure= self.get_structure(a:from_path)

    let save_cwd= getcwd()
    try
        execute 'lcd' a:to_path
        call self.attrs.logger.info("Change working directory to `%s'", a:to_path)

        " copy directory and file structure
        call self.attrs.logger.info('Creating directories...')
        for directory in structure.directories
            let relpath= self.to_relpath(a:from_path, directory)
            call self.attrs.logger.info("Create directory: `%s'", relpath)

            if !isdirectory(relpath)
                call mkdir(relpath, 'p')
            else
                call self.attrs.logger.warn('Already exists, skipping...')
            endif
        endfor

        call self.attrs.logger.info('Copying files...')
        for file in structure.files
            let relpath= self.to_relpath(a:from_path, file)
            call self.attrs.logger.info("Copy file: `%s' to `%s'", file, relpath)

            if !filereadable(relpath)
                let lines= readfile(file)

                call writefile(self.attrs.expr_parser.parse(lines), relpath)
            else
                call self.attrs.logger.warn('Already exists, skipping...')
            endif
        endfor
    finally
        execute 'lcd' save_cwd
    endtry
endfunction

function! s:injector.to_relpath(base_dir, filepath)
    let base_dir= substitute(s:FP.unify_separator(a:base_dir), '/\+', '/', 'g')
    let filepath= substitute(s:FP.unify_separator(a:filepath), '/\+', '/', 'g')

    let save_cwd= getcwd()
    try
        execute 'lcd' base_dir
        call self.attrs.logger.debug("Change working directory to `%s'", base_dir)
        call self.attrs.logger.debug("Current directory is `%s'", getcwd())

        let relpath= fnamemodify(filepath, ':.')
        call self.attrs.logger.debug("Relativize `%s' to `%s'", filepath, relpath)
        return relpath
    finally
        execute 'lcd' save_cwd
    endtry
endfunction

function! s:injector.get_structure(dirpath)
    let files= split(globpath(a:dirpath, '/**'), '\%(\r\n\|\r\|\n\)')
    let directories= filter(copy(files), 'isdirectory(v:val)')
    let files= filter(copy(files), 'filereadable(v:val)')

    let save_cwd= getcwd()
    try
        execute 'lcd' a:dirpath

        let directories= map(directories, 'fnamemodify(v:val, ":p")')
        let files= map(files, 'fnamemodify(v:val, ":p")')

        return {
        \   'directories': directories,
        \   'files': files,
        \}
    finally
        execute 'lcd' save_cwd
    endtry
endfunction

function! injdir#injector#new()
    return deepcopy(s:injector)
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
