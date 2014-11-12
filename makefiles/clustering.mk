.PHONY: clustering centers plot plot_all
clustering: $$(CLUSTER_TRAJ)

centers: clustering $$(CLUSTER_CENTERS)

plot: $$(CENTERS_PLOT)

plot_all: plot

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
CENTERS_PLOT = $(addprefix clucenters_,$(call add-V01-V02,\
	       $(wildcard ${RAWDATA}),.png,CLUSTER))

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

define template_plot
clucenters_$(1)-V$(2)-V$(3).tex : $(1) $$(SCR)/plot_cluster_centers.gp
	gnuplot -e 'V1=$(patsubst 0%,%,${2}); V2=$(patsubst 0%,%,${3}); \
		FILEROOT="$$<"' $$(SCR)/plot_cluster_centers.gp
endef

## macros to be called later
MACROS += rule_clustering

FILEINFO_NAMES = CLUSTER
define rule_clustering
$(foreach file,$(wildcard ${RAWDATA}),\
	$(foreach col2,$(call range,$(call getmin,${CLUSTER_LAST_COL}\
		${lastcol})),$(foreach col1,$(call rangeto,${col2}),\
		$(eval $(call template_plot,${file},${col1},${col2})))))
endef

## info
ifndef INFO
INFO = clustering centers plot
define INFOADD
endef
else
INFOend +=
endif
INFO_clustering = apply clustering
INFO_centers    = cluster centers and standard deviations
INFO_plot       = plot cluster centers

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST += $(CENTERS_PLOT)
CLEAN_LIST +=
PURGE_LIST += $(addsuffix .clutraj,${RAWDATA}) $(addsuffix .clucenters,${RAWDATA})
