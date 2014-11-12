.PHONY: colselect
colselect: $$(COLSELECTDATA)

## default settings
IC_MIN_COL ?= $(MIN_COL)
IC_MAX_COL ?= $(MAX_COL)

# settings/data to be shown by showconf/showdata
SHOWCONF += IC_MIN_COL IC_MAX_COL
$(if $(filter colselect,${projtargets}),$(eval\
	SHOWDATA += COLSELECTDATA))

## default settings that must be changed before including this file

## variables
ICPREVSUFFIX := $(SUFFIX)
COLSELECTDATA += $(addsuffix ${ICPREVSUFFIX}.ic,${DATA})
# suffix for data that is further analysed
SUFFIX := $(ICPREVSUFFIX).ic
# minima and maxima as reference for ranges
MINMAXALL = $(COLSELECTDATA)

## rules
%.ic : %
	# selection of inner columns in $<
	$(ic_command)

define ic_command
$(SCR)/select_inner_columns.awk\
	-v min_col=$(strip ${IC_MIN_COL})\
	-v max_col=$(strip ${IC_MAX_COL}) $< > $@
endef

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
