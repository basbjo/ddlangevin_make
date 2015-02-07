#OLANGEVIN_DATA += $(addprefix catdata/,$(foreach suffix,-01 -02,\
	$(addsuffix ${suffix},\
	$(foreach k,25 200 500,\
	$(RAWDATA).dle2$(OL_SUFFIX).m1.k${k}.lang))))
#OLANGEVIN_DATA += $(addprefix catdata/,$(foreach suffix,-01 -02,\
	$(addsuffix ${suffix},\
	$(foreach k,750,\
	$(RAWDATA).dle2$(OL_SUFFIX).weights.m1.k${k}.lang))))

catdata/$(RAWDATA).dle2$(OL_SUFFIX).m1.k%.lang-01: $(RAWDATA)
	ol-second$(OL_SUFFIX) -m1 -k$* -F7 -L1000001 -I1 $< -o $@

catdata/$(RAWDATA).dle2$(OL_SUFFIX).m1.k%.lang-02: $(RAWDATA)
	ol-second$(OL_SUFFIX) -m1 -k$* -F7 -L1000001 -I2 $< -o $@

catdata/$(RAWDATA).dle2$(OL_SUFFIX).m1.k%.lang-03: $(RAWDATA)
	ol-second$(OL_SUFFIX) -m1 -k$* -F7 -L1000001 -I3 $< -o $@

catdata/$(RAWDATA).dle2$(OL_SUFFIX).m1.k%.lang-04: $(RAWDATA)
	ol-second$(OL_SUFFIX) -m1 -k$* -F7 -L1000001 -I4 $< -o $@

catdata/$(RAWDATA).dle2$(OL_SUFFIX).weights.m1.k%.lang-01: $(RAWDATA)
	ol-second-weights$(OL_SUFFIX) -m1 -k$* -F7 -L1000001 -I1 $< -o $@

catdata/$(RAWDATA).dle2$(OL_SUFFIX).weights.m1.k%.lang-02: $(RAWDATA)
	ol-second-weights$(OL_SUFFIX) -m1 -k$* -F7 -L1000001 -I2 $< -o $@

catdata/$(RAWDATA).dle2$(OL_SUFFIX).weights.m1.k%.lang-03: $(RAWDATA)
	ol-second-weights$(OL_SUFFIX) -m1 -k$* -F7 -L1000001 -I3 $< -o $@

catdata/$(RAWDATA).dle2$(OL_SUFFIX).weights.m1.k%.lang-04: $(RAWDATA)
	ol-second-weights$(OL_SUFFIX) -m1 -k$* -F7 -L1000001 -I4 $< -o $@

