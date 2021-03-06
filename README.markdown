**Moved to [GitLab](https://gitlab.com/victor-engmark/mkrepo)**

[![Build Status](https://travis-ci.org/l0b0/mkgithub.svg?branch=master)](https://travis-ci.org/l0b0/mkgithub)

mkgithub
========

Create a local GitHub repository with a single command.

Test
----

Requires `shunit2`.

    make test

Installation
------------

    git clone --recurse-submodules https://github.com/l0b0/mkgithub.git
    cd mkgithub
    make test
    sudo make install

To install it in another directory:

    make install PREFIX=/some/path

Usage
-----

    mkgithub.sh [<options>] [directories]

Options
-------

    -c, --configure
           Write the options in this command as the new configuration and
           exit. If run as root, it writes to /etc/mkgithub.conf, otherwise
           it writes to ~/.mkgithub.

    -g, --git
           Use git:// read-only remote URL.

    -h, --https
           Use https:// remote URL.

    -s, --ssh
           Use ssh:// remote URL (default).

    -u, --user=username
           GitHub username. Default your github.user configuration value.

    --help
           Display this information and quit.

    -v, --verbose
           Verbose output.

Examples
--------

    mkgithub.sh -ch
           Configure mkgithub to use HTTPS remote URLs.

    mkgithub.sh ~/dev/mkgithub
           Make ready for your own mkgithub clone :)
