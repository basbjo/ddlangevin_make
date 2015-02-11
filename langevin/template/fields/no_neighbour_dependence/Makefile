# variables
OL_SUFFIX = $(shell grep ^OL_SUFFIX ../../Makefile | sed 's/^[^=]*= *//;s/ *\#.*//')

ALL = noise_variances.eps friction_averages.eps

ALL := $(ALL) $(sort $(patsubst %.eps,%.pdf,${ALL} $(wildcard *.eps))\
       $(patsubst %.eps,%.png,${ALL} $(wildcard *.eps)))\
       $(wildcard *_noweights)

dt = 0.001

# macros
define macro_bin_average
for file in $+; do\
	echo $${file} `$(${1}) $${file}` \
	| sed 's/.*m1.k//;s/.ltm[^ ]* / /';\
	done | sort -n | awk 'BEGIN{print "#k ${2}"}{print $$0}' > $@
endef

# commands
bin_average_friction = awk '!/^\#/ {count++; sum += $$2}END{print (sum/count+1)/$(dt)}'
bin_average_noise = awk '!/^\#/ {count++; sum += $$3**2*$$4}END{print sum/count}'

# targets
.PHONY: all purge
all: $(ALL)

purge:
	$(if $(wildcard ${ALL}),$(RM) $(wildcard ${ALL}))

%.eps: %.gp
	gnuplot $<

%.pdf: %.eps
	epstopdf $<

%.png: %.pdf
	pdftoppm -png -l 1 $< > $@

friction_averages.eps: friction_averages.gp friction_averages_noweights
	#friction_averages_weights
	gnuplot $<

command_friction_averages = $(call macro_bin_average,bin_average_friction,friction_mean)

noise_variances.eps: noise_variances.gp noise_variances_noweights
	#noise_variances_weights
	gnuplot $<

command_noise_variances = $(call macro_bin_average,bin_average_noise,noise_var)

friction_averages_noweights: $(wildcard ../*.dle2$(OL_SUFFIX).m1.*.x1.g_1_1.bins)
	$(command_friction_averages)

noise_variances_noweights: $(wildcard ../*.dle2$(OL_SUFFIX).m1.*.x1.xi1.bins)
	$(command_noise_variances)

noise_variances_weights: $(wildcard ../*.dle2$(OL_SUFFIX).weights.*.x1.xi1.bins)
	$(command_noise_variances)

