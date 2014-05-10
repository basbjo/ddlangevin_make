.PHONY: split
split: $$(SPLIT_DATA)

## default settings
SPLIT_FUTURE ?= $(or ${IF_FUTURE},1)# 1 if last column for follower, 0 else
SPLIT_DROPSUFFIX ?= # drop suffix of source filenames

# settings/data to be shown by showconf/showdata
SHOWCONF += SPLIT_FUTURE
SHOWDATA += splitdir SPLIT_DROPSUFFIX SPLIT_LIST

## default settings that must be changed before including this file
splitdir ?= splitdata

## variables
SPLIT_LIST ?= $(DATA)
SPLIT_DROP = $(patsubst %$(strip ${SPLIT_DROPSUFFIX}),%,$(wildcard ${SPLIT_LIST}))
SPLIT_DATA = $(addsuffix -01,$(addprefix ${splitdir}/,${SPLIT_DROP}))
DIR_LIST += $(splitdir)

## rules
$(splitdir):
	mkdir -p $@

# split data into consecutive trajectories / in two parts
# - end of each series when last column is 0
# - if SPLIT_FUTURE==0 split trajectory into two
$(splitdir)/%-01 : %$$(strip $${SPLIT_DROPSUFFIX}) | $$(splitdir)
	@$(split_command)

define split_command
  $(if $(shell [ ${SPLIT_FUTURE} -eq 1 ] && echo yes),\
	  $(info Split file $< by last column into $(@D)/$*-##.)\
	  awk 'BEGIN { i=1 } !/^#/ {\
	      print $$0 >sprintf("$(@D)/$*-%02d", i);\
	      if ($$NF==0) i++;\
	  }' $<)
  $(if $(shell [ ${SPLIT_FUTURE} -eq 0 ] && echo yes),\
	  $(info Split file $< in two parts $(@D)/$*-##.)\
	  awk -vhalf=$$(($$(${NROWS} $<) / 2))\
	  'BEGIN { i=1 } !/^#/ {\
	      count++;\
	      print $$0 >sprintf("$(@D)/$*-%02d", i);\
	      if (count==half) i++;\
	  }' $<)
endef

## macros to be called later
MACROS +=

## info
ifndef INFO
INFO = split
define INFOADD
endef
else
INFOend += split del_split
endif
INFO_split = split data (directory $(patsubst ./%,%,${splitdir}))
INFO_del_split = delete split data

## keep intermediate files
PRECIOUS +=

## clean
SPLIT_WILD = $(addsuffix -[0-9]*[0-9],$(addprefix ${splitdir}/,${SPLIT_DROP}))
