.PHONY:

## default settings
PROJ_FUTURE ?= $(or ${IF_FUTURE},0)
# if 1: append last column of source data to projected data

# settings/data to be shown by showconf/showdata
SHOWCONF += PROJ_FUTURE
SHOWDATA +=

## default settings that must be changed before including this file

## variables

## rules

# common command to append follower column to projected data
define appendlastcol_command
  $(if $(shell [ ${PROJ_FUTURE} -eq 1 ] && echo yes),\
	  $(info # write result with follower column to $@)\
	  awk '!/^#/{print $$NF}' $* | paste -d\  $< - > $@,\
	  $(info # move result to $@)\
	  mv $< $@)
endef

## macros to be called later
#MACROS +=

## info
ifndef INFO
INFO =
define INFOADD
endef
else
INFOend +=
endif

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST +=
CLEAN_LIST +=
PURGE_LIST +=
