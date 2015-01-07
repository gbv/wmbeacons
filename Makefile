info:
	@echo see README.md

debian-clean:
	fakeroot debian/rules clean

debian-package:
	dpkg-buildpackage -b -us -uc -rfakeroot
	mv ../wmbeacons_* .
