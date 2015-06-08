# This makefile creates filenames for down sampled data.

## variables
SAMPDATA = $(foreach file,$(wildcard ${SAMPORIG})\
	   ,$(foreach rfac,${REDUCTION_FACTORS}\
	   ,$(call down_sampled_linkname,${file},${TIME_UNIT},${rfac})))

## macros
define down_sampled_linkname
$(shell name=$(1); unit=$(2); factor=$(3);
prefix=`echo $${name}|sed -r "s/_[0-9.]+$${unit}.*//"`;
suffix=`echo $${name}|sed -r "s/.*_[0-9.]+$${unit}//"`;
oldvalue=`echo $${name}|egrep -o "_[0-9.]+$${unit}($$|\.)"|grep -o '[0-9.]*[0-9]'`;
newvalue=$$(printf "%g" `echo $${oldvalue}*$${factor}|bc`);
echo $${prefix}_$${newvalue}$${unit}$${suffix})
endef
