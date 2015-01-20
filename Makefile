debian/wmbeacons.1: README.md
	grep -v '^\[!' $< | pandoc -s -t man -M title="WMBEACONS(1) Manual" -o $@

# create single entry from last tag
changelog:
	@VERSION=`git describe --tags` ;\
		echo "wmbeacons ($$VERSION) unstable; urgency=low" > debian/changelog ;\
		echo >> debian/changelog ;\
		AUTHOR=`git show -s --format="%an <%ae>" $$VERSION` ; \
		DATE=`git show -s --format="%ad" $$VERSION | awk '{ print $$1",",$$3,$$2,$$5,$$4,$$6 }'` ; \
		echo " -- $$AUTHOR  $$DATE" >> debian/changelog ;\
	perl -pi -e "s/VERSION='[^']+'/VERSION='$$VERSION'/" bin/app.psgi ;\
	echo $$VERSION

debian-clean:
	fakeroot debian/rules clean

debian-package:
	dpkg-buildpackage -b -us -uc -rfakeroot
	mv ../wmbeacons_* .
