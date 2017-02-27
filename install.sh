#! /bin/bash

# Installing Vim.
apt-get update && \
    apt-get install sudo -y && \
    apt-get install vim-gnome -y && \
    apt-get install curl wget -y && \
    apt-get install screen -y

# Installing the compilation toolchain, git, Python and Valgrind.
apt-get install build-essential -y && \
    apt-get install python3 python-dev python3-dev python3-all -y && \
    apt-get install gcc -y && \
    apt-get install g++ -y && \
    apt-get install make cmake -y && \
    apt-get install git -y && \
    apt-get install valgrind valgrind-dbg valkyrie -y

# Copying the bashrc, the bash_aliases, ls_colors and vimrc files.
cp bashrc ~/.bashrc
cp bash_aliases ~/.bash_aliases
cp ls_colors ~/.ls_colors
cp vimrc ~/.vimrc

# Copying the template of the extra configuration files needed by YCM.
cp -r sample_ycm ~/.vim/

# Creating Vim's bundle directory.
mkdir -p ~/.vim/bundle/

# Cloning the repository of Vundle in order to install all the plugins 
# (including itself) easily.
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Launching the installation of the Vim plugins.
vim +PluginInstall +qall

# Compiling and completing the installation of YCM.
cd ~/.vim/bundle/YouCompleteMe && \
    ./install.py --clang-completer
