.PHONY: cossin dpca plot
dpca: $$(PCADATA)

cossin: $$(COSSINDATA)

plot: dpca $$(CVARPLOT)

## default settings
PCA_FUTURE ?= $(or ${IF_FUTURE},0)
# if 1: append last column of source data to dpca data

# settings/data to be shown by showconf/showdata
SHOWCONF += DIH_MIN_COL DIH_MAX_COL PCA_FUTURE
SHOWDATA +=

## default settings that must be changed before including this file

## variables
# cos-/sin-transformed dihedral angles
COSSINDATA += $(addsuffix .cossin,${DATA})
# projected data from principal component analysis
PCADATA += $(addsuffix .pca,${COSSINDATA})
# plot of cumulative variances (eigenvalues)
CVARPLOT = $(addsuffix .eigval.png,${COSSINDATA})
# minima and maxima as reference for ranges
MINMAXALL = $(PCADATA)

## rules
%.cossin : %
	# cos-/sin-transform of inner dihedrals in $<
	$(SCR)/cos_sin_tran.awk\
		-v dih_min_col=$(strip ${DIH_MIN_COL})\
		-v dih_max_col=$(strip ${DIH_MAX_COL}) $< > $@

%.cossin.pca.tmp : %.cossin
	# perform principal component analysis on $<
	name=$<; $(FASTCA) -f $$name -p $@ -c $$name.cov -v $$name.eigvec -V $$name.eigval

%.cossin.pca : %.cossin.pca.tmp
	$(appendlastcol_command)

define appendlastcol_command
  $(if $(shell [ ${PCA_FUTURE} -eq 1 ] && echo yes),\
	  $(info # write result with follower column to $@)\
	  awk '!/^#/{print $$NF}' $* | paste -d\  $< - > $@,\
	  $(info # move result to $@)\
	  mv $< $@)
endef

%.eigval.tex : %.pca $(SCR)/plot_cumulative.py
	$(SCR)/plot_cumulative.py $(basename $@)

## macros to be called later
#MACROS +=

## info
ifndef INFO
INFO = cossin dpca plot clean
INFO_cossin = create cos-/sin-transformed data
INFO_dpca   = dihedral principal component analysis
INFO_plot   = plot cumulative variances
INFO_clean  = delete cos-/sin-transformed data
define INFOADD
endef
else
INFOend +=
endif

## keep intermediate files
PRECIOUS += $(COSSINDATA)

## clean
PLOTS_LIST += $(CVARPLOT)
CLEAN_LIST += $(COSSINDATA) $(addsuffix .tmp,${PCADATA})
PURGE_LIST += $(foreach suffix,pca cov eigvec eigval,\
	      $(addsuffix .${suffix},${COSSINDATA}))
