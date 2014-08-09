set runtimepath+=./.vim-test/*
filetype plugin indent on

runtime plugin/*.vim

describe 'injdir#injector'
    before
        let g:to_dir= './.vim-injdir-working/'

        if isdirectory(g:to_dir)
            throw 'directory already exists, abort test'
        endif

        call mkdir(g:to_dir, 'p')
        " can't make absolute path when g:to_dir is not exists.
        let g:to_dir= fnamemodify(g:to_dir, ':p')
    end

    after
        if isdirectory(g:to_dir)
            call system('rm -r ' . g:to_dir)
        endif
    end

    it 'can relativize filepath'
        let injector= injdir#injector#new()

        let base_dir= fnamemodify('./t/fixtures/template//hoge/', ':p')

        let fullpath= fnamemodify(base_dir . '/A', ':p')
        let relpath=  injector.to_relpath(base_dir, fullpath)

        Expect relpath ==# 'A'
    end

    it 'can inject directory structure'
        let injector= injdir#injector#new()

        let from_dir= fnamemodify('./t/fixtures/template/fuga/', ':p')

        call injector.inject(from_dir, g:to_dir)

        let expected= map(split(globpath(from_dir, '**'), '\%(\r\n\|\r\|\n\)'), 'injector.to_relpath(from_dir, v:val)')
        let actual=   map(split(globpath(g:to_dir, '**'), '\%(\r\n\|\r\|\n\)'), 'injector.to_relpath(g:to_dir, v:val)')

        Expect actual ==# expected
    end

    it 'can inject file structure'
        let injector= injdir#injector#new()

        let from_dir= fnamemodify('./t/fixtures/template/hoge/', ':p')

        call injector.inject(from_dir, g:to_dir)

        let expected= map(split(globpath(from_dir, '**'), '\%(\r\n\|\r\|\n\)'), 'injector.to_relpath(from_dir, v:val)')
        let actual=   map(split(globpath(g:to_dir, '**'), '\%(\r\n\|\r\|\n\)'), 'injector.to_relpath(g:to_dir, v:val)')

        Expect actual ==# expected
    end
end
