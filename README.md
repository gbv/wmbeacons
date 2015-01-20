# NAME

wmbeacons - BEACON file provider 

[![Build Status](https://travis-ci.org/gbv/wmbeacons.svg)](https://travis-ci.org/gbv/wmbeacons)

# DESCRIPTION

**wmbeacons** is an application to regularly download, parse and transform
dumps of Wikimedia wikis to create and provide BEACON link dumps. The
application consists of a cronjob and a web application. 

# SYNOPSIS

The application is automatically started as service, listening on port 6019.

    sudo service wmbeacons {status|start|stop|restart}

# INSTALLATION

The application is packaged as Debian package and installed at
`/srv/wmbeacons/`. Log files are located at `/var/log/wmbeacons/`.

# CONFIGURATION

See `/etc/default/wmbeacons` for basic configuration and `/etc/wmbecons` for
additional settings. Restart is needed after changes.

# SEE ALSO

Source code at <https://github.com/gbv/wmbeacons>

