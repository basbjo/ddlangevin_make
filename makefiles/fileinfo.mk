.PHONY: showncols

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF += IF_FUTURE
SHOWDATA +=

## default settings that must be changed before including this file

## variables
# maximum number of columns per file
lastcol = $(call getmax,$(foreach file,${DATA},${NCOLS_${file}}))

## rules
showncols: ;@true
	$(info # Number of columns in file minus IF_FUTURE (${IF_FUTURE}))
	$(foreach file,${DATA},$(info ${file}: ${NCOLS_${file}}))

## macros
# columns in file $(1) minus $(IF_FUTURE)
define NCOLS_template
  NCOLS_$(1) = $(call fcols,${1})
endef

## macros to be called later
MACROS += fileinfo

define fileinfo
  $(foreach file,${DATA},$(eval $(call NCOLS_template,${file})))
endef
