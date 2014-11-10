.PHONY: colselect
colselect: $$(COLSELECTDATA)

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF += DIH_MIN_COL DIH_MAX_COL
$(if $(filter colselect,${projtarget}),$(eval\
	SHOWDATA += COLSELECTDATA))

## default settings that must be changed before including this file

## variables
PREVSUFFIX := $(PROJSUFFIX)
COLSELECTDATA += $(addsuffix .ic,$(addsuffix ${PREVSUFFIX},${DATA}))
# suffix for data that is further analysed
PROJSUFFIX += .ic
PROJDROPSUFFIX =# drop this suffix in subdirs
# minima and maxima as reference for ranges
MINMAXALL = $(COLSELECTDATA)

## rules
%.ic : %
	# selection of inner columns in $<
	$(SCR)/select_inner_columns.awk\
		-v dih_min_col=$(strip ${DIH_MIN_COL})\
		-v dih_max_col=$(strip ${DIH_MAX_COL}) $< > $@

## macros to be called later
#MACROS +=

## info
ifndef INFO
INFO = colselect
define INFOADD
endef
else
INFOend += colselect
endif
INFO_colselect = select inner columns (suffix .ic)

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST +=
CLEAN_LIST +=
PURGE_LIST += $(COLSELECTDATA)
