.PHONY: pca plot
pca: $$(PCADATA)

plot: $$(PROJ_PLOT_TARGETS)

## default settings
EIGVEC_PCA_LASTX ?=# last eigenvector in plot (optional)
EIGVEC_PCA_LASTY ?=# last eigenvector entry in plot (optional)
ANGLE_DPCA_LASTX ?= 20# number of angles per plot (dpca only)
DIH_ANGLE_OFFSET ?= $(shell echo $$((${MIN_COL} - ${FIRST_DIH_COL})))

# settings/data to be shown by showconf/showdata
SHOWCONF += EIGVEC_PCA_LASTX EIGVEC_PCA_LASTY ANGLE_DPCA_LASTX
$(if $(shell echo ${projtargets}|grep -q "cossin *pca"&&echo TRUE),$(eval\
	SHOWCONF += FIRST_DIH_COL))
SHOWDATA += PCADATA

## default settings that must be changed before including this file

## variables
PCAPREVSUFFIX := $(SUFFIX)
PCADATA += $(addsuffix ${PCAPREVSUFFIX}.pca,${DATA})
# suffix for data that is further analysed
SUFFIX := $(PCAPREVSUFFIX).pca
# plot of cumulative variances (eigenvalues) and eigenvector entries
PROJ_PLOT_TARGETS += pca $(CVARPLOT) $(EIGVPLOT)
$(if $(shell echo ${projtargets}|grep -q "cossin *pca"&&echo TRUE),$(eval\
	PROJ_PLOT_TARGETS += $${DPCAPLOT}))
CVARPLOT = $(addsuffix ${PCAPREVSUFFIX}.eigval.png,${DATA})
EIGVPLOT = $(addsuffix ${PCAPREVSUFFIX}.eigvec.png,${DATA})
DPCAPLOT = $(addsuffix ${PCAPREVSUFFIX}.angles.pdf,${DATA})
# minima and maxima as reference for ranges
MINMAXALL = $(PCADATA)

## rules
%$(SUFFIX).tmp %$(PCAPREVSUFFIX).eigvec : %$(PCAPREVSUFFIX)
	# perform principal component analysis on $<
	name=$<; $(FASTCA) -f $$name -p $@ -c $$name.cov -v $$name.eigvec -V $$name.eigval

%$(SUFFIX) : %$(SUFFIX).tmp
	$(appendlastcol_command)

%.cs.angles : %.cs.eigvec %.cs
	$(SCR)/calc_dpca_angle_contribs.awk $+ > $@

%.cs.angles.pdf : $(SCR)/plot_dpca_angle_contribs.gp %.cs.angles %.cs.eigvec
	$(dpca_angle_plot_command)

define dpca_angle_plot_command
gnuplot -e 'FILE="$(word 2,$+)"; EIGVEC="$(word 3,$+)"; OUTFILE="$@";\
	ANGLES_PER_PLOT=$(strip ${ANGLE_DPCA_LASTX});\
	DIH_ANGLE_OFFSET=$(strip ${DIH_ANGLE_OFFSET})' $<
endef

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
INFO_plot   = generate pca related plots

## makefile includes (must remain after info)
include $(makedir)/projfuture.mk

## keep intermediate files
PRECIOUS += $(addsuffix ${PCAPREVSUFFIX}.angles,${DATA})

## clean
PLOTS_LIST += $(CVARPLOT) $(EIGVPLOT) $(DPCAPLOT)
CLEAN_LIST += $(addsuffix .tmp,${PCADATA})
PURGE_LIST += $(foreach suffix,pca cov eigvec eigval angles,\
	      $(addsuffix ${PCAPREVSUFFIX}.${suffix},${DATA}))
