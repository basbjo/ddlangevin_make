.PHONY: clustering
clustering: $$(CLUSTER_TRAJ)

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF += CLUSTER_SCRIPT
SHOWDATA += CLUSTER_TRAJ

## default settings that must be changed before including this file

## variables
CLUSTER_SCRIPT ?= $(SCR)/clustering_aib.awk
CLUSTER_TRAJ = $(addsuffix .clutraj,${DATA})

## rules
%.clutraj : % $(CLUSTER_SCRIPT)
	$(clustering_command)

define clustering_command
$(lastword $+)\
	-v min_col=$(strip ${MIN_COL})\
	-v max_col=$(strip ${MAX_COL}) $< > $@
endef

## macros to be called later
#MACROS +=

## info
ifndef INFO
INFO = clustering
define INFOADD
endef
else
INFOend +=
endif
INFO_clustering = apply clustering

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST +=
CLEAN_LIST +=
PURGE_LIST += $(CLUSTER_TRAJ)
