# Dockerfile aiming at creating an image of the latest Ubuntu distribution 
# with a fully configured C/C++ development environment:
#   - bashrc;
#   - ls_colors;
#   - vim;
#   - vimrc;
#   - Vundle;
#   - Molokai;
#   - YouCompleteMe;
#   - goyo;
#   - limelight;
#   - gcc/g++;
#   - Make;
#   - CMake;
#   - Valgrind;
#   - git;
#   - Python (needed by YCM).
FROM ubuntu:latest

# Installing Vim.
RUN apt-get update && \
    apt-get install sudo -y && \
    apt-get install vim-gnome -y && \
    apt-get install curl wget -y && \
    apt-get install screen -y

# Installing the compilation toolchain, git, Python and Valgrind.
RUN apt-get update && \
    apt-get install build-essential -y && \
    apt-get install python3 python-dev python3-dev python3-all -y && \
    apt-get install gcc -y && \
    apt-get install g++ -y && \
    apt-get install make cmake -y && \
    apt-get install git -y && \
    apt-get install valgrind valgrind-dbg valkyrie -y

# Copying the bashrc, the bash_aliases, ls_colors and vimrc files.
COPY bashrc /root/.bashrc
COPY bash_aliases /root/.bash_aliases
COPY git_template /root/.git_template
COPY ls_colors /root/.ls_colors
COPY vimrc /root/.vimrc

# Creating Vim's bundle directory.
RUN mkdir -p /root/.vim/bundle/

# Cloning the repository of Vundle in order to install all the plugins 
# (including itself) easily.
RUN git clone https://github.com/VundleVim/Vundle.vim.git /root/.vim/bundle/Vundle.vim

# Launching the installation of the Vim plugins.
RUN vim +PluginInstall +qall

# Compiling and completing the installation of YCM.
RUN cd /root/.vim/bundle/YouCompleteMe && \
    ./install.py --clang-completer

# Copying the template of the extra configuration files needed by YCM.
COPY sample_ycm /root/.vim/sample_ycm
