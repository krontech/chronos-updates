## Makefile rules just cleans up the syntax a bit.
DIRNAME=$(dir $(lastword $(MAKEFILE_LIST)))
DISTFILES  = busy.raw
DISTFILES += update.sh
DISTFILES += update_real.sh
DISTFILES := $(addprefix $(DIRNAME)/,$(DISTFILES))

DOCFILES  = changelog.txt README.txt
DOCFILES := $(addprefix $(DIRNAME)/,$(DOCFILES))

## Get the git revision
VERSION := $(shell cd $(DIRNAME) && git describe --tags --always --dirty)
ZIPFILE = camUpdate-$(VERSION).zip
TARFLAGS = --numeric-owner --owner=0 --group=0
.DEFAULT_GOAL = $(ZIPFILE)

.PHONY: help clean camUpdate camUpdate/update.tgz $(MAKECMDGOALS)

clean:
	rm -rf $(ZIPFILE)
	rm -rf camUpdate

camUpdate/update.tgz:
	mkdir -p camUpdate
	[ -L $(DIRNAME)/rootfs/lib/udev/rules.d ] || ln -s /etc/udev/rules.d $(DIRNAME)/rootfs/lib/udev/
	tar $(TARFLAGS) -czf camUpdate/update.tgz -C $(DIRNAME)/rootfs $(shell ls $(DIRNAME)/rootfs)

camUpdate: $(DISTFILES)
	mkdir -p camUpdate
	cp $(DISTFILES) camUpdate

## Generate the update package given by the make goal.
$(ZIPFILE) $(filter %.zip,$(MAKECMDGOALS)): camUpdate camUpdate/update.tgz $(DOCFILES)
	rm -f $@
	zip -r $@ camUpdate
	zip $@ -j $(DOCFILES)

