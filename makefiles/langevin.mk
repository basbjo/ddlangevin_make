.PHONY: cat del_cat
cat: $$(CAT_DATA)

del_cat:
	$(if $(wildcard ${CAT_DATA}),$(RM) $(wildcard ${CAT_DATA}))

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF += IF_FUTURE
SHOWDATA += catdir CAT_DATA

## default settings that must be changed before including this file
catdir ?= catdata

## variables
CAT_DATA = $(sort $(notdir $(shell echo $(wildcard ${catdir}/*-[0-9][0-9]) \
		| tr ' ' '\n' | sed 's/-[0-9][0-9]$$//')))\
	   $(sort $(notdir $(shell echo $(wildcard ${catdir}/*-[0-9][0-9].field) \
		| tr ' ' '\n' | sed 's/-[0-9][0-9].field/.field/')))
DIR_LIST += $(catdir)

## rules
$(catdir):
	mkdir -p $@

# select columns from data files
define template_selectcolumns
$(1).%cols : $(1)
	$(SCR)/select_outer_columns.awk -vnfirst=$$* -vnlast=$$(IF_FUTURE) $$< > $$@
endef

# create testmodel trajectories
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

# concatenate data files
define template_cat_lang
$(1) : $$$$(wildcard $$$${catdir}/$(1)-[0-9]*[0-9])
	$$(cat_command)
endef

define template_cat_field
$(1) : $$$$(wildcard $$$${catdir}/$(patsubst %.field,%,${1})-[0-9]*[0-9].field)
	$$(cat_command)
endef

define cat_command
$(RM) $@
for file in $+; do sed '/^#/!s/ *$$/ 1/;$$s/ 1/ 0/' $${file} >> $@; done
endef

## macros to be called later
MACROS += rule_langevin

define rule_langevin
$(foreach file,${DATA},\
	$(eval $(call template_selectcolumns,${file}))\
	$(eval $(call template_testmodel,${file})))\
$(foreach file,$(filter-out %.field,${CAT_DATA}),\
	$(eval $(call template_cat_lang,${file})))\
$(foreach file,$(filter %.field,${CAT_DATA}),\
	$(eval $(call template_cat_field,${file})))
endef

## info
ifndef INFO
INFO = cat del_cat split
define INFOADD

To extract say 3 columns from a data file, call »make file.3cols«.
If IF_FUTURE is 1, also the last column of the file is appended.

Testmodel trajectories »file.dle<n>[.weights].m<m>.k<k>.ltm« can
be created where <n> is 1 for ol-first-tm and 2 for ol-second-tm.
The arguments to -m, -k and -F are generated automatically.  With
».weights«, ol-first-tm-weights or ol-second-tm-weights is used.
Testmodel trajectories can be splitted with the »split« target.

Save Langevin trajectories of a data file to »file.detail.lang«
manually.  The detail commonly reflects the options, for options
»-m5« and »-k50« the results may be saved to »file.m5.k50.lang«.
Edit »localconf.mk« to specify whether a follower column exists.
Singe trajectories »catdata/file.detail.lang-##« are concatenated
to »file.detail.lang« with follower column by the »cat« target.

endef
else
INFOend += cat del_cat
endif
INFO_cat = concatenate data (directory $(patsubst ./%,%,${catdir}))
INFO_del_cat = delete cat data

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST +=
CLEAN_LIST +=
PURGE_LIST +=
