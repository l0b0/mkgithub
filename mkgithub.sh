#!/usr/bin/env bash
#
# NAME
#        mkgithub.sh - Create a local GitHub repository
#
# SYNOPSIS
#        mkgithub.sh [<options>] [directories]
#
# DESCRIPTION
#        Creates the directories, initializes them as Git repositories, and
#        configures the GitHub remotes.
#
#        -c, --configure
#               Write the options in this command as the new configuration and
#               exit. If run as root, it writes to /etc/mkgithub.conf, otherwise
#               it writes to ~/.mkgithub.
#
#        -g, --git
#               Use git:// read-only remote URL.
#
#        -h, --https
#               Use https:// remote URL.
#
#        -s, --ssh
#               Use ssh:// remote URL (default).
#
#        -u, --user=username
#               GitHub username. Default your github.user configuration value.
#
#        --help
#               Display this information and quit.
#
#        -v, --verbose
#               Verbose output.
#
# CONFIGURATION
#        This script looks for configuration options in /etc/mkgithub.conf and
#        ~/.mkgithub, in that order. Command line options override any options
#        in your configuration files.
#
#        protocol=ssh
#               Remote URL protocol (ssh or https).
#
# EXAMPLES
#        mkgithub.sh -ch
#               Configure mkgithub to use HTTPS remote URLs.
#
#        mkgithub.sh ~/dev/mkgithub
#               Make ready for your own mkgithub clone :)
#
# BUGS
#        https://github.com/l0b0/mkgithub/issues
#
# COPYRIGHT
#        Copyright (C) 2011-2013 Victor Engmark
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
. "$includes"/verbose_print_line.sh
unset includes

# Process parameters
params="$(getopt -o cghsu:v -l configure,git,help,https,ssh,user:,verbose --name "$0" -- "$@")" || usage $ex_usage

eval set -- "$params"
unset params

declare -ar config_files=('/etc/mkgithub.conf' "${HOME}/.mkgithub")

# Read default configuration
for config_file in "${config_files[@]}"
do
    if [ -f "$config_file" ]
    then
        source "$config_file"
    fi
done

# Command line options
while true
do
    case $1 in
        -c|--configure)
            if [ "${USER-root}" = root ]
            then
                config_write="${config_files[0]}"
            else
                config_write="${config_files[@]: -1}"
            fi
            declare -r config_write
            shift
            ;;
        --help)
            usage
            ;;
        -g|--git)
            protocol=git
            shift
            ;;
        -h|--https)
            protocol=https
            shift
            ;;
        -s|--ssh)
            protocol=ssh
            shift
            ;;
        -u|--user)
            user="$2"
            shift 2
            ;;
        -v|--verbose)
            verbose='--verbose'
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Not implemented: $1" >&2
            usage 1
            ;;
    esac
done

# Defaults
protocol=${protocol-ssh}
user="${user-$(git config github.user)}" || usage $ex_usage

# Write configuration
if [ "${config_write+defined}" = defined ]
then
    write_config() {
        if [ "${verbose+defined}" = defined ]
        then
            tee -- "$config_write"
        else
            set +o noclobber
            cat > "$config_write"
            set -o noclobber
        fi
    }
    verbose_print_line "Writing configuration in $config_write:"
    echo "# Generated configuration file
protocol=$protocol" | write_config
    exit
fi

# Create repositories
if [ $# -eq 0 ]
then
    error "No directory specified. See --help for more information." $ex_usage
fi

for repo_path
do
    mkdir ${verbose-} -- "$repo_path"
    cd -- "$repo_path"

    git init

    repo_name="$(basename -- "$repo_path")"
    case $protocol in
        git)
            repo_url="git://github.com/${user}/${repo_name}.git"
            ;;
        https)
            repo_url="https://${user}@github.com/${user}/${repo_name}.git"
            ;;
        ssh)
            repo_url="git@github.com:${user}/${repo_name}.git"
            ;;
        *)
            error "Unknown protocol $protocol" $ex_unknown
            ;;
    esac
    git remote ${verbose-} add origin -- "$repo_url"

    git config push.default matching
    git config branch.master.remote origin
    git config branch.master.merge refs/heads/master
done
