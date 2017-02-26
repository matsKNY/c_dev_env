# DevEnv: C/C++  
## Abstract  
This repository aims at automating the installation and setting up process of the development environment I am using when it comes to code in C and C++ programming languages.  
Two ways of automation have been considered:  
    * **Docker**: supplying a Dockerfile, and the related files, to build a Docker image containing the development environment.  
    It is a convenient way when your user account is not a sudoer/has not root priviledges (given that Docker is installed, which is ever more likely, and that your user account may run it), or when you do not want/cannot install new software on the host machine;  
    * **Script**: supplying a Bash script, and the related files, to install the development environment on the host machine.  
## Components of the development environment  
The development environment to be installed is composed of the hereinbelow software components:  
    * **Bash** configuration files: the *.bashrc*, *.bash_aliases* and *.ls_colors* files;  
    * **gcc** and **g++**: the "common" Unix compilation toolchain for the C and C++ programming languages;  
    * **Make** and **CMake**: a set of compilation automation tools;  
    * **Valgrind**: a tool aiming at checking memory usage and handling;  
    * **git**: a versioning tool;  
    * **Python**: quite handy for scripting and quick proof-of-concept implementation;  
    * **vim**: the VI iMproved text editor, along with several plugins:  
     * **YouCompleteMe**: an autocompletion plugin, with a lot of advanced features such as on-the-fly syntax checking;  
     * **Goyo**: a plugin to make **vim** a refined, sober and clean text editor to take notes rather than produce lines of code;  
     * **Limelight**: a "focuser" which highlights only the current paragraph. To be used together with **Goyo** to take notes efficiently.  
## How to
The first step is to clone the current repository to the host machine:  
``` bash
user@host $> git clone https://github.com/matsKNY/c_dev_env.git
```  
Then, accordingly to the way you choose, the procedure to follow is detailed in the associated paragraph, hereinbelow.  
### How to - Docker way  
First, make sure the current directory is the one you just cloned:  
``` bash
user@host $> cd c_dev_env
```  
Then, build the Docker image - you have to choose and specify the name of the image to be built:  
``` bash
user@host $> docker build -t "image/name" .
```  
The main idea is then to use a Docker volume to attach the project/source code to be edited (which will be stored on the host machine) to a detach instance of the image we have just created.  
You have to choose and specify the name of instance to create, to specify the absolute path to the project/source code to attach, and choose and specify the path it must be attached to on the instance:  
``` bash
user@host $> docker run -d -t --name "instance_name" -v /path/to/code/host:/path/to/code/docker "image/name"
```  
Then, you can open a bash shell on the instance to work on the source code (you can think of it as a SSH connection to a remote host):  
``` bash
user@host $> docker exec -t -i "instance_name" /bin/bash
```
Once you have finished editing, you can, from the host machine (after exiting the shell), get the edited files:  
``` bash
user@host $> docker cp "instance_name":/path/to/code/docker /dest/path/host
```  
Finally, when you are done with the current instance, you can stop and remove it (the created volume may share the same fate):  
``` bash
user@host $> docker stop "instance_name"
user@host $> docker rm "instance_name"
user@host $> docker volume list
user@host $> docker volume rm "volume_id"
```  
### How to - Script way
**TODO**
