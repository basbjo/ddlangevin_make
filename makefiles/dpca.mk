.PHONY: dpca plot
dpca: $$(PCADATA)

plot: dpca $$(CVARPLOT)

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF +=
SHOWDATA += PCADATA

## default settings that must be changed before including this file

## variables
# projected data from principal component analysis
PCADATA += $(addsuffix .pca,${COSSINDATA})
# suffix for projected data that is further analysed
PROJSUFFIX = .cs.pca
PROJDROPSUFFIX = .cs.pca# drop this in subdirs
# plot of cumulative variances (eigenvalues)
CVARPLOT = $(addsuffix .eigval.png,${COSSINDATA})
# minima and maxima as reference for ranges
MINMAXALL = $(PCADATA)

%$(PROJSUFFIX).tmp : %.cs
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
INFO = cossin dpca plot clean
INFO_dpca   = dihedral principal component analysis
INFO_plot   = plot cumulative variances
INFO_clean  = delete cos-/sin-transformed data
define INFOADD
endef
else
INFOend +=
endif

## makefile includes (must remain after info)
include $(makedir)/cossin.mk

## keep intermediate files
PRECIOUS += $(COSSINDATA)

## clean
PLOTS_LIST += $(CVARPLOT)
CLEAN_LIST += $(COSSINDATA) $(addsuffix .tmp,${PCADATA})
PURGE_LIST += $(foreach suffix,pca cov eigvec eigval,\
	      $(addsuffix .${suffix},${COSSINDATA}))
