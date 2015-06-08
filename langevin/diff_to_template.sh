#!/bin/bash
# Compare all copies to makefiles in template

for tmpl in \
    template/Makefile\
    template/fields/Makefile\
    template/histogram/Makefile
do
    for dir in `find . -mindepth 1 -maxdepth 1 -type d -not -name template`
    do
        eval "diff -q ${tmpl} ${tmpl/template/${dir}}" >/dev/null || (
            echo "#===== ${tmpl} vs ${tmpl/template/${dir}} ====="
            eval "diff ${tmpl} ${tmpl/template/${dir}}"
            echo
            )
    done
done
