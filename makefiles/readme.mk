.PHONY: doc
doc: $$(README)

## default settings
README ?= README.html

## info
INFOend += doc
INFO_doc = create documentation README.html

## clean
PURGE_LIST += $(README)
