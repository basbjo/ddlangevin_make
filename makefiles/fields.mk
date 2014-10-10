.PHONY: showfields

## default settings

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

## macros to be called later
#MACROS +=

## info
ifndef INFO
INFO = showfields
define INFOADD
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
