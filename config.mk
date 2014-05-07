# do not add any targets in this file
makedir = $(prefix)/makefiles

## source data
TIME_UNIT = ps
RAWDATA = alldih*_1$(TIME_UNIT)
# name format: <unique name without dots>[.suffixes]_<num>$(TIME_UNIT)
# data format: "[time] dihedral_angles... [future]"
#      future: 0 at end of trajectory / 1 else
IF_FUTURE ?= 1# 1 with future column, 0 else
