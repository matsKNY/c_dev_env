#! /bin/bash

# If an error occurs, exiting the script.
set -eo pipefail

# The "LAB_NOTEBOOK" environment variable must be defined, and point to the
# directory containing the laboratory notebook.
if [[ -z "$LAB_NOTEBOOK" || ! -d "$LAB_NOTEBOOK" ]]; then
    echo -e "\nThe \"LAB_NOTEBOOK\" environment variable must be defined, and" 
    echo -e "point to the directory containing the laboratory notebook."
    exit 1
fi

# Defining the list of files to push to the centralized server.
FILE_LIST="${LAB_NOTEBOOK}/ideas.org ${LAB_NOTEBOOK}/knowledge.org"
FILE_LIST="${FILE_LIST} ${LAB_NOTEBOOK}/todo.org ${LAB_NOTEBOOK}/notebook.org"
FILE_LIST="${FILE_LIST} ${LAB_NOTEBOOK}/references.org ${LAB_NOTEBOOK}/writing.org"

# Building the name of the temporary directory which will be pushed to the
# centralized server.
TMP_DIRNAME="${LAB_NOTEBOOK}/$(date -u +%Y-%m-%dT%H-%M-%S)"

# Creating and filling the temporary directory.
mkdir "$TMP_DIRNAME"
for file in $FILE_LIST; do
    cp "$file" "$TMP_DIRNAME"
done

# Sending the archive directory to the centralized server.
scp -r "$TMP_DIRNAME" git-server:/lab_notebook

# Removing the temporary directory since it has been sent.
rm -fr "$TMP_DIRNAME"
