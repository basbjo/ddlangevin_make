.PHONY: clustering coring centers plot plot_all plot_centers plot_projs
clustering: $$(CLUSTER_TRAJ)

coring: $$(CORE_TRAJ)

centers: coring $$(CORE_CENTERS)

plot: plot_centers plot_projs

plot_all: plot

plot_centers: $$(CENTERS_PLOT)

plot_projs: $$(PROJS_PLOT)

## default settings
CLUSTER_LAST_COL ?= 5# last column (optional)

# settings/data to be shown by showconf/showdata
SHOWCONF += CORE_SCRIPT CLUSTER_LAST_COL
SHOWDATA += CLUSTER_TRAJ CORE_TRAJ CORE_CENTERS

## default settings that must be changed before including this file

## variables
CLUSTER_SCRIPT ?= $(SCR)/clustering_aib.awk
CORE_SCRIPT ?= $(SCR)/coring_aib.awk
CLUSTER_TRAJ = $(addsuffix .clutraj,$(wildcard ${RAWDATA}))
CORE_TRAJ = $(addsuffix .coretraj,$(wildcard ${RAWDATA}))
CORE_CENTERS = $(addsuffix $(PROJSUFFIX).corecenters,$(wildcard ${RAWDATA}))
CENTERS_PLOT = $(addprefix corecenters_,$(call add-V01-V02,\
	       $(addsuffix $(PROJSUFFIX),$(wildcard ${RAWDATA})),.png,CLUSTER))
PROJS_PLOT = $(addprefix coreprojs_,$(call add-V01-V02,\
	       $(addsuffix $(PROJSUFFIX),$(wildcard ${RAWDATA})),.png,CLUSTER))
.INTERMEDIATE: $$(patsubst %.png,%.eps,$${PROJS_PLOT})

## rules
%.clutraj : % $(CLUSTER_SCRIPT)
	$(clustering_command)

%.coretraj : % $(CORE_SCRIPT)
	$(coring_command)

define coring_command
$(lastword $+)\
	-v min_col=$(strip ${MIN_COL})\
	-v max_col=$(strip ${MAX_COL}) $< > $@
endef

%$(PROJSUFFIX).corecenters : %$(PROJSUFFIX) %.coretraj
	$(corecenters_command)

define corecenters_command
paste -d\  $+ | $(SCR)/core_centers.awk -vlast_col=$(NCOLS_$<_CLUSTER) > $@
endef

define template_plot
corecenters_$(1)-V$(2)-V$(3).tex : $(1).corecenters $$(SCR)/plot_core_centers.gp
	gnuplot -e 'V1=$(patsubst 0%,%,${2}); V2=$(patsubst 0%,%,${3}); \
		FILEROOT="$(1)"' $$(lastword $$+)
endef

define template_plot_alt
coreprojs_$(1)$(PROJSUFFIX)-V$(2)-V$(3).eps : $(1)$(PROJSUFFIX) $(1).coretraj\
		$$(SCR)/plot_core_projections.gp
	gnuplot -e 'V1=$(patsubst 0%,%,${2}); V2=$(patsubst 0%,%,${3}); \
		FILE="$$<"; CLUTRAJ="$$(word 2,$$+)"' $$(lastword $$+)
endef

## macros to be called later
MACROS += rule_clustering

FILEINFO_NAMES = CLUSTER
define rule_clustering
$(foreach file,$(wildcard ${RAWDATA}),\
	$(foreach col2,$(call range,$(call getmin,${CLUSTER_LAST_COL}\
		${lastcol})),$(foreach col1,$(call rangeto,${col2}),\
		$(eval $(call template_plot\
		,${file}${PROJSUFFIX},${col1},${col2}))\
		$(eval $(call template_plot_alt\
		,${file},${col1},${col2})))))
endef

## info
ifndef INFO
INFO = clustering coring centers plot_centers plot_projs plot
define INFOADD
endef
else
INFOend +=
endif
INFO_clustering = apply clustering
INFO_coring     = apply coring
INFO_centers    = core centers and standard deviations
INFO_plot_centers = plot core centers
INFO_plot_projs   = plot core projections
INFO_plot         = create all plots

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST += $(CENTERS_PLOT) $(PROJS_PLOT)
CLEAN_LIST +=
PURGE_LIST += $(CLUSTER_TRAJ) $(CORE_TRAJ) $(CORE_CENTERS)
