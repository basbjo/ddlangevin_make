# Call make in all subdirectories except template

all: $(dir $(shell find . -mindepth 2 -maxdepth 2\
	-name Makefile -not -path "*/template/*"))

./*/::
	cd $@ && $(MAKE)
