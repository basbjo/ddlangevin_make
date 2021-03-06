.PHONY: split
split: $$(SPLIT_DATA)

## default settings
SPLIT_FUTURE ?= $(or ${IF_FUTURE},1)# 1 if last column for follower, 0 else
SPLIT_KEEP_FUTURE ?= 0# 1 to keep follower column, else remove follower column

# settings/data to be shown by showconf/showdata
SHOWCONF += SPLIT_FUTURE SPLIT_KEEP_FUTURE
SHOWDATA += splitdir SPLIT_LIST

## default settings that must be changed before including this file
splitdir ?= splitdata

## variables
SPLIT_SUFFIX ?=# suffix contained in split data but not in source data
SPLIT_LIST ?= $(DATA)
SPLIT_DATA = $(addsuffix ${SPLIT_SUFFIX}-01,$(addprefix ${splitdir}/,\
	     $(wildcard ${SPLIT_LIST})))
DIR_LIST += $(splitdir)

## rules
$(splitdir):
	mkdir -p $@

# split data into consecutive trajectories / in two parts
# - end of each series when last column is 0
# - if SPLIT_FUTURE==0 split trajectory into two
define template_split
SPLIT_SUFFIX := $(SPLIT_SUFFIX)
$(splitdir)/%$(SPLIT_SUFFIX)-01 : % | $(splitdir)
	$$(split_command)
	$(if $(shell [ ${SPLIT_FUTURE} -eq 1 ] || [ ${SPLIT_FUTURE} -eq 0 ] \
		&& echo yes),touch -cmr $$< $$$$(find -L $$(@D) -type f \
		-regex '$$(@D)/$$*${SPLIT_SUFFIX}-[0-9]+'))
endef

define split_command
  $(if $(shell [ ${SPLIT_FUTURE} -eq 1 ] && echo yes),\
	  # split file $< by last column into $(@D)/$*$(SPLIT_SUFFIX)-##
	  awk 'BEGIN { i=1; end=0; }\
	  !/^#/ {\
	      if ($$NF==0) end=1;\
	      $(if $(patsubst 1,,${SPLIT_KEEP_FUTURE}),sub(" [01]$$","",$$0);,)\
	  } {\
	      print $$0 >sprintf("$(@D)/$*$(SPLIT_SUFFIX)-%02d", i);\
	      if (end) { i++; end=0; }\
	      $(awk_status)\
	  }' $<)
  $(if $(shell [ ${SPLIT_FUTURE} -eq 0 ] && echo yes),\
	  # split file $< in two parts $(@D)/$*$(SPLIT_SUFFIX)-##
	  awk -vhalf=$$(($$(${NROWS} $<) / 2))\
	  'BEGIN { i=1; count=1 } {\
	      print $$0 >sprintf("$(@D)/$*$(SPLIT_SUFFIX)-%02d", i);\
	      if (count==half) i++;\
	      $(awk_status)\
	  } !/^#/ { count++; }' $<)
endef

define awk_status
if(! (NR % 10000)) {\
	printf("\rsplit: lines processed: %d", NR) > "/dev/stderr";\
}} END { if(NR>=10000) { printf("\n") > "/dev/stderr" }
endef

## macros to be called later
MACROS += rule_split

define rule_split
$(eval $(call template_split))
endef

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
