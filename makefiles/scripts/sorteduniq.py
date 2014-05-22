#!/usr/bin/env python
#Print arguments from stdin without showing words twice
import sys
uniqlist = []
for word in sys.argv[1:]:
    if word not in uniqlist:
        uniqlist.append(word)
print(" ".join(uniqlist))
