# wmbeacons

* cronjob to regularly downloand, parse, and transform Wikmedia dumps
* web interface to browse and download BEACON dumps
* requires Ubuntu >= 14.10, Debian sid (unstable), jessie (testing) or
  wheezy (stable).

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

