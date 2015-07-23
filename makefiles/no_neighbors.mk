.PHONY: no_neighbor_dependence
no_neighbor_dependence: $$(ALL)

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF += OL_SUFFIX dt
SHOWDATA += ALL

## default settings that must be changed before including this file

## variables
OL_SUFFIX ?= $(shell grep ^OL_SUFFIX ../../Makefile | sed 's/^[^=]*= *//;s/ *\#.*//')

dt ?= $(shell grep ^dt $(GPMODEL) | sed 's/^[^=]*= *//;s/ *\#.*//')

ALL ?= noise_variances.png friction_averages.png diffusion_averages.png\
       distance_averages.png abs_ecc_averages.png var_ratio_fut_averages.png

## rules

# macros
define rule_make_eps
$(1).pdf: $(1).eps
	epstopdf $$<
$(1).eps: $(1).gp $(1)_noweights.dat
	gnuplot -e 'gpmodel="$$(GPMODEL)"' $$<
endef

define macro_bin_average
for file in $+; do\
	echo $${file} `cat $${file} | $(bin_average_${1})` \
	| sed 's/.*m1.k//;s/.ltm[^ ]* / /';\
	done | sort -n \
	| awk 'BEGIN{print "#k ${1}_${2} ${1}_${2}_std"}{print $$0}' > $@
endef

# commands
meanstd = awk '!/^\#/ {count ++; sum += $$2; sumsq += $$2**2}\
	  END{print sum/count, sqrt((sumsq - sum**2/count)/(count-1))}'
bin_average_friction = $(meanstd) | awk '{print ($$1+1)/$(dt), $$2/$(dt)}'
bin_average_diffusion = $(meanstd) | awk '{print $$1/$(dt)**1.5, $$2/$(dt)}'
bin_average_noise = awk '!/^\#/ {print $$1, $$3**2*$$4}' | $(meanstd)
bin_average_distance = $(meanstd)
bin_average_abs_ecc = $(meanstd)
bin_average_var_ratio_fut = $(meanstd)

# rules to create eps files
$(foreach name,friction_averages diffusion_averages noise_variances\
	distance_averages abs_ecc_averages var_ratio_fut_averages,\
	$(eval $(call rule_make_eps,${name})))

# rules to create data files
friction_averages_noweights.dat: $$(wildcard ../*.dle2$$(OL_SUFFIX).m1.*.x1.g_1_1.bins)
	$(call macro_bin_average,friction,mean)

diffusion_averages_noweights.dat: $$(wildcard ../*.dle2$$(OL_SUFFIX).m1.*.x1.K_1_1.bins)
	$(call macro_bin_average,diffusion,mean)

noise_variances_noweights.dat: $$(wildcard ../*.dle2$$(OL_SUFFIX).m1.*.x1.xi1.bins)
	$(call macro_bin_average,noise,var)

distance_averages_noweights.dat: $$(wildcard ../*.dle2$$(OL_SUFFIX).m1.*.x1.distance.bins)
	$(call macro_bin_average,distance,mean)

abs_ecc_averages_noweights.dat: $$(wildcard ../*.dle2$$(OL_SUFFIX).m1.*.x1.abs_ecc.bins)
	$(call macro_bin_average,abs_ecc,mean)

var_ratio_fut_averages_noweights.dat: $$(wildcard ../*.dle2$$(OL_SUFFIX).m1.*.x1.var_ratio_fut.bins)
	$(call macro_bin_average,var_ratio_fut,mean)

# rules for additional gnuplot files

%.eps: %.gp; gnuplot -e 'gpmodel="$(GPMODEL)"' $<

%.pdf: %.eps; epstopdf $<

## macros to be called later
#MACROS +=

## info
ifndef INFO
empty =
INFO = $(empty)
define INFOADD

Use make to create eps/pdf/png from further gnuplot files that
use the »gpmodel« variable and produce eps output (for example
if plot.gp creates plot.eps, add »plot.pdf plot.png« to ALL).$(if $(example_suffix),

WARNING: Plotting friction and diffusion averaged over the
	 x-axis is meaningful for the default model with
	 constant friction and diffusion but not for variants.)

endef
else
INFOend +=
endif

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST += $(addsuffix .eps,$(basename ${ALL}))
CLEAN_LIST +=
PURGE_LIST += $(addsuffix _noweights.dat,$(basename ${ALL}))