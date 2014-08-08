#!/usr/bin/env rake

task :ci => [:dump, :test]

task :dump do
    sh 'vim --version'
end

task :test do
    sh <<'...'
if ! [ -d .vim-test/ ]; then
    mkdir .vim-test/
    git clone https://github.com/Shougo/vimproc.vim .vim-test/vimproc.vim/
    make -C ./.vim-test/vimproc.vim/ -f make_unix.mak
fi
...
    sh 'bundle exec vim-flavor test'
end
