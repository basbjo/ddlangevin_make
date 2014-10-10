.PHONY: showfields

## default settings
BIN1D_NBINS ?= 100# number of bins per dimension (1D binning)
BIN2D_NBINS ?= 80# number of bins per dimension (2D binning)

# settings/data to be shown by showconf/showdata
SHOWCONF +=
SHOWDATA +=

## default settings that must be changed before including this file

## variables

## rules
showfields:
	@echo; $(foreach file,${DATA},echo "${file}";\
		echo ${file} | sed 's/./=/g';\
		$(call showfields_macro,${file}); echo;)

define showfields_macro
head $(1) | grep '^#x1' | sed 's/ [01]$$//' \
	| tr ' ' '\n' | sed 's/^#//' \
	| nl -ba -s\  | sed 's/^  *//'
endef

getfieldno_macro = $(showfields_macro) | grep $(2) | cut -d\  -f1

define template_field
$(1).x% : $(1)
	$$(eval nums := $$(foreach label,$$(subst ., ,x$$*),\
		$$(shell $$(call getfieldno_macro,${1},$${label}))))
	$$(if $$(patsubst 2,,$$(words $${nums}))\
		,,${BINNING1D})$$(if $$(patsubst 3,,$$(words $${nums}))\
		,,${BINNING2D}) -c $$(shell echo $${nums}|tr ' ' ',') $$< -o $$@
endef

## macros to be called later
MACROS += rule_fields

define rule_fields
$(foreach file,${DATA},$(eval $(call template_field,${file})))
endef

## info
ifndef INFO
INFO = showfields
define INFOADD

To calculate field binnings of a »file« use the labels that are shown
by target »showfields«, e.g. »make file.x1.f1« or »make file.x1.x2.f2«.

endef
else
INFOend +=
endif
INFO_showfields = show column numbers with field labels

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST +=
CLEAN_LIST +=
PURGE_LIST +=
