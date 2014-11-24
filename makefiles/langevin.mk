.PHONY:

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF += IF_FUTURE
SHOWDATA +=

## default settings that must be changed before including this file

## variables

## rules
define template_selectcolumns
$(1).%cols : $(1)
	$(SCR)/select_outer_columns.awk -vnfirst=$$* -vnlast=$$(IF_FUTURE) $$< > $$@
endef

define template_testmodel
$(1).dle1.%.ltm: $(1)
	ol-first$$(testmodel_command)
$(1).dle2.%.ltm: $(1)
	ol-second$$(testmodel_command)
endef

extract_argument = $(shell echo $@|egrep -o '\.$(1)[0-9]+\.'|grep -o '[0-9]*')

define testmodel_command
-tm$(if $(filter weights%,$*),-weights)\
 -m$(call extract_argument,m) \
 -k$(call extract_argument,k)$(if\
$(shell [ ${IF_FUTURE} -eq 1 ] && echo yes),\
 -F$(shell echo `expr $(call fcols,$<) + 1`))\
 $< -o $@
endef

## macros to be called later
MACROS += rule_langevin

define rule_langevin
$(foreach file,${DATA},\
	$(eval $(call template_selectcolumns,${file}))\
	$(eval $(call template_testmodel,${file})))
endef

## info
ifndef INFO
INFO = split
define INFOADD

To extract say 3 columns from a data file, call »make file.3cols«.
If IF_FUTURE is 1, also the last column of the file is appended.

Testmodel trajectories »file.dle<n>[.weights].m<m>.k<k>.ltm« can
be created where <n> is 1 for ol-first-tm and 2 for ol-second-tm.
The arguments to -m, -k and -F are generated automatically.  With
».weights«, ol-first-tm-weights or ol-second-tm-weights is used.

Save Langevin trajectories of a data file to »file.detail.lang«
manually.  The detail commonly reflects the options, for options
»-m5« and »-k50« the results may be saved to »file.m5.k50.lang«.
Edit »localconf.mk« to specify whether a follower column exists.

endef
else
INFOend +=
endif

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST +=
CLEAN_LIST +=
PURGE_LIST +=
