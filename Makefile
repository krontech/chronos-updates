## Makefile rules just cleans up the syntax a bit.
DIRNAME=$(dir $(lastword $(MAKEFILE_LIST)))
DISTFILES  = camApp
DISTFILES += camAppRevision
DISTFILES += FPGA.bit
DISTFILES += update.sh
DISTFILES := $(addprefix $(DIRNAME)/,$(DISTFILES))

DOCFILES  = changelog.txt README.txt
DOCFILES := $(addprefix $(DIRNAME)/,$(DOCFILES))

## Get the git revision
VERSION := $(shell cd $(DIRNAME) && git describe --tags --always --dirty)
ZIPFILE = camUpdate-$(VERSION).zip
.DEFAULT_GOAL = $(ZIPFILE)

.PHONY: help clean camUpdate $(MAKECMDGOALS)

clean:
	rm -rf $(ZIPFILE)
	rm -rf camUpdate

camUpdate: $(DISTFILES)
	rm -rf camUpdate
	mkdir -p camUpdate
	cp $(DISTFILES) camUpdate

## Generate the update package given by the make goal.
$(ZIPFILE) $(filter %.zip,$(MAKECMDGOALS)): camUpdate $(DOCFILES)
	zip -r $@ camUpdate
	zip $@ -j $(DOCFILES)

