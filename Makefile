## Makefile rules just cleans up the syntax a bit.
DIRNAME=$(dir $(lastword $(MAKEFILE_LIST)))
DISTFILES  = camApp
DISTFILES += camAppRevision
DISTFILES += FPGA.bit
DISTFILES += update.sh
DISTFILES := $(addprefix $(DIRNAME)/,$(DISTFILES))

.DEFAULT_GOAL = camUpdate.zip

.PHONY: help clean camUpdate $(MAKECMDGOALS)

clean:
	rm -rf camUpdate

camUpdate: $(DISTFILES)
	rm -rf camUpdate
	mkdir -p camUpdate
	cp $(DISTFILES) camUpdate

## Generate the update package given by the make goal.
camUpdate.zip $(filter %.zip,$(MAKECMDGOALS)): camUpdate
	zip -r $@ camUpdate

