.PHONY: split
split: $$(SPLIT_DATA)

## default settings
SPLIT_FUTURE ?= $(or ${IF_FUTURE},1)# 1 if last column for follower, 0 else

# settings/data to be shown by showconf/showdata
SHOWCONF += SPLIT_FUTURE
SHOWDATA += splitdir SPLIT_LIST

## default settings that must be changed before including this file
splitdir ?= splitdata

## variables
SPLIT_SUFFIX =# only needed to find split data if split.mk is not included
SPLIT_LIST ?= $(DATA)
SPLIT_DATA = $(addsuffix -01,$(addprefix ${splitdir}/,\
	     $(wildcard ${SPLIT_LIST})))
DIR_LIST += $(splitdir)

## rules
$(splitdir):
	mkdir -p $@

# split data into consecutive trajectories / in two parts
# - end of each series when last column is 0
# - if SPLIT_FUTURE==0 split trajectory into two
$(splitdir)/%-01 : % | $(splitdir)
	$(split_command)

define split_command
  $(if $(shell [ ${SPLIT_FUTURE} -eq 1 ] && echo yes),\
	  # split file $< by last column into $(@D)/$*-##
	  awk 'BEGIN { i=1 } {\
	      print $$0 >sprintf("$(@D)/$*-%02d", i);\
	      if ($$NF==0) i++;\
	      $(awk_status)\
	  }' $<)
  $(if $(shell [ ${SPLIT_FUTURE} -eq 0 ] && echo yes),\
	  # split file $< in two parts $(@D)/$*-##
	  awk -vhalf=$$(($$(${NROWS} $<) / 2))\
	  'BEGIN { i=1 } {\
	      count++;\
	      print $$0 >sprintf("$(@D)/$*-%02d", i);\
	      if (count==half) i++;\
	      $(awk_status)\
	  }' $<)
endef

define awk_status
if(! (NR % 10000)) {\
	printf("\rsplit: lines processed: %d", NR) > "/dev/stderr";\
}} END { if(NR>=10000) { printf("\n") > "/dev/stderr" }
endef

## macros to be called later
#MACROS +=

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
SPLIT_WILD = $(addsuffix -[0-9]*[0-9],$(addprefix ${splitdir}/,${SPLIT_LIST}))
