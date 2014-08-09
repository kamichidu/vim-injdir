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
unlet s:V

let s:parser= {}

function! s:parser.parse(lines)
    let lines= (type(a:lines) == type([])) ? a:lines : [a:lines]
    let result= []

    for line in lines
        let exprs= s:S.scan(line, '`=.\{-}`')

        " expr is `=xxxx`
        for expr in exprs
            let res= eval(matchstr(expr, '`=\zs.\{-}\ze`'))
            let line= s:S.replace_first(line, expr, res)
        endfor

        let result+= [line]
    endfor

    return result
endfunction

function! injdir#expr_parser#new()
    return deepcopy(s:parser)
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
