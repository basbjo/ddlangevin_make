## programs
PDFLATEX ?= pdflatex
# Python Docutils
RST2HTML = rst2html -t
# Debian package poppler-utils
PDF2PNG ?= pdftoppm -png -l 1
PDF2EPS ?= pdftops -eps -l 1
# imagemagick utilities
EPS2PNG ?= convert -density 300 -background white -flatten
# TISEAN
CORR ?= corr -V0
XCOR ?= xcor -V0
RESCALE ?= rescale -V0 -u
# TISEAN (see ./patches)
HIST1D ?= histogram -V0 -b $(HIST1D_NBINS) -D
HIST2D ?= histo2d -V0 -b $(HIST2D_NBINS)
NEGENT ?= negentropy -V0 -b $(NEGENT_NBINS)
BINNING1D ?= binning -V0 -b $(BIN1D_NBINS)
BINNING2D ?= binning2d -V0 -b $(BIN2D_NBINS)
# Stock group
FASTCA ?= fastca
DELAYPCA ?= $(SCR)/delayPCA.py
# scripts
MINMAX ?= $(SCR)/minmax.sh -d" " -f "%9.6f"
NCOLS ?= $(SCR)/shape.sh -c
NROWS ?= $(SCR)/shape.sh -r
HEATMAP ?= $(SCR)/heatmap.py $(HEATMAP_FLAGS)

## default target
.SECONDEXPANSION:
all: $$(all)

## default variables
SCR ?= $(realpath ${makedir}/scripts)# scripts directory
datadirs ?= $(prefix)# remote data directories
DROPSUFFIX ?= # data filename suffix to be omitted in link names
IF_FUTURE ?= 0# 1 if last column for follower, 0 else
MINMAXFILE ?= minmax# minima and maxima as reference for ranges
MINMAXALL ?= $(DATA)# all files considered for minima and maxima

## common variables
SYMLINKS += $(DATALINKS)
CLEAN_LIST +=
PURGE_LIST += $(notdir ${MINMAXFILE} ${MINMAXFILE}.old) $(SPLIT_WILD)
# subdirectories in which make can be called by a double-colon rule
COMMON_SUBDIRS = clustering correlation drift fields histogram information

## macros to be called later
MACROS += rule_data_links rule_minmax

## macro to call several macros later
define call_macros
$(eval MACROS += rule_common_subdirs)\
$(foreach macro,${MACROS},$(call ${macro}))
endef

## source data files
DATA += $(sort $(wildcard ${DATA_HERE}) ${DATALINKS})#without repetitions
REMOTEDATA += $(foreach wildcard,${DATA_LINK},$(foreach dir,$(filter-out .,\
	      ${datadirs}),$(wildcard ${dir}/${wildcard})))
DATALINKS = $(notdir $(patsubst %$(strip ${DROPSUFFIX}),%,${REMOTEDATA}))
SHOWDATA += DATA datadirs DROPSUFFIX REMOTEDATA# to be shown by showdata

# symbolic links to source data files
define template_data_links
$(1): $(2)
	$$(if $$(wildcard $$@),,ln -s $$< $$@)
endef
define rule_data_links
$(foreach file,${REMOTEDATA},$(eval $(call template_data_links,\
	$(notdir $(patsubst %$(strip ${DROPSUFFIX}),%,${file})),${file})))
endef

# reread makefiles after creating links
-include .data
.data: $$(DATALINKS); @touch $@

## common phony targets
define INFO_start

Specific targets:
  all            $(all)
endef

define INFO_common
Common targets: info, show, showconf, showdata, showmacros,
  mksymlinks, rmsymlinks, clean, del_latex, del_plots, purge.
endef

info: ;@true
	$(info ${INFO_start})
	$(foreach target,$(shell ${SCR}/sorteduniq.py ${INFO} ${INFOend}),\
	  $(info $(shell printf "  %-12s\n" ${target} '${INFO_${target}}')))
	$(info )
	$(info ${INFO_common})
	$(info ${INFOADD})

show: showconf showdata showmacros

showconf: ;@true
	$(foreach var,$(shell ${SCR}/sorteduniq.py ${SHOWCONF}),\
		$(info ${var} = ${${var}}))
	$(info )

showdata: ;@true
	$(foreach var,$(shell ${SCR}/sorteduniq.py ${SHOWDATA}),\
		$(info ${var} = ${${var}}))
	$(info )

showmacros: ;@true
	$(info MACROS = $(MACROS))

mksymlinks: $$(SYMLINKS)

rmsymlinks:
	$(eval PURGE_LIST := ${PURGE_LIST})
	$(RM) $(foreach file,${SYMLINKS} ${SAMPDATA},$(if $(shell\
		[ -h ${file} ] && echo yes),${file}))
	@$(RM) .data

clean:
	$(if $(wildcard ${CLEAN_LIST}),$(RM) $(wildcard ${CLEAN_LIST}))

purge: rmsymlinks clean del_plots
	$(if $(wildcard ${PURGE_LIST}),$(RM) $(wildcard ${PURGE_LIST}))
	$(if $(wildcard $(filter-out .,${DIR_LIST})),\
		rmdir --ignore-fail-on-non-empty $(wildcard\
		$(filter-out .,${DIR_LIST})))
	$(if $(wildcard makefiles/example/make_example),\
		cd makefiles/example && $(MAKE) purge)
	@$(RM) .data

