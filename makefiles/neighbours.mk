.PHONY: no_neighbour_dependence
no_neighbour_dependence: $$(ALL)

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF += OL_SUFFIX dt
SHOWDATA += ALL

## default settings that must be changed before including this file

## variables
OL_SUFFIX = $(shell grep ^OL_SUFFIX ../../Makefile | sed 's/^[^=]*= *//;s/ *\#.*//')

dt = $(shell grep ^dt $(GPMODEL) | sed 's/^[^=]*= *//;s/ *\#.*//')

ALL = noise_variances.eps friction_averages.eps diffusion_averages.eps

ALL := $(ALL) $(sort $(patsubst %.eps,%.pdf,${ALL} $(wildcard *.eps))\
       $(patsubst %.eps,%.png,${ALL} $(wildcard *.eps)))\
       $(wildcard *_noweights)

## rules

# macros
define rule_make_eps
$(1).pdf: $(1).eps
	epstopdf $$<
$(1).eps: $(1).gp $(1)_noweights
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

# rules to create eps files
$(foreach name,friction_averages diffusion_averages noise_variances,\
	$(eval $(call rule_make_eps,${name})))

# rules to create data files
friction_averages_noweights: $(wildcard ../*.dle2$(OL_SUFFIX).m1.*.x1.g_1_1.bins)
	$(call macro_bin_average,friction,mean)

diffusion_averages_noweights: $(wildcard ../*.dle2$(OL_SUFFIX).m1.*.x1.K_1_1.bins)
	$(call macro_bin_average,diffusion,mean)

noise_variances_noweights: $(wildcard ../*.dle2$(OL_SUFFIX).m1.*.x1.xi1.bins)
	$(call macro_bin_average,noise,var)

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

Use make to create eps/pdf/png from further gnuplot files
that use the »gpmodel« variable and produce eps output.$(if $(example_suffix),

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
PLOTS_LIST +=
CLEAN_LIST +=
PURGE_LIST +=
