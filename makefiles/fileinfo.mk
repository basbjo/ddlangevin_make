.PHONY: showncols

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF += IF_FUTURE
SHOWDATA +=

## default settings that must be changed before including this file

## variables
# maximum number of columns per data file
lastcol = $(call getmax,$(foreach file,${DATA},${NCOLS_${file}}))
# maximum number of plots per data file
lastplot = $(call getmax,${LAST_PLOTS})

## rules
showncols: ;@true
	$(info # Number of columns in file minus IF_FUTURE (${IF_FUTURE}))
	$(foreach file,${DATA},$(info ${file}: ${NCOLS_${file}}))

## macros
# columns in file $(1) minus $(IF_FUTURE)
define NCOLS_template
  NCOLS_$(1) = $(call fcols,${1})
endef
# minimum of NCOLS_file and name_LAST_COL (file: $(1), name: $(2))
define NCOLSN_template
  NCOLS_$(1)_$(2) = $(call getmin,$(NCOLS_${1}) ${${2}_LAST_COL})
endef
# 01 02 ... NCOLS_file_name (file: $(1), name: $(2))
define COLS_template
  COLS_$(1)_$(2) = $(call range,${NCOLS_${1}_${2}})
endef
# 01 02 ... up to number of plots needed with $(2)_PLOT_NCOLS columns per plot
define PLOTS_template
  LAST_PLOTS += $(call nplots,${1},${2})
  PLOTS_$(1)_$(2) = $(call range,$(call nplots,${1},${2}))
endef

# for each file in $(1) list file-V##$(2) up to NCOLS_file_$(3)
define add-V01
  $(foreach file,${1},$(foreach nn,${COLS_${file}_${3}},\
	  $(addsuffix -V${nn}${2},${file})))
endef

# for each file in $(1) list file-V##-V##$(2) up to NCOLS_file_$(3)
define add-V01-V02
  $(foreach file,${1},$(foreach nn2,${COLS_${file}_${3}},\
	  $(foreach nn1,$(call rangeto,${nn2}),\
	  $(addsuffix -V${nn1}-V${nn2}${2},${file}))))
endef

# number of plots for file $(1) and name $(2)
nplots = $(call divide_ceil,${NCOLS_${1}_${2}},${${2}_PLOT_NCOLS})

# for each file in $(1) list file_$(2)##$(3) up to the smallest integer that is
# needed to group NCOLS_file_$(4) columns in plots with $(4)_PLOT_NCOLS columns
define add_01
  $(foreach file,${1},$(foreach nn,${PLOTS_${file}_${4}},\
	  $(addsuffix ${2}${nn}${3},${file})))
endef

# for each column needed for $(2)'th plot to file $(1) list file-V##$(3) with
# $(4)_PLOT_NCOLS columns per plot and a total of NCOLS_file_$(4) columns
define plot-V01
  $(foreach nn,$(call plotcols,${${4}_PLOT_NCOLS},${2},${NCOLS_${1}_${4}}),\
	  $(addsuffix -V${nn}${3},${1}))
endef

## macros to be called later
MACROS += fileinfo

# lists of colums are created for names in FILEINFO_NAMES
#     variables name_LAST_COL (last column used) are optional
# lists for plots are created for names in FILEINFO_PLOTS
#     variables name_PLOT_NCOLS (columns per plot) are necessary
define fileinfo
  $(foreach file,${DATA},$(eval $(call NCOLS_template,${file})))\
  $(foreach file,${DATA},$(foreach name,${FILEINFO_NAMES},\
	  $(eval $(call NCOLSN_template,${file},${name}))\
	  $(eval $(call COLS_template,${file},${name}))))\
  $(foreach file,${DATA},$(foreach name,${FILEINFO_PLOTS},\
	  $(eval $(call PLOTS_template,${file},${name}))))
endef

## info
INFOend += showncols
INFO_showncols = show numbers of data columns
