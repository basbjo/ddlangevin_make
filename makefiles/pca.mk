.PHONY: pca plot
pca: $$(PCADATA)

plot: $$(PROJ_PLOT_TARGETS)

## default settings
EIGVEC_PCA_LASTX ?=
EIGVEC_PCA_LASTY ?=

# settings/data to be shown by showconf/showdata
SHOWCONF +=
SHOWDATA += PCADATA

## default settings that must be changed before including this file

## variables
PCAPREVSUFFIX := $(SUFFIX)
PCADATA += $(addsuffix ${PCAPREVSUFFIX}.pca,${DATA})
# suffix for data that is further analysed
SUFFIX := $(PCAPREVSUFFIX).pca
# plot of cumulative variances (eigenvalues) and eigenvector entries
PROJ_PLOT_TARGETS += pca $(CVARPLOT) $(EIGVPLOT)
CVARPLOT = $(addsuffix ${PCAPREVSUFFIX}.eigval.png,${DATA})
EIGVPLOT = $(addsuffix ${PCAPREVSUFFIX}.eigvec.png,${DATA})
# minima and maxima as reference for ranges
MINMAXALL = $(PCADATA)

## rules
%$(SUFFIX).tmp : %$(PCAPREVSUFFIX)
	# perform principal component analysis on $<
	name=$<; $(FASTCA) -f $$name -p $@ -c $$name.cov -v $$name.eigvec -V $$name.eigval

%$(SUFFIX) : %$(SUFFIX).tmp
	$(appendlastcol_command)

%.eigval.tex : $(SCR)/plot_cumulative.py %.pca
	$< $(basename $@)

%.eigvec.tex : $(SCR)/plot_eigenvectors.gp %.pca
	$(eigvec_plot_command)

define eigvec_plot_command
gnuplot -e 'FILE="$(basename $@)"$(if\
	$(strip ${EIGVEC_PCA_LASTX}),; xmax=$(strip ${EIGVEC_PCA_LASTX}))$(if\
	$(strip ${EIGVEC_PCA_LASTY}),; ymax=$(strip ${EIGVEC_PCA_LASTY}))' $<
endef

## macros to be called later
#MACROS +=

## info
ifndef INFO
INFO = pca plot
define INFOADD
endef
else
INFOend += pca plot
endif
INFO_pca    = principal component analysis (suffix .pca)
INFO_plot   = plot cumulative variances (pca) and eigenvectors

## makefile includes (must remain after info)
include $(makedir)/projfuture.mk

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST += $(CVARPLOT) $(EIGVPLOT)
CLEAN_LIST += $(addsuffix .tmp,${PCADATA})
PURGE_LIST += $(foreach suffix,pca cov eigvec eigval,\
	      $(addsuffix ${PCAPREVSUFFIX}.${suffix},${DATA}))
