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
