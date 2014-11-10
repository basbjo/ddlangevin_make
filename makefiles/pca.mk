.PHONY: select pca plot
select: $$(INNERCOLSDATA)

pca: $$(PCADATA)

plot: pca $$(CVARPLOT)

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF +=
SHOWDATA += PCADATA

## default settings that must be changed before including this file

## variables
# selected inner columns
INNERCOLSDATA += $(addsuffix .ic,${DATA})
# projected data from principal component analysis
PCADATA += $(addsuffix .pca,${INNERCOLSDATA})
# suffix for projected data that is further analysed
PROJSUFFIX = .ic.pca
PROJDROPSUFFIX =# drop this suffix in subdirs
# plot of cumulative variances (eigenvalues)
CVARPLOT = $(addsuffix .eigval.png,${INNERCOLSDATA})
# minima and maxima as reference for ranges
MINMAXALL = $(PCADATA)

## rules
%.ic : %
	# selection of inner columns in $<
	$(SCR)/select_inner_columns.awk\
		-v min_col=$(strip ${MIN_COL})\
		-v max_col=$(strip ${MAX_COL}) $< > $@

%$(PROJSUFFIX).tmp : %.ic
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
INFO = select pca plot clean
INFO_select = select inner columns
INFO_pca   = dihedral principal component analysis
INFO_plot   = plot cumulative variances
INFO_clean  = delete cos-/sin-transformed data
define INFOADD
endef
else
INFOend +=
endif

## makefile includes (must remain after info)
include $(makedir)/projfuture.mk

## keep intermediate files
PRECIOUS += $(INNERCOLSDATA)

## clean
PLOTS_LIST += $(CVARPLOT)
CLEAN_LIST += $(INNERCOLSDATA) $(addsuffix .tmp,${PCADATA})
PURGE_LIST += $(foreach suffix,pca cov eigvec eigval,\
	      $(addsuffix .${suffix},${INNERCOLSDATA}))
