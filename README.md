# Manual usage

Install required dependencies into `./local`:

    $ carton

Run download and transformation (this will take a while):

    $ carton exec bin/wpextract de dewiki.templates.gz
    $ carton exec bin/wpbeacons de

This execution can best be triggered by a cronjob, see
`debian/wmbeacons.cron.weekly`.

# Installation

The repository is prepared for Debian packaging with git-dpm, but things may
not work automatically yet. In theory, a package can be build this way:

    $ git-dpm prepare && dpkg-buildpackage -rfakeroot -us -uc

In practice you still have to manually run what `dpkg install` whould do
with `sudo make manual-install` (see `Makefile`) for details.