del_latex:
	$(RM) $(wildcard $(foreach suffix,tex aux log,\
		$(addsuffix .${suffix},$(basename ${PLOTS_LIST}))))

del_plots: del_latex
	$(RM) $(wildcard ${PLOTS_LIST} $(foreach suffix,pdf png,\
		$(addsuffix .${suffix},$(basename ${PLOTS_LIST}))))

del_split: .del_split .del_splitdir

.del_split:
	$(if $(wildcard ${SPLIT_WILD}),$(RM) $(wildcard ${SPLIT_WILD}))

.del_splitdir:
	$(if $(wildcard ${splitdir}),$(if $(shell\
		[ -d ${splitdir} ] && [ . != ${splitdir} ] && echo yes),\
		rmdir --ignore-fail-on-non-empty ${splitdir}))

.PHONY: all info show showconf showdata showmacros\
	mksymlinks rmsymlinks clean purge del_latex del_plots\
	del_split .del_split .del_splitdir

.PRECIOUS: $$(PRECIOUS)

## common double-colon rules to call make in subdirectories
define template_double_colon
$(1)::
	cd $$@ && $$(MAKE)
endef

define rule_common_subdirs
$(foreach name,$(patsubst %/Makefile,%,$(wildcard\
	$(addsuffix /Makefile,${COMMON_SUBDIRS}))),\
	$(eval $(call template_double_colon,${name}))\
	$(eval INFOend += ${name})\
	$(eval INFO_${name} = call make in subdirectory ${name}))
endef

## common rules
%.html : %.rst $(makedir)/readme.css $(makedir)/readme.sed
	$(RST2HTML) --stylesheet=$(word 2,$+) $< | sed -f $(word 3,$+) > $@

%.eps : %.pdf ; $(PDF2EPS) $<

%.png : %.pdf ; $(PDF2PNG) $< > $@

%.png : %.eps ; $(EPS2PNG) $< $@

%.pdf : %.tex ; $(PDFLATEX) -halt-on-error $* >/dev/null && $(RM) $*.aux $*.log

# by default keep intermediate pdf files
keeppdf ?= true
ifeq (${keeppdf},true)
	PRECIOUS += $(patsubst %.png,%.pdf,${PLOTS_LIST})
endif

# minima and maxima as reference for ranges
%.minmax : %
	$(MINMAX) $< > $@
define template_minmax
$(1): $$(MINMAXALL)
	$$(if $$(and $$?,$$(wildcard $$@)),\
		cp -p $$@ $$@.old; $$(MINMAX) $$@.old $$? > $$@,\
		$$(if $$?, $$(MINMAX) $$? > $$@))
endef
# apply this rule only in current directory
# MINMAXALL in showdata only if MINMAXFILE in current directory
# MINMAXFILE in info only if also MINMAXALL is non empty, however
#  »INFO += minmax« is sufficient to always show the description
define rule_minmax
$(if ${MINMAXALL},$(eval $(call template_minmax,$(notdir ${MINMAXFILE}))))\
$(if $(patsubst ./,,$(dir ${MINMAXFILE})),$(eval SHOWDATA += MINMAXFILE)\
,$(if ${MINMAXFILE},$(eval SHOWDATA += MINMAXFILE MINMAXALL)\
  $(if ${MINMAXALL},$(eval INFOend += $(patsubst ./%,%,${MINMAXFILE})))\
  $(if ${INFO_$(patsubst ./%,%,${MINMAXFILE})},,$(eval\
INFO_$(patsubst ./%,%,${MINMAXFILE}) = minima/maxima as reference for ranges))))
endef

## common macros
# numeric minimum or maximum of a list of words
getmin = $(shell echo ${1}|tr ' ' '\n'|sort -n |head -1)
getmax = $(shell echo ${1}|tr ' ' '\n'|sort -nr|head -1)
# ceiling($1/$2) to find minimum integer x such that x*$2 >= $1
divide_ceil = $(shell echo $$(((${1}-1+${2})/${2})))
# columns in file $(1) minus $(IF_FUTURE)
fcols = $(shell echo $$(($$(${NCOLS} "${1}") - ${IF_FUTURE})))
# range from 1 to $(1) (unformated)
urange = $(shell i=1; while [ "$(1)" != "" ] && [ $$i -le $(1) ]; do \
	 echo $$i; i=`expr $$i + 1`; done)
# range from 1 to $(1) in format "%02d"
range = $(shell i=1; while [ "$(1)" != "" ] && [ $$i -le $(1) ]; do \
	printf -- "%02d\n" $$i; i=`expr $$i + 1`; done)
# range from 1 to ($1)-1 in format "%02d"
rangeto = $(shell i=1; while [ "$(1)" != "" ] && [ $$i -lt $(1) ]; do \
	  printf -- "%02d\n" $$i; i=`expr $$i + 1`; done)
# columns for $(2)'th plot with $(1) columns and last column $(3)
plotcols = $(shell i=`python -c 'print ((int("${2}")-1)*int("${1}")+1)'`;\
	   end=`python -c 'print min(int("${2}")*int("${1}"),int("${3}"))'`;\
	   while [ $$i -le $$end ]; do \
	   printf -- "%02d\n" $$i; i=`expr $$i + 1`; done)
# list of numbers to denote splitted trajectories
splitnums = $(patsubst $(notdir ${1})-%,%,$(notdir $(shell find -L\
	    $(dir ${1}) -regex "[./]*${1}-[0-9]+"|sort -r)))
