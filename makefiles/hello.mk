.PHONY: hello
hello:
	@$(SCR)/print.sh '$(HELLO)'

## default settings
HELLO ?= "Hello world!"

# settings/data to be shown by showconf/showdata
SHOWCONF += HELLO
SHOWDATA +=

## default settings that must be changed before including this file

## variables

## rules

## macros to be called later
MACROS +=

## info
ifndef INFO
INFO = hello
INFO_hello = print »$(HELLO)«
define INFOADD
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
