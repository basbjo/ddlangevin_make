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
INFO = cossin clean
INFO_clean  = delete cos-/sin-transformed data
define INFOADD
endef
else
INFOend +=
endif

## makefile includes (must remain after info)
include $(makedir)/cossin.mk

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST +=
CLEAN_LIST += $(COSSINDATA)
PURGE_LIST +=
