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
	# cos-/sin-transform of inner dihedrals
	$(SCR)/cos_sin_tran.awk\
		-v dih_min_col=$(strip ${DIH_MIN_COL})\
		-v dih_max_col=$(strip ${DIH_MAX_COL}) $< > $@

## macros to be called later
MACROS +=

## info
ifndef INFO
INFO = cossin clean
INFO_cossin = create cos-/sin-transformed data
INFO_clean  = delete cos-/sin-transformed data
define INFOADD
endef
else
INFOend +=
endif

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST +=
CLEAN_LIST += $(COSSINDATA)
PURGE_LIST +=
