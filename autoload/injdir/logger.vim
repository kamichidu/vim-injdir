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
let s:M= s:V.import('Vim.Message')
unlet s:V

let s:logger= {
\   'attrs': {
\       'name': 'anonymouse',
\       'levels': ['debug', 'trace', 'info', 'warn', 'error'],
\       'hl': {
\           'debug': 'Normal',
\           'trace': 'Normal',
\           'info':  'Normal',
\           'warn':  'WarningMsg',
\           'error': 'ErrorMsg',
\       },
\   },
\}

function! s:logger.log(level, msg)
    let now_level= index(self.attrs.levels, g:injdir_config.log_level)
    let given_level= index(self.attrs.levels, a:level)

    if given_level < now_level
        return
    endif

    let name= self.attrs.name
    let hl= self.attrs.hl[a:level]

    call s:M.echomsg(hl, printf('[%s] [%s] [%s] - %s', name, a:level, strftime('%Y-%M-%d %H:%M:%S'), a:msg))
endfunction

function! s:logger.format(fmt, args)
    if len(a:args) > 0
        return call('printf', [a:fmt] + a:args)
    else
        return a:fmt
    endif
endfunction

function! s:logger.debug(msg, ...)
    call self.log('debug', self.format(a:msg, a:000))
endfunction

function! s:logger.trace(msg, ...)
    call self.log('trace', self.format(a:msg, a:000))
endfunction

function! s:logger.info(msg, ...)
    call self.log('info', self.format(a:msg, a:000))
endfunction

function! s:logger.warn(msg, ...)
    call self.log('warn', self.format(a:msg, a:000))
endfunction

function! s:logger.error(msg, ...)
    call self.log('error', self.format(a:msg, a:000))
endfunction

function! injdir#logger#new(name)
    let logger= deepcopy(s:logger)

    let logger.attrs.name= a:name

    return logger
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
