.PHONY:

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF +=
SHOWDATA +=

## default settings that must be changed before including this file

## variables

## rules

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
