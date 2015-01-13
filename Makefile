info:
	@echo see README.md

# create single entry from last tag
debian-changelog:
	@VERSION=`git describe --tags` ;\
		echo "wmbeacons ($$VERSION) unstable; urgency=low" > debian/changelog ;\
		echo >> debian/changelog ;\
		AUTHOR=`git show -s --format="%an <%ae>" $$VERSION` ; \
		DATE=`git show -s --format="%ad" $$VERSION | awk '{ print $$1",",$$3,$$2,$$5,$$4,$$6 }'` ; \
		echo " -- $$AUTHOR  $$DATE" >> debian/changelog

debian-clean:
	fakeroot debian/rules clean

debian-package:
	dpkg-buildpackage -b -us -uc -rfakeroot
	mv ../wmbeacons_* .
