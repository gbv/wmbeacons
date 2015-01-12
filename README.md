# wmbeacons

**wmbeacos** is an application to regularly download, parse and transform dumps
of Wikimedia wikis to create and provide BEACON link dumps. The application
consists of a cronjob and a web application. 

The application is packaged as Debian package and installs at the following
locations:

  /srv/wmbeacons/       - application files
  /etc/wmbeacons/       - configuration
  /var/log/wmbeacons/   - log files
  /etc/init.d/wmbeacons - init script

The application has been tested on Ubuntu >= 14.04.

[![Build Status](https://travis-ci.org/gbv/wmbeacons.svg)](https://travis-ci.org/gbv/wmbeacons)

## Local execution

Install required dependencies into `./local`

    $ carton

Run download and transformation (this will take a while)

    $ carton exec bin/wpextract de dewiki.templates.gz
    $ carton exec bin/wpbeacons de

When installed, the transformation is triggered by a cronjob (see
`debian/wmbeacons.cron.weekly`).

## Packaging and installation

The repository is prepared for Debian packaging with. Version number and
changelog are not included from git yet.  An unsigned "binary" package can be
created this way (`make debian-package`)

    $ dpkg-buildpackage -b -us -uc -rfakeroot

The package can then be installed with

    $ dpkg --install wmbeacons_...deb

Dependencies must be installed before, see 

    $ dpkg -I wmbeacons_...deb

See `.traviy.yml` for detailed steps.

