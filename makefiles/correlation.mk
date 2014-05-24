.PHONY:

## default settings
CORR_LAST_COL ?= 18# last column (optional)

# settings/data to be shown by showconf/showdata
SHOWCONF += CORR_LAST_COL
SHOWDATA +=

## default settings that must be changed before including this file

## variables

## rules

## macros to be called later
#MACROS +=

FILEINFO_NAMES = CORR

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
