.PHONY: pca plot
pca: $$(PCADATA)

plot: pca $$(CVARPLOT)

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF +=
SHOWDATA += PCADATA

## default settings that must be changed before including this file

## variables
PCAPREVSUFFIX := $(PROJSUFFIX)
PCADATA += $(addsuffix ${PCAPREVSUFFIX}.pca,${DATA})
# suffix for data that is further analysed
PROJSUFFIX := $(PCAPREVSUFFIX).pca
PROJDROPSUFFIX =# drop this suffix in subdirs
# plot of cumulative variances (eigenvalues)
CVARPLOT = $(addsuffix ${PCAPREVSUFFIX}.eigval.png,${DATA})
# minima and maxima as reference for ranges
MINMAXALL = $(PCADATA)

## rules
%$(PROJSUFFIX).tmp : %$(PCAPREVSUFFIX)
	# perform principal component analysis on $<
	name=$<; $(FASTCA) -f $$name -p $@ -c $$name.cov -v $$name.eigvec -V $$name.eigval

%$(PROJSUFFIX) : %$(PROJSUFFIX).tmp
	$(appendlastcol_command)

%.eigval.tex : %.pca $(SCR)/plot_cumulative.py
	$(SCR)/plot_cumulative.py $(basename $@)

## macros to be called later
#MACROS +=

## info
ifndef INFO
INFO = pca plot
define INFOADD
endef
else
INFOend += pca
endif
INFO_pca    = principal component analysis (suffix .pca)
INFO_plot   = plot cumulative variances

## makefile includes (must remain after info)
include $(makedir)/projfuture.mk

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST += $(CVARPLOT)
CLEAN_LIST += $(addsuffix .tmp,${PCADATA})
PURGE_LIST += $(foreach suffix,pca cov eigvec eigval,\
	      $(addsuffix ${PCAPREVSUFFIX}.${suffix},${DATA}))
