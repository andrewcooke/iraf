# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include <math/iminterp.h>
include "im1interpdef.h"

# ARIEVAL -- procedure to evaluate the interpolant at a given value of x
# Arival allows  the interpolation of a few interpolated points without
# the computing time and storage required for the seuential version.

real procedure arieval (x, datain, npts, interp_type)

real	x		# x value, 1 <= x <= n
real	datain[ARB]	# array of data values
int	npts		# number of data values
int	interp_type	# interpolant type

int 	i, k, nearx, pindex
real	a[MAX_NDERIVS], cd20, cd21, cd40, cd41, deltax, deltay, hold
real	bcoeff[SPLPTS+3], temp[SPLPTS+3], pcoeff[SPLINE3_ORDER]

begin
	switch (interp_type) {

	case II_NEAREST:
	    return (datain[int (x + 0.5)])

	case II_LINEAR:
	    nearx = x
	    # protect against x = n case
	    if (nearx >= npts)
		hold = 2. * datain[nearx] - datain[nearx - 1]
	    else
		hold = datain[nearx+1]
	    return ((x - nearx) * hold + (nearx + 1 - x) * datain[nearx])

	case II_POLY3:
	    nearx = x

	    # The major complication is that near the edge interior polynomial
	    # must somehow be defined.
	    k = 0
	    for (i = nearx - 1; i <= nearx + 2; i = i + 1) {
		k = k + 1

		# project data points into temporary array
		if (i < 1)
		    a[k] = 2. * datain[1] - datain[2-i]
		else if (i > npts)
		    a[k] = 2. * datain[npts] - datain[2*npts-i]
		else
		    a[k] = datain[i]
	    }

	    deltax = x - nearx
	    deltay = 1. - deltax

	    # second central differences
	    cd20 = 1./6. * (a[3] - 2. * a[2] + a[1])
	    cd21 = 1./6. * (a[4] - 2. * a[3] + a[2])

	    return (deltax * (a[3] + (deltax * deltax - 1.) * cd21) +
		    deltay * (a[2] + (deltay * deltay - 1.) * cd20))

	case II_POLY5:
	    nearx = x

	    # The major complication is that near the edge interior polynomial
	    # must somehow be defined.
	    k = 0
	    for (i = nearx - 2; i <= nearx + 3; i = i + 1) {
		k = k + 1

		# project data points into temporary array
		if (i < 1)
		    a[k] = 2. * datain[1] - datain[2-i]
		else if (i > npts)
		    a[k] = 2. * datain[npts] - datain[2*npts-i]
		else
		    a[k] = datain[i]
	    }

	    deltax = x - nearx
	    deltay = 1. - deltax

	    # second central differences
	    cd20 = 1./6. * (a[4] - 2. * a[3] + a[2])
	    cd21 = 1./6. * (a[5] - 2. * a[4] + a[3])

	    # fourth central differences
	    cd40 = 1./120. * (a[1] - 4. * a[2] + 6. * a[3] - 4. * a[4] + a[5])
	    cd41 = 1./120. * (a[2] - 4. * a[3] + 6. * a[4] - 4. * a[5] + a[6])

	    return (deltax * (a[4] + (deltax * deltax - 1.) *
	    	   (cd21 + (deltax * deltax - 4.) * cd41)) +
	    	   deltay * (a[3] + (deltay * deltay - 1.) *
		   (cd20 + (deltay * deltay - 4.) * cd40)))

	case II_SPLINE3:
	    nearx = x

	    deltax = x - nearx
	    k = 0

	    # maximum number of points used is SPLPTS
	    for (i = nearx - SPLPTS/2 + 1; i <= nearx + SPLPTS/2; i = i + 1) {
		if (i < 1 || i > npts)
		    ;
		else {
		    k = k + 1
		    if (k == 1)
			pindex = nearx - i + 1
		    bcoeff[k+1] = datain[i]
		}
	    }

	    bcoeff[1] = 0.
	    bcoeff[k+2] = 0.

	    # Use special routine for cardinal splines.
	    call ii_spline (bcoeff, temp, k)

	    pindex = pindex + 1
	    bcoeff[k+3] = 0.

	    pcoeff[1] = bcoeff[pindex-1] + 4. * bcoeff[pindex] +
	    		bcoeff[pindex+1]
	    pcoeff[2] = 3. * (bcoeff[pindex+1] - bcoeff[pindex-1])
	    pcoeff[3] = 3. * (bcoeff[pindex-1] - 2. * bcoeff[pindex] +
	    		bcoeff[pindex+1])
	    pcoeff[4] = -bcoeff[pindex-1] + 3. * bcoeff[pindex] - 3. *
	    		bcoeff[pindex+1] + bcoeff[pindex+2]
		    
	    return (pcoeff[1] + deltax * (pcoeff[2] + deltax *
	    	   (pcoeff[3] + deltax * pcoeff[4])))
	}
end
