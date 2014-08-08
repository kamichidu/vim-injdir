set runtimepath+=./.vim-test/*
filetype plugin indent on

describe 'injdir#expr_parser'
    it 'can replace embedded vim expression to plain text'
        let parser= injdir#expr_parser#new()

        let actual= parser.parse("This is a `='hoge'`.")
        let expected= ['This is a hoge.']
        Expect actual ==# expected

        let actual= parser.parse("今日は`=strftime('%Y年%M月')`だよ")
        let expected= ['今日は' . strftime('%Y年%M月') . 'だよ']
        Expect actual ==# expected
    end

    it 'simply return given text if no expression contained'
        let parser= injdir#expr_parser#new()

        let actual= parser.parse('This is a hoge.')
        let expected= ['This is a hoge.']
        Expect actual ==# expected
    end
end
