info:
	@echo see README.md

# unless Debian packaging is ready
manual-install:
	mkdir -p /srv/wmbeacons
	mkdir -p /var/log/wmbeacons
	mkdir -p /etc/wmbeacons
	cp dewiki.namespaces /srv/wmbeacons
	cp cpanfile          /srv/wmbeacons
	cp cpanfile.snapshot /srv/wmbeacons
	cp -r bin            /srv/wmbeacons/bin
	cp -r local          /srv/wmbeacons/local
	cp debian/wmbeacons.cron.weekly /etc/cron.weekly/wmbeacons
	cp etc/init.d/wmbeacons /etc/init.d
	cp etc/wmbeacons.yaml /etc/wmbeacons
	cp etc/index.html     /etc/wmbeacons
	debian/postinst configure
