.PHONY: negentropy

negentropy: $$(NEGENTROPIES)

## default settings
NEGENT_NBINS ?= 500# number of bins (optional)
NEGENT_LAST_COL ?= 20# last column (optional)

# settings/data to be shown by showconf/showdata
SHOWCONF += NEGENT_NBINS NEGENT_LAST_COL
SHOWDATA +=

## default settings that must be changed before including this file

## variables
NEGENTROPIES = $(addsuffix .negentropy,${DATA})

## rules
%.negentropy : %
	$(negentropy_command)

define negentropy_command
$(SCR)/calc_negentropy.py $(if ${NEGENT_NBINS},-b ${NEGENT_NBINS})\
	-m $(NCOLS_${<}_NEGENT) $< -o $@
endef

## macros to be called later
#MACROS +=
FILEINFO_NAMES += NEGENT

## info
ifndef INFO
INFO = negentropy
INFO_negentropy = calculate column-wise negentropies
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
PURGE_LIST += $(NEGENTROPIES)
