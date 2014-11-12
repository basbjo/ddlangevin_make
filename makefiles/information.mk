.PHONY: calc plot negentropy plot_all

calc: negentropy

plot: calc $$(NEGENT_PLOT)

negentropy: $$(NEGENTROPIES)

plot_all: plot

## default settings
NEGENT_NBINS ?= 500# number of bins
NEGENT_LAST_COL ?= 20# last column (optional)

# settings/data to be shown by showconf/showdata
SHOWCONF += NEGENT_NBINS NEGENT_LAST_COL
SHOWDATA +=

## default settings that must be changed before including this file

## variables
NEGENTROPIES = $(addsuffix .negentropy,${DATA})
NEGENT_PLOT = $(addsuffix .png,${NEGENTROPIES})

## rules
%.negentropy : %
	$(negentropy_command)

define negentropy_command
$(NEGENT) -m $(NCOLS_$<_NEGENT) $< -o $@
endef

%.negentropy.tex : %.negentropy $(SCR)/plot_negentropy.gp
	gnuplot -e "FILE='$<'" $(lastword $+)

## macros to be called later
#MACROS +=
FILEINFO_NAMES += NEGENT

## info
ifndef INFO
INFO = negentropy plot
INFO_negentropy = calculate column-wise negentropies
INFO_plot = plot negentropies
define INFOADD
endef
else
INFOend +=
endif

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST += $(NEGENT_PLOT)
CLEAN_LIST +=
PURGE_LIST += $(NEGENTROPIES)
