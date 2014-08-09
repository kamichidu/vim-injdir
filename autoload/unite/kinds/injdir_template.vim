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

let s:injector=      injdir#injector#new()
let s:script_runner= injdir#script_runner#new()

let s:expand= {
\   'is_quit': 1,
\   'is_selectable': 1,
\}

function! s:expand.func(candidate)
    let candidates= (type(a:candidate) == type([])) ? deepcopy(a:candidate) : [deepcopy(a:candidate)]

    for candidate in candidates
        let template_dir= candidate.action__template_dir
        let scripts_dir=  candidate.action__scripts_dir
        let relpath=      candidate.action__relpath
        let before_scripts_dir= scripts_dir . '/' . relpath . '/before/'
        let after_scripts_dir=  scripts_dir . '/' . relpath . '/after/'

        call s:script_runner.run(before_scripts_dir, getcwd())
        call s:injector.inject(template_dir . '/' . relpath, getcwd())
        call s:script_runner.run(after_scripts_dir, getcwd())
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
