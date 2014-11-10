.PHONY: cossin
cossin: $$(COSSINDATA)

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF += MIN_COL MAX_COL
$(if $(filter cossin,${projtarget}),$(eval\
	SHOWDATA += COSSINDATA))

## default settings that must be changed before including this file

## variables
PREVSUFFIX := $(PROJSUFFIX)
COSSINDATA += $(addsuffix .cs,$(addsuffix ${PREVSUFFIX},${DATA}))
# suffix for data that is further analysed
PROJSUFFIX += .cs
PROJDROPSUFFIX =# drop this suffix in subdirs
# minima and maxima as reference for ranges
MINMAXALL = $(COSSINDATA)

## rules
%.cs : %
	# cos-/sin-transform of inner dihedrals in $<
	$(SCR)/cos_sin_tran.awk\
		-v min_col=$(strip ${MIN_COL})\
		-v max_col=$(strip ${MAX_COL}) $< > $@

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
