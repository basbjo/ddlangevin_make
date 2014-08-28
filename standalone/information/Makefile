prefix = ../..
datadirs = ..
makedir = $(prefix)/makefiles
include $(makedir)/common.mk
include $(makedir)/fileinfo.mk
include $(makedir)/information.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DATA_LINK = *.dat
DROPSUFFIX = .dat

## settings
IF_FUTURE = 0		# 1 if last column for follower, 0 else
# settings for negentropies
NEGENT_LAST_COL = 20	# last column (optional)

## default targets
all += negentropy

## call macros
$(call_macros)
