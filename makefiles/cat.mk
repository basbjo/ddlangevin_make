.PHONY: cat del_cat
cat: $$(CAT_DATA)

del_cat:
	$(if $(wildcard ${CAT_DATA}),$(RM) $(wildcard ${CAT_DATA}))

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF +=
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

define template_cat
$(1) : $$$$(wildcard $$$${catdir}/$(1)-[0-9]*[0-9])
	$$(cat_command)
endef

define cat_command
$(RM) $@
for file in $+; do sed '/^#/!s/ *$$/ 1/;$$s/ 1/ 0/' $${file} >> $@; done
endef

define template_cat_field
$(1) : $$$$(wildcard $$$${catdir}/$(patsubst %.field,%,${1})-[0-9]*[0-9].field)
	$$(cat_command)
endef

## macros to be called later
MACROS += rule_cat

define rule_cat
$(foreach file,${DATA},\
	$(eval $(call template_selectcolumns,${file}))\
	$(eval $(call template_testmodel,${file})))\
$(foreach file,$(filter-out %.field,${CAT_DATA}),\
	$(eval $(call template_cat,${file})))\
$(foreach file,$(filter %.field,${CAT_DATA}),\
	$(eval $(call template_cat_field,${file})))
endef

## info
ifndef INFO
INFO = cat
define INFOADD

Single trajectories »$(catdir)/filename-##« are concatenated
to »filename« including a follower column by the »cat« target.
Files with suffix ».field« are treated exceptionally: files
»$(catdir)/name-##.field« are concatenated to »name.field«.

endef
else
INFOend += cat del_cat
endif
INFO_cat = concatenate data (directory $(patsubst ./%,%,${catdir}))
INFO_del_cat = delete concatenated data

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST +=
CLEAN_LIST +=
PURGE_LIST += $(CAT_DATA)
