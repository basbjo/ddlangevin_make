OLANGEVIN_DATA += $(addprefix catdata/,$(foreach suffix,-01 -02,\
	$(addsuffix ${suffix},\
	$(foreach k,50 300 1000,\
	$(RAWDATA).dle2$(OL_SUFFIX).m1.k${k}.lang))))
#OLANGEVIN_DATA += $(addprefix catdata/,$(foreach suffix,-01 -02,\
	$(addsuffix ${suffix},\
	$(foreach k,1500,\
	$(RAWDATA).dle2$(OL_SUFFIX).weights.m1.k${k}.lang))))

common_flags = -m1 -k$* -F$(shell echo `expr $(call fcols,$<) + 1`) -L1000001

catdata/$(RAWDATA).dle2$(OL_SUFFIX).m1.k%.lang-01: $(RAWDATA) | catdata
	ol-second$(OL_SUFFIX) $(common_flags) -I1 $< -o $@

catdata/$(RAWDATA).dle2$(OL_SUFFIX).m1.k%.lang-02: $(RAWDATA) | catdata
	ol-second$(OL_SUFFIX) $(common_flags) -I2 $< -o $@

catdata/$(RAWDATA).dle2$(OL_SUFFIX).m1.k%.lang-03: $(RAWDATA) | catdata
	ol-second$(OL_SUFFIX) $(common_flags) -I3 $< -o $@

catdata/$(RAWDATA).dle2$(OL_SUFFIX).m1.k%.lang-04: $(RAWDATA) | catdata
	ol-second$(OL_SUFFIX) $(common_flags) -I4 $< -o $@

catdata/$(RAWDATA).dle2$(OL_SUFFIX).weights.m1.k%.lang-01: $(RAWDATA) | catdata
	ol-second-weights$(OL_SUFFIX) $(common_flags) -I1 $< -o $@

catdata/$(RAWDATA).dle2$(OL_SUFFIX).weights.m1.k%.lang-02: $(RAWDATA) | catdata
	ol-second-weights$(OL_SUFFIX) $(common_flags) -I2 $< -o $@

catdata/$(RAWDATA).dle2$(OL_SUFFIX).weights.m1.k%.lang-03: $(RAWDATA) | catdata
	ol-second-weights$(OL_SUFFIX) $(common_flags) -I3 $< -o $@

catdata/$(RAWDATA).dle2$(OL_SUFFIX).weights.m1.k%.lang-04: $(RAWDATA) | catdata
	ol-second-weights$(OL_SUFFIX) $(common_flags) -I4 $< -o $@

