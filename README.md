vim-injdir [![Build Status](https://travis-ci.org/kamichidu/vim-injdir.svg?branch=master)](https://travis-ci.org/kamichidu/vim-injdir)
====================================================================================================

Abstract
----------------------------------------------------------------------------------------------------
This is a kind of vim plugin template plugin.

It inject a directory structure you choose placed on g:injdir\_config.template\_dir, and run some
scripts before/after injection.

## Prequirements

* [vimproc.vim](https://github.com/Shougo/vimproc.vim)
* [unite.vim](https://github.com/Shougo/unite.vim)

Installation
----------------------------------------------------------------------------------------------------

* for [neobundle.vim](https://github.com/Shougo/neobundle.vim)

    write below to your `$MYVIMRC`

    ```vim:
    NeoBundle 'kamichidu/vim-injdir', {
    \   'depends': ['Shougo/vimproc.vim', 'Shougo/unite.vim'],
    \}

    NeoBundleCheck
    ```
