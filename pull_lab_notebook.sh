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

# Pulling is only authorized if the "$LAB_NOTEBOOK" directory is empty.
# Otherwise, the "expertise" of the user is necessary to avoid overwriting
# non-centralized data.
if [[ ! -z "$(ls -A "$LAB_NOTEBOOK")" ]]; then
    echo -e "\nThe ${LAB_NOTEBOOK} directory is not empty."
    echo -e "The user has to pull manually to avoid overwriting" \
        "non-centralized data."
    exit 1
fi

# Getting the path to the most recent archive on the centralized server.
SERVER_DIR="$(ssh git-server "ls /lab_notebook | tail -n 1")"
SERVER_PATH="/lab_notebook/${SERVER_DIR}"

# Retrieving the last archive, then extracting its content and cleaning up.
scp -r git-server:"$SERVER_PATH" "$LAB_NOTEBOOK"
cd "$LAB_NOTEBOOK"/"$SERVER_DIR"
for file in *.org; do
    mv "$file" ..
done
cd ..
rmdir "$SERVER_DIR"
