.PHONY: showncols

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF += IF_FUTURE
SHOWDATA +=

## default settings that must be changed before including this file

## variables
# maximum number of columns per file
lastcol = $(call getmax,$(foreach file,${DATA},${NCOLS_${file}}))

## rules
showncols: ;@true
	$(info # Number of columns in file minus IF_FUTURE (${IF_FUTURE}))
	$(foreach file,${DATA},$(info ${file}: ${NCOLS_${file}}))

## macros
# columns in file $(1) minus $(IF_FUTURE)
define NCOLS_template
  NCOLS_$(1) = $(call fcols,${1})
endef

# columns in file $(1) minus $(IF_FUTURE), or $(2) if specified and smaller
ncols = $(call getmin,${NCOLS_${1}} ${2})

# for each file in $(1) list file-V##$(2) up to NCOLS_file or $(3)_LAST_COL
define add-V01
  $(foreach file,${1},$(foreach nn,$(call range,\
	  $(call ncols,${file},${${3}_LAST_COL})),\
	  $(addsuffix -V${nn}${2},${file})))
endef

# for each file in $(1) list file-V##-V##$(2) up to NCOLS_file or $(3)_LAST_COL
define add-V01-V02
  $(foreach file,${1},$(foreach nn2,\
	  $(call range,$(call ncols,${file},${${3}_LAST_COL})),\
	  $(foreach nn1,$(call rangeto,${nn2}),\
	  $(addsuffix -V${nn1}-V${nn2}${2},${file}))))
endef

# number of plots for file $(1) with maximum $(2) columns and $(3) per plot
nplots = $(call divide_ceil,$(call ncols,${1},${2}),${3})

# for each file in $(1) list file_$(2)##$(3) up to the smallest integer to group
# NCOLS_file or $(4)_LAST_COL columns in files with $(4)_PLOT_NCOLS columns
define add_01
  $(foreach file,${1},$(foreach nn,$(call range,\
	  $(call nplots,${file},${${4}_LAST_COL},${${4}_PLOT_NCOLS})),\
	  $(addsuffix ${2}${nn}${3},${file})))
endef

## macros to be called later
MACROS += fileinfo

define fileinfo
  $(foreach file,${DATA},$(eval $(call NCOLS_template,${file})))
endef
