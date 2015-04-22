.PHONY: cat del_cat .del_cat cat_links
cat: $$(CAT_DATA)

del_cat: .del_cat .del_splitdir

.del_cat:
	$(if $(wildcard ${CAT_DATA}),$(RM) $(wildcard ${CAT_DATA}))
	$(if $(wildcard ${splitdir}),$(foreach file,${CAT_DATA},\
		find -L '${splitdir}' -type f -or -type l \
		-regex '${splitdir}/${file}-[0-9][0-9]+' -delete;))

cat_links: | $(splitdir)
	$(foreach filename,$(filter-out %.field,${CAT_DATA}),\
		find -L '${splitdir}' -type f -or -type l \
		-regex '${splitdir}/${filename}-[0-9][0-9]+' -delete;\
		for name in "${catdir}/${filename}"-[0-9]*[0-9]; \
			do ln -s ../${catdir}/$${name##*/} $(splitdir)/$${name##*/}; done;)

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF +=
SHOWDATA += catdir CAT_DATA

## default settings that must be changed before including this file
catdir ?= catdata

## variables
CAT_DATA = $(sort $(notdir $(shell echo $(shell find -L '${catdir}' \
		-regex '${catdir}/.*-[0-9][0-9]+' | sort -g) \
		| tr ' ' '\n' | sed -r 's/-[0-9][0-9]+$$//')))\
	 $(sort $(notdir $(shell echo $(shell find -L '${catdir}' \
		-regex '${catdir}/.*-[0-9][0-9]+.field' | sort -g) \
		| tr ' ' '\n' | sed -r 's/-[0-9][0-9]+.field/.field/')))
DIR_LIST += $(catdir)

## rules
$(catdir):
	mkdir -p $@

# rule for concatenation of filename-## to filename
define template_cat
$(1) : $$$$(shell find -L '$$$${catdir}' \
		-regex '$$$${catdir}/$(1)-[0-9][0-9]+' | sort -g)
	$$(cat_command)
	touch -cmr $$(shell ls -t $$+ | head -n1) $$@
	$$(if $$(wildcard $${splitdir}),$${link_to_split_command})
endef

# command for concatenation
define cat_command
$(RM) $@
for file in $+; do sed '/^#/!s/ *$$/ 1/;$$s/ 1$$/ 0/' $${file} >> $@; done
endef

# if splitdir exists, create symlinks from splitdir to catdir
define link_to_split_command
find -L '$(splitdir)' -type f -or -type l \
	-regex '$(splitdir)/$(notdir $@)-[0-9][0-9]+' -delete
for name in $(notdir $+); do ln -s ../$(catdir)/$${name} $(splitdir)/$${name}; done
endef

# rule for concatenation of filename-##.field to filename.field
define template_cat_field
$(1) : $$$$(shell find -L '$$$${catdir}' \
	-regex '$$$${catdir}/$(patsubst %.field,%,${1})-[0-9][0-9]+.field')
	$$(cat_command)
	touch -cmr $$(shell ls -t $$+ | head -n1) $$@
endef

## macros to be called later
MACROS += rule_cat

define rule_cat
$(foreach file,$(filter-out %.field,${CAT_DATA}),\
	$(eval $(call template_cat,${file})))\
$(foreach file,$(filter %.field,${CAT_DATA}),\
	$(eval $(call template_cat_field,${file})))
endef

## info
ifndef INFO
INFO = cat $(if ${splitdir},cat_links)
define INFOADD

Single trajectories »$(catdir)/filename-##« are concatenated
to »filename« including a follower column by the »cat« target.
Files with suffix ».field« are treated exceptionally: files
»$(catdir)/name-##.field« are concatenated to »name.field«.

endef
else
INFOend += cat $(if ${splitdir},cat_links) del_cat
endif
INFO_cat = concatenate data (directory $(patsubst ./%,%,${catdir}))
INFO_cat_links = create links from $(patsubst ./%,%,${splitdir}) to $(patsubst ./%,%,${catdir})
INFO_del_cat = delete concatenated data

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST +=
CLEAN_LIST +=
PURGE_LIST += $(CAT_DATA)
