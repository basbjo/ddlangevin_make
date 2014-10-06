.PHONY: clustering centers
clustering: $$(CLUSTER_TRAJ)

centers: clustering $$(CLUSTER_CENTERS)

## default settings
CLUSTER_LAST_COL ?= 5# last column (optional)

# settings/data to be shown by showconf/showdata
SHOWCONF += CLUSTER_SCRIPT CLUSTER_LAST_COL
SHOWDATA += CLUSTER_TRAJ CLUSTER_CENTERS

## default settings that must be changed before including this file

## variables
CLUSTER_SCRIPT ?= $(SCR)/clustering_aib.awk
CLUSTER_TRAJ = $(addsuffix .clutraj,$(wildcard ${RAWDATA}))
CLUSTER_CENTERS = $(addsuffix .clucenters,$(wildcard ${RAWDATA}))

## rules
%.clutraj : % $(CLUSTER_SCRIPT)
	$(clustering_command)

define clustering_command
$(lastword $+)\
	-v min_col=$(strip ${MIN_COL})\
	-v max_col=$(strip ${MAX_COL}) $< > $@
endef

%.clucenters : %$(PROJSUFFIX) %.clutraj
	$(centers_command)

define centers_command
paste -d\  $+ | $(SCR)/cluster_centers.awk -vlast_col=$(NCOLS_$<_CLUSTER) > $@
endef

## macros to be called later
#MACROS +=
FILEINFO_NAMES = CLUSTER

## info
ifndef INFO
INFO = clustering centers
define INFOADD
endef
else
INFOend +=
endif
INFO_clustering = apply clustering
INFO_centers = cluster centers and standard deviations

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST +=
CLEAN_LIST +=
PURGE_LIST += $(addsuffix .clutraj,${RAWDATA}) $(addsuffix .clucenters,${RAWDATA})
