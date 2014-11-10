.PHONY: cossin
cossin: $$(COSSINDATA)

## default settings
CS_MIN_COL ?= $(MIN_COL)
CS_MAX_COL ?= $(MAX_COL)

# settings/data to be shown by showconf/showdata
SHOWCONF += CS_MIN_COL CS_MAX_COL
$(if $(filter cossin,${projtargets}),$(eval\
	SHOWDATA += COSSINDATA))

## default settings that must be changed before including this file

## variables
CSPREVSUFFIX := $(PROJSUFFIX)
COSSINDATA += $(addsuffix ${CSPREVSUFFIX}.cs,${DATA})
# suffix for data that is further analysed
PROJSUFFIX := $(CSPREVSUFFIX).cs
PROJDROPSUFFIX =# drop this suffix in subdirs
# minima and maxima as reference for ranges
MINMAXALL = $(COSSINDATA)

## rules
%.cs : %
	# cos-/sin-transform of inner columns in $<
	$(cs_command)

define cs_command
$(SCR)/cos_sin_tran.awk\
	-v min_col=$(strip ${CS_MIN_COL})\
	-v max_col=$(strip ${CS_MAX_COL}) $< > $@
endef

## macros to be called later
#MACROS +=

## info
ifndef INFO
INFO = cossin
define INFOADD
endef
else
INFOend += cossin
endif
INFO_cossin = cos-/sin-transform data (suffix .cs)

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST +=
CLEAN_LIST +=
PURGE_LIST += $(COSSINDATA)
