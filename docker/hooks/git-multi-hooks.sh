#!/bin/sh
#
# git-multi-hooks.sh - Run multiple Git hooks from a single trigger.
#
# To set up multiple hooks for a Git event, do the following:
#
# 1. Create a symlink from the desired hook to this script, using relative paths
#    (e.g. `ln -s git-multi-hooks.sh pre-push`).
#
# 2. Create a directory <hook-name>.d adjacent to the symlink (e.g. `mkdir
#    pre-push.d`).
#
# 3. Add regular hook files to the directory (e.g. `vim pre-push.d/my-hook`).
#
# Adapted from https://gist.github.com/mjackson/7e602a7aa357cfe37dadcc016710931b.

# determine which hooks to run and where to find them based on how this script
# is invoked
script_dir=$(dirname $0)
hook_name=$(basename $0)
hook_dir="$script_dir/$hook_name.d"

if [ -d $hook_dir ]; then
    # capture stdin so that it can be passed to each hook
    stdin=$(cat /dev/stdin)

    # run each hook, preserving stdin and all args and exiting on any failure
    for hook in $hook_dir/*; do
        echo "Running $hook hook" >&2
        echo "$stdin" | $hook "$@"

        exit_code=$?

        if [ $exit_code != 0 ]; then
            exit $exit_code
        fi
    done
fi

# exit successfully
exit 0
