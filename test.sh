#!/usr/bin/env bash
#
# NAME
#    test.sh - Test script
#
# BUGS
#    https://github.com/l0b0/mkgithub/issues
#
# COPYRIGHT AND LICENSE
#    Copyright (C) 2011 Victor Engmark
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
################################################################################

declare -r directory=$(dirname $(readlink -f "$0"))
declare -r cmd="${directory}/$(basename "$directory").sh"

test_invalid() {
    assertFalse "No options or directory" "\"$cmd\""
}

test_simple() {
    local -r test_dir="$(mktemp -d -u --tmpdir="${__shunit_tmpDir}")"
    assertTrue "Simple project name" "\"$cmd\" \"$test_dir\""
    assertTrue "Remove repo dir" "rm -r -- \"$test_dir\""
}

test_complex(){
    local -r test_dir="$__shunit_tmpDir"/$'--$`\! *@ \a\b\E\f\r\t\v\\\"\' \n'
    assertTrue "Complex project name" "\"$cmd\" -- $(printf %q "$test_dir")"
    assertTrue "Remove repo dir" "rm -r -- $(printf %q "$test_dir")"
}

# load and run shUnit2
test -n "${ZSH_VERSION:-}" && SHUNIT_PARENT=$0
. shunit2
