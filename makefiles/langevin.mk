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
	$(SCR)/select_columns.awk -vnfirst=$$* -vnlast=$$(IF_FUTURE) $$< > $$@
endef

define rule_langevin
$(foreach file,${DATA},$(eval $(call template_selectcolumns,${file})))
endef

## macros to be called later
MACROS += rule_langevin

## info
ifndef INFO
INFO = split
define INFOADD

To extract say 3 columns from a data file, call »make file.3cols«.
If IF_FUTURE is 1, also the last column of the file is appended.

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
