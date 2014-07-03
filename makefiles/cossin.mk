.PHONY: cossin
cossin: $$(COSSINDATA)

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF += DIH_MIN_COL DIH_MAX_COL
SHOWDATA +=

## default settings that must be changed before including this file

## variables
# cos-/sin-transformed dihedral angles
COSSINDATA += $(addsuffix .cossin,${DATA})

## rules
%.cossin : %
	# cos-/sin-transform of inner dihedrals in $<
	$(SCR)/cos_sin_tran.awk\
		-v dih_min_col=$(strip ${DIH_MIN_COL})\
		-v dih_max_col=$(strip ${DIH_MAX_COL}) $< > $@

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
INFO_cossin = create cos-/sin-transformed data

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST +=
CLEAN_LIST +=
PURGE_LIST += $(COSSINDATA)
