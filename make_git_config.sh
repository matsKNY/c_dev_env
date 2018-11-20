#! /bin/bash

# Defining the return codes of this script.
EXIT_SUCCESS=0
EXIT_FAILURE=1

# Defining the help_file function which prints the help file associated with
# this script, and then exits.
function help_file {
    echo "
Help file - make_git_config.sh:

1) Brief description
    This script aims at automating the creation of a git global configuration
    file.

2) Options
    Hereinbelow is a list of the options of this script. Please note that it is
    compulsory to supply all the options marked as \"Required\":

    -e editor   Required. Sets the default text editor to be used by git.

    -h          Prints this help file.

    -m email    Required. Sets the e-mail address to be associated by git to
                the user.

    -n name     Required. Sets the username to be associated by git to the 
                user.
"
    exit "$EXIT_SUCCESS"
}

# Defining the variable which contains the path where the configuration file
# should be created.
PATH="$(cd ; pwd)"
CONFIG_PATH="${PATH}/.gitconfig"
TEMPLATE_PATH="${PATH}/.git_template"

# Defining the variable which must be set thanks to the options.
EDITOR=""
MAIL=""
NAME=""

# Handling the arguments:
while getopts ":e:hm:n:" arg; do
    case "$arg" in
        e)
            EDITOR="$OPTARG"
            ;;
        h)
            help_file
            ;;
        m)
            MAIL="$OPTARG"
            ;;
        n)
            NAME="$OPTARG"
            ;;
        :)
            echo -e "\nOption \"-${OPTARG}\" requires an argument."
            echo -e "Try ./make_git_config.sh -h.\n"
            exit "$EXIT_FAILURE"
            ;;
        \?)
            echo -e "\nInvalid option \"-${OPTARG}\"."
            echo -e "Try ./make_git_config.sh -h.\n"
            exit "$EXIT_FAILURE"
            ;;
    esac
done

# If no argument supplied at all, printing the help file.
if [[ "$#" -eq 0 ]]; then
    help_file
fi

# Checking that the necessary options have been supplied.
if [[ -z "$EDITOR" ]]; then
    echo -e "\nThe editor should have been defined thanks to the \"-e\" option.\n"
    exit "$EXIT_FAILURE"
fi

if [[ -z "$MAIL" ]]; then
    echo -e "\nThe e-mail should have been defined thanks to the \"-m\" option.\n"
    exit "$EXIT_FAILURE"
fi

if [[ -z "$NAME" ]]; then
    echo -e "\nThe name should have been defined thanks to the \"-n\" option.\n"
    exit "$EXIT_FAILURE"
fi

# Main - creating the git configuration file.
echo "
[alias]
    lg = \"log --color --oneline --graph --date=short \
--pretty=format:'%C(yellow)%h%Creset => %<(85) %s by %C(bold blue)%<(20)%an%Creset on %Cgreen(%cd)%Creset'\"
[color]
	branch = true
	diff = true
	status = true
	ui = true
[commit]
    template = ${TEMPLATE_PATH}
[core]
	editor = ${EDITOR}
[user]
	name = ${NAME}
	email = ${MAIL}
" > "$CONFIG_PATH"
