set runtimepath+=./.vim-test/*
filetype plugin indent on

runtime plugin/*.vim

describe 'injdir#injector'
    it 'can relativize filepath'
        let injector= injdir#injector#new()

        let base_dir= fnamemodify('./t/fixtures/template//hoge/', ':p')

        let fullpath= fnamemodify(base_dir . '/A', ':p')
        let relpath=  injector.to_relpath(base_dir, fullpath)

        Expect relpath ==# 'A'
    end
end
