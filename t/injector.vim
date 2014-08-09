set runtimepath+=./.vim-test/*
filetype plugin indent on

runtime plugin/*.vim

describe 'injdir#injector'
    before
        let g:to_dir= $TEMP . '/.vim-injdir-working/'

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

    it 'can get file structure'
        let injector= injdir#injector#new()

        let base_dir= fnamemodify('./t/fixtures/template//hoge/', ':p')

        let structure= injector.get_structure(base_dir)

        Expect has_key(structure, 'directories') to_be_true
        Expect has_key(structure, 'files') to_be_true

        let structure.files= map(structure.files, 'injector.to_relpath(base_dir, v:val)')

        Expect structure ==# {'directories': [], 'files': ['.C', 'A', 'B']}
    end

    it 'can get directory structure'
        let injector= injdir#injector#new()

        let base_dir= fnamemodify('./t/fixtures/template//fuga/', ':p')

        let structure= injector.get_structure(base_dir)

        Expect has_key(structure, 'directories') to_be_true
        Expect has_key(structure, 'files') to_be_true

        let structure.directories= map(structure.directories, 'injector.to_relpath(base_dir, v:val)')

        Expect structure ==# {'directories': ['piyo/', 'piyo/puyo/'], 'files': []}
    end

    it 'can inject directory structure'
        let injector= injdir#injector#new()

        let from_dir= fnamemodify('./t/fixtures/template/fuga/', ':p')

        call injector.inject(from_dir, g:to_dir)

        let actual= map(split(globpath(g:to_dir, '**'), '\%(\r\n\|\r\|\n\)'), 'injector.to_relpath(g:to_dir, v:val)')

        Expect actual ==# ['piyo', 'piyo/puyo']
    end

    it 'can inject file structure'
        let injector= injdir#injector#new()

        let from_dir= fnamemodify('./t/fixtures/template/hoge/', ':p')

        call injector.inject(from_dir, g:to_dir)

        let actual= map(split(globpath(g:to_dir, '**'), '\%(\r\n\|\r\|\n\)'), 'injector.to_relpath(g:to_dir, v:val)')
        let actual+= map(split(globpath(g:to_dir, '**/.*'), '\%(\r\n\|\r\|\n\)'), 'injector.to_relpath(g:to_dir, v:val)')

        call filter(actual, '!isdirectory(v:val)')
        call sort(actual)

        Expect actual ==# ['.C', 'A', 'B']
    end
end
