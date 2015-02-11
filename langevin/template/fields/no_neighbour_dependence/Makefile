# variables
OL_SUFFIX = $(shell grep ^OL_SUFFIX ../../Makefile | sed 's/^[^=]*= *//;s/ *\#.*//')

ALL = noise_variances.eps

ALL := $(ALL) $(sort $(patsubst %.eps,%.pdf,${ALL} $(wildcard *.eps))\
       $(patsubst %.eps,%.png,${ALL} $(wildcard *.eps)))\
       $(wildcard *_noweights)

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

noise_variances.eps: noise_variances.gp noise_variances_noweights
	#noise_variances_weights
	gnuplot $<

define command_noise_variances
grep deviation $+ | sed 's/.*m1.k//;s/.ltm.* / /' | sort -n \
	| awk 'BEGIN{print "#k noise_var"}{print $$1, $$2**2}' > $@
endef

noise_variances_noweights: $(wildcard ../*.dle2$(OL_SUFFIX).m1.*xi1.hist)
	$(command_noise_variances)

noise_variances_weights: $(wildcard ../*.dle2$(OL_SUFFIX).weights.*xi1.hist)
	$(command_noise_variances)

