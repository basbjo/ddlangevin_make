#!/usr/bin/env python
#Average second column over several files
#Infile format: x_common(%.6e) y_file_specific
#For identical x values, y values are averaged
#Outfile format: x y_mean stddev_of_mean number_of_y_values

import sys

PRECISION=5
FMT="%.6e "

if len(sys.argv) <= 1:
    sys.exit("Usage: %s filenames" % sys.argv[0])

filenames = sys.argv[1:]

# read data and use first column as keys
xvals = {}
yvals = {}
for filename in filenames:
    with open(filename) as f:
        for row in f.readlines():
            row = row.strip()
            if len(row) >= 1 and row[0] != '#':
                row = row.split()
                if len(row) >= 2:
                    x = float(row[0])
                    y = float(row[1])
                    key = round(x,PRECISION)
                    if not key in yvals:
                        xvals[key] = [x]
                        yvals[key] = [y]
                    else:
                        xvals[key].append(x)
                        yvals[key].append(y)

# helper functions
def _mean(values):
    """
    @type values: list
    """
    return sum(values)/len(values)

def _std(values,ddof=0):
    """
    @type values: list
    """
    var = sum([i**2 for i in values])
    var -= sum(values)**2/len(values)
    if var >= 0:
        var /= (len(values) - ddof)
    else:
        var = 0
    return _sqrt(var)

def _sqrt(num):
    """
    @type values: list
    """
    return num**0.5

# average and write to stdout
print("#averaged data series")
print("#format: x y_mean stddev_of_mean n_y_values")
for key in sorted(yvals.keys()):
    values = yvals[key]
    if len(values) > 1:
        error = FMT % (_std(values,ddof=1)/_sqrt(len(values)))
    else:
        error = "nan "
    print((2*FMT+"%s %d") % (_mean(xvals[key]),
        _mean(values), error, len(values)))
