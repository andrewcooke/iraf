include <mach.h>
include "../lib/center.h"

# AP_CTR1D -- Procedure to compute the center from the 1D marginal
# distributions.

int procedure ap_ctr1d (ctrpix, nx, ny,  xc, yc, xerr, yerr)

real	ctrpix[nx, ny]		# object to be centered
int	nx, ny			# dimensions of subarray
real	xc, yc			# computed centers
real	xerr, yerr		# estimate of centering error

pointer	sp, xm, ym

begin
	call smark (sp)
	call salloc (xm, nx, TY_REAL)
	call salloc (ym, ny, TY_REAL)

	# Compute the marginal distributions.
	call ap_mkmarg (ctrpix, Memr[xm], Memr[ym], nx, ny)
	call adivkr (Memr[xm], real (nx), Memr[xm], nx)
	call adivkr (Memr[ym], real (ny), Memr[ym], ny)

	# Get the centers and errors.
	call ap_cmarg (Memr[xm], nx, xc, xerr)
	call ap_cmarg (Memr[ym], ny, yc, yerr)

	call sfree (sp)
	return (AP_OK)
end


# AP_CMARG -- Compute the center and estimate its error given the
# marginal distribution and the number of points.

procedure ap_cmarg (a, npts, xc, err)

real	a[npts]		# array
int	npts		# number of points
real	xc		# center value
real	err		# error

int	i
real	sumi, sumix, sumix2
bool	fp_equalr()

begin
	# Initialize.
	sumi = 0.0
	sumix = 0.0
	sumix2 = 0.0

	# Accumulate the sums.
	do i = 1, npts {
	    sumi = sumi + a[i]
	    sumix = sumix + a[i] * i
	    sumix2 = sumix2 + a[i] * i ** 2
	}

	# Compute the position and the error.
	if (fp_equalr (sumi, 0.0)) {
	    xc =  (1.0 + npts) / 2.0
	    err = INDEFR
	} else {
	    xc = sumix / sumi
	    err = (sumix2 / sumi - xc ** 2)
	    if (err <= 0.0)
		err = 0.0
	    else
	        err = sqrt (err / sumi)
	}
end


# AP_MKMARG -- Accumulate the marginal distributions.

procedure ap_mkmarg (ctrpix, xm, ym, nx, ny)

real	ctrpix[nx, ny]		# pixels
real	xm[nx]			# x marginal distribution
real	ym[ny]			# y marginal distribution
int	nx, ny			# dimensions of array

int	i, j
real	sum

begin
	# Compute the x marginal.
	do i = 1, nx {
	    sum = 0.0
	    do j = 1, ny
		sum = sum + ctrpix[i,j]
	    xm[i] = sum
	}

	# Compute the y marginal.
	do j = 1, ny {
	    sum = 0.0
	    do i = 1, nx
		sum = sum + ctrpix[i,j]
	    ym[j] = sum
	}
end
