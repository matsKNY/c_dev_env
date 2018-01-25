#! /bin/bash

# This script should be run with root priviledges.
if [[ "$EUID" -ne 0 ]]; then
    echo -e "\nThis script should be run with root priviledges.\n"
    exit 1
fi

# The user for which the installation should be done.
# This should be specified by the user before running the script => TODO.
USER_INSTALL=stoffelm
DIR_INSTALL=/home/"$USER_INSTALL"
if [[ ! -d "$DIR_INSTALL" ]]; then
    echo -e "\nThe specified user seems not to exist on the system."
    echo -e "\nThe user must be specified in the header of the script file.\n"
    exit 1
fi

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
    apt-get install automake make cmake -y && \
    apt-get install git -y && \
    apt-get install valgrind valgrind-dbg valkyrie -y

# Retrieving, compiling and installing universal-ctags, which will be needed by 
# vim-orgmode.                                                                  
git clone https://github.com/universal-ctags/ctags.git                          
cd ctags
./autogen.sh && ./configure && make && make install
cd ..
rm -fr ctags

# Copying the bashrc, the bash_aliases, ls_colors and vimrc files.
install -o "$USER_INSTALL" -g "$USER_INSTALL" -m 644 bashrc "$DIR_INSTALL"/.bashrc
install -o "$USER_INSTALL" -g "$USER_INSTALL" -m 644 bash_aliases "$DIR_INSTALL"/.bash_aliases
install -o "$USER_INSTALL" -g "$USER_INSTALL" -m 644 git_template "$DIR_INSTALL"/.git_template
install -o "$USER_INSTALL" -g "$USER_INSTALL" -m 644 ls_colors "$DIR_INSTALL"/.ls_colors
install -o "$USER_INSTALL" -g "$USER_INSTALL" -m 644 vimrc "$DIR_INSTALL"/.vimrc

# Creating the directory dedicated to the laboratory notebook.
install -o "$USER_INSTALL" -g "$USER_INSTALL" -d "$DIR_INSTALL"/.lab_notebook

# Installing the push/pull scripts associated with the laboratory notebook.
install -o "root" -g "root" -m 755 push_lab_notebook.sh /usr/local/bin/push_lab_notebook
install -o "root" -g "root" -m 755 pull_lab_notebook.sh /usr/local/bin/pull_lab_notebook

# Copying the template of the extra configuration files needed by YCM.
install -o "$USER_INSTALL" -g "$USER_INSTALL" -d "$DIR_INSTALL"/.vim/
install -o "$USER_INSTALL" -g "$USER_INSTALL" -d "$DIR_INSTALL"/.vim/sample_ycm
install -o "$USER_INSTALL" -g "$USER_INSTALL" -m 644 sample_ycm/* "$DIR_INSTALL"/.vim/sample_ycm

# Installing the "vim-snippet" plugin.
install -o "$USER_INSTALL" -g "$USER_INSTALL" -d "$DIR_INSTALL"/.vim/plugin
install -o "$USER_INSTALL" -g "$USER_INSTALL" -m 644 vim-plugins/vim-snippet/snippet.vim "$DIR_INSTALL"/.vim/plugin
install -o "$USER_INSTALL" -g "$USER_INSTALL" -d "$DIR_INSTALL"/.vim/snippet
install -o "$USER_INSTALL" -g "$USER_INSTALL" -d "$DIR_INSTALL"/.vim/snippet/C
install -o "$USER_INSTALL" -g "$USER_INSTALL" -m 644 vim-plugins/vim-snippet/snippet/C/* "$DIR_INSTALL"/.vim/snippet/C

# Creating Vim's bundle directory.
install -o "$USER_INSTALL" -g "$USER_INSTALL" -d "$DIR_INSTALL"/.vim/bundle/

# Cloning the repository of Vundle in order to install all the plugins 
# (including itself) easily.
git clone https://github.com/VundleVim/Vundle.vim.git "$DIR_INSTALL"/.vim/bundle/Vundle.vim

# Launching the installation of the Vim plugins.
vim +PluginInstall +qall

# Compiling and completing the installation of YCM.
cd "$DIR_INSTALL"/.vim/bundle/YouCompleteMe && \
    ./install.py --clang-completer
