## programs
PDFLATEX ?= pdflatex
# Python Docutils
RST2HTML = rst2html -t
# Debian package poppler-utils
PDF2PNG ?= pdftoppm -png -l 1
PDF2EPS ?= pdftops -eps -l 1
# scripts

## default target
.SECONDEXPANSION:
all: $$(all)

## default variables
SCR ?= $(makedir)/scripts# scripts directory
datadirs ?= $(prefix)# remote data directories
DROPSUFFIX ?= # data filename suffix to be omitted in link names

## common variables
SYMLINKS += $(DATALINKS)
CLEAN_LIST +=
PURGE_LIST +=

## macros to be called later
MACROS += rule_data_links

## macro to call several macros later
define call_macros
$(foreach macro,${MACROS},$(call ${macro}))
endef

## source data files
DATA += $(sort $(wildcard ${DATA_HERE}) ${DATALINKS})#without repetitions
REMOTEDATA += $(foreach wildcard,${DATA_LINK},$(foreach dir,${datadirs},\
	      $(wildcard ${dir}/${wildcard})))
DATALINKS = $(notdir $(patsubst %${DROPSUFFIX},%,${REMOTEDATA}))
SHOWDATA += DATA datadirs DROPSUFFIX REMOTEDATA# to be shown by showdata

# symbolic links to source data files
define template_data_links
$(1): $(2)
	$$(if $$(wildcard $$@),,ln -s $$< $$@)
endef
define rule_data_links
$(foreach file,${REMOTEDATA},$(eval $(call template_data_links,\
	$(notdir $(patsubst %${DROPSUFFIX},%,${file})),${file})))
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
	$(foreach target,${INFO},$(info $(shell\
		printf "  %-12s\n" ${target} '${INFO_${target}}')))
	$(foreach target,${INFOend},$(if $(filter\
		${target},${INFO}),,$(info $(shell\
		printf "  %-12s\n" ${target} '${INFO_${target}}'))))
	$(info )
	$(info ${INFO_common})
	$(info ${INFOADD})

show: showconf showdata showmacros

showconf: ;@true
	$(foreach var,${SHOWCONF},$(info ${var} = ${${var}}))
	$(info )

showdata: ;@true
	$(foreach var,${SHOWDATA},$(info ${var} = ${${var}}))
	$(info )

showmacros: ;@true
	$(info MACROS = $(MACROS))

mksymlinks: $$(SYMLINKS)

rmsymlinks:
	$(RM) $(foreach file,${SYMLINKS},$(if $(shell\
		[ -h ${file} ] && echo yes),${file}))
	@$(RM) .data

clean:
	$(if $(wildcard ${CLEAN_LIST}),$(RM) $(wildcard ${CLEAN_LIST}))

purge: rmsymlinks clean del_plots
	$(if $(wildcard ${PURGE_LIST}),$(RM) $(wildcard ${PURGE_LIST}))
	@$(RM) .data

del_latex:
	$(RM) $(wildcard $(foreach suffix,tex aux log,\
		$(addsuffix .${suffix},$(basename ${PLOTS_LIST}))))

del_plots: del_latex
	$(RM) $(wildcard ${PLOTS_LIST} $(foreach suffix,pdf png,\
		$(addsuffix .${suffix},$(basename ${PLOTS_LIST}))))

.PHONY: all info show showconf showdata showmacros\
	mksymlinks rmsymlinks clean purge del_latex del_plots

.PRECIOUS: $$(PRECIOUS)

## common rules
%.html : %.rst ; $(RST2HTML) $< $@

%.eps : %.pdf ; $(PDF2EPS) $<

%.png : %.pdf ; $(PDF2PNG) $< > $@

%.pdf : %.tex ; $(PDFLATEX) -halt-on-error $* >/dev/null && $(RM) $*.aux $*.log

# by default keep intermediate pdf files
keeppdf ?= true
ifeq (${keeppdf},true)
	PRECIOUS += $(patsubst %.png,%.pdf,${PLOTS_LIST})
endif

## common macros
