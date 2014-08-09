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
let g:injdir_config.log_level= get(g:injdir_config, 'log_level', 'info')

command! InjdirSetup call injdir#setup()

let &cpo= s:save_cpo
unlet s:save_cpo
