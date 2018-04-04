#!/usr/bin/env bash
#
# NAME
#        all.sh - Clone all your public GitHub repositories
#
# SYNOPSIS
#        all.sh directory
#
# DESCRIPTION
#        Runs mkgithub.sh for each of your repositories.
#
# EXAMPLES
#        all.sh ~/dev
#               Clone all your repositories
#
# BUGS
#        https://github.com/l0b0/mkgithub/issues
#
# COPYRIGHT
#        Copyright (C) 2018 Victor Engmark
#
#        This program is free software: you can redistribute it and/or modify
#        it under the terms of the GNU General Public License as published by
#        the Free Software Foundation, either version 3 of the License, or
#        (at your option) any later version.
#
#        This program is distributed in the hope that it will be useful,
#        but WITHOUT ANY WARRANTY; without even the implied warranty of
#        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#        GNU General Public License for more details.
#
#        You should have received a copy of the GNU General Public License
#        along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
################################################################################

set -o errexit -o noclobber -o nounset -o pipefail

includes="$(dirname -- "$0")"/shell-includes
. "$includes"/error.sh
. "$includes"/usage.sh
. "$includes"/variables.sh
. "$includes"/warning.sh
unset includes

if [ $# -ne 1 ]
then
    usage $ex_usage
fi

target_directory="$1"

declare -ar config_files=('/etc/mkgithub.conf' "${HOME}/.mkgithub")

# Read default configuration
for config_file in "${config_files[@]}"
do
    if [ -f "$config_file" ]
    then
        source "$config_file"
    fi
done

user="${user-$(git config github.user)}" || usage $ex_usage

page=1
while true
do
    repos=($(curl "https://api.github.com/users/${user}/repos?per_page=100&page=${page}" | jq --raw-output '.[] | .name'))

    if [[ "${#repos[@]}" -eq 0 ]]
    then
        break
    fi

    for repository in "${repos[@]}"
    do
        repository_directory="${target_directory}/${repository}"
        if [[ -e "$repository_directory" ]]
        then
            warning "Directory already exists; skipping: ${repository_directory}"
            continue
        fi
        "$(dirname -- "$0")/mkgithub.sh" "$repository_directory"
    done

    ((page++))
done
