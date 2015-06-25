.PHONY:

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF += IF_FUTURE OL_SUFFIX OL_TM_FLAGS OL_SN_FLAGS
SHOWDATA +=

## default settings that must be changed before including this file

## variables
OL_SUFFIX ?=# extra suffix for olangevin programs
OL_TM_FLAGS ?=# additional flags for olangevin testmodel programs
OL_SN_FLAGS ?=# additional flags for ol-search-neighbors programs

## rules
# select columns from data files
define template_selectcolumns
$(1).%cols : $(1)
	$(SCR)/select_outer_columns.awk -vnfirst=$$* -vnlast=$$(IF_FUTURE) $$< > $$@
endef

# create testmodel trajectories
define template_testmodel
$(1).dle1$(OL_SUFFIX).%.ltm: $(1)
	ol-first-tm$(OL_SUFFIX) $$(call testmodel_args,${1})
$(1).dle2$(OL_SUFFIX).%.ltm: $(1)
	ol-second-tm$(OL_SUFFIX) $$(call testmodel_args,${1})
$(1).dle1.%.osn: $(1)
	ol-search-neighbors$(OL_SUFFIX) -W1 $$(call neighbor_args,${1})
$(1).dle2.%.osn: $(1)
	ol-search-neighbors$(OL_SUFFIX) -W2 $$(call neighbor_args,${1})
$(1).%.osn: $(1)
	ol-search-neighbors$(OL_SUFFIX) $$(call neighbor_args,${1})
endef

extract_argument = $(shell echo $@|egrep -o '\.$(1)[0-9]+\.'|grep -o '[0-9]*')

define m_k_opt_arg
-m$(call extract_argument,m) \
-k$(call extract_argument,k)
endef

define testmodel_args
$(m_k_opt_arg)$(if\
$(shell [ ${IF_FUTURE} -eq 1 ] && echo yes),\
 -F$(shell echo `expr $(call fcols,$<) + 1`))$(if\
$(wildcard $(1).m$(call extract_argument,m).ltmp),\
 -t $(wildcard ${1}.m$(call extract_argument,m).ltmp))$(if\
${OL_TM_FLAGS},\
 ${OL_TM_FLAGS}) $< -o $@
endef

define neighbor_args
$(m_k_opt_arg)$(if\
$(shell [ ${IF_FUTURE} -eq 1 ] && echo yes),\
 -F$(shell echo `expr $(call fcols,$<) + 1`))$(if\
$(wildcard $(1).m$(call extract_argument,m).osnp),\
 -t $(wildcard ${1}.m$(call extract_argument,m).osnp))$(if\
${OL_SN_FLAGS},\
 ${OL_SN_FLAGS}) $< -o $@
endef

## macros to be called later
MACROS += rule_langevin
define rule_langevin
$(foreach file,${DATA},\
	$(eval $(call template_selectcolumns,${file}))\
	$(eval $(call template_testmodel,${file})))
endef

## info
ifndef INFO
INFO = cat split
define INFOADD

To extract say 3 columns from a data file, call »make file.3cols«.
If IF_FUTURE is 1, also the last column of the file is appended.

Set variable OL_SUFFIX in Makefile for alternative olangevin programs.
In olangevin programs, the number of components is selected by option
»-m« and the number of neighbors by »-k«.  Here, this is reflected
by an extension ».m<num>.k<num>« in the output filenames.
Let »symlink« an input trajectory in the following.

Testmodel:
  Testmodel trajectories »symlink.dle<n>$(OL_SUFFIX).m<m>.k<k>.ltm«
  can be created where <n> is 1 for ol-first-tm$(OL_SUFFIX)
                          and 2 for ol-second-tm$(OL_SUFFIX).
  Correct arguments to -m, -k and -F are generated automatically.
  If »symlink.m<m>.ltmp« is provided, fields are calculated for
  points in this file and not for all points in input data.
  Use variable »OL_TM_FLAGS« to provide additional options.

  Testmodel trajectories can be splitted with the »split« target.

Neighbors:
  Neighbor indices in »symlink.m<m>.k<k>.osn« can be created.
  To obtain the neighbourhoods that are used by ol-first or
  ol-second, create »symlink.dle<n>.m<m>.k<k>.osn«, n = 1,2.
  If »symlink.m<m>.osnp« is provided, neighbors are searched for
  points in this file and not for all points in input data.
  Use variable »OL_SN_FLAGS« to provide additional options.

Langevin:
  Save Langevin trajectories of a data file to »file.detail.lang«
  manually.  The detail commonly reflects the options, for options
  »-m5« and »-k50« the results may be saved to »file.m5.k50.lang«.
  Edit »localconf.mk« to specify whether a follower column exists.
  Single trajectories »$(catdir)/file.detail.lang-##« are concatenated
  to »file.detail.lang« with a follower column by the »cat« target.
  Files »$(catdir)/name-##.field« are concatenated to »name.field«.

  Target »cat_links« creates symbolic links in »splitdata« that are
  needed for subdirectories that require split data.

endef
else
INFOend +=
endif

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST +=
CLEAN_LIST +=
PURGE_LIST +=
