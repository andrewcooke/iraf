include	<error.h>
include	<mach.h>
include	<gset.h>

define	HELP	"noao$lib/scr/deblend.key"
define	OP  "Option (a=0p1s, b=1p1s, c=np1s, d=0pns, e=1pns, f=npns, q=quit):"
define	SQ2PI	2.5066283

# DEBLEND -- Deblend up to 4 lines in a spectral region.

procedure deblend (gfd, x1, x2, dx, wx1, wy1, pix, ans, nans)

pointer	gfd			# GIO file descriptor
real	x1, x2, dx		# Coordinate scale
real	wx1, wy1		# Cursor position
real	pix[ARB]		# Spectrum data
char	ans[2*SZ_LINE,4]	# Answer strings
int	nans			# Number of answer strings

int	i, j, i1, npts, nlines, maxlines, wc, key, op
real	w, wxc, wyc, wx, wy, wx2, wy2, a[14], waves[4]
real	slope, height, flux, cont, sigma, eqw, scale, chisq
bool	fit
pointer	sp, cmd, x, y, z

int	clgcur(), clgkey()
real	clgetr(), model()
errchk	dofit

define	done_	99

begin
	call smark (sp)
	call salloc (cmd, SZ_FNAME, TY_CHAR)

	# Input cursor is first continuum point now get second continuum point.
	call printf ("d again:")
	if (clgcur ("cursor", wx2, wy2, wc, key, Memc[cmd], SZ_FNAME) == EOF) {
	    call sfree (sp)
	    return
	}

	# Set pixel indices and determine number of points to fit.
	call fixx (wx1, wx2, wy1, wy2, x1, x2)
	call pixind (x1, x2, dx, wx1, i1)
	call pixind (x1, x2, dx, wx2, j)
	npts = j - i1 + 1
	if (npts < 3) {
	    call eprintf ("At least 3 points are required\n")
	    call sfree (sp)
	    return
	}

	# Allocate space for the points to be fit.
	call salloc (x, npts, TY_REAL)
	call salloc (y, npts, TY_REAL)
	call salloc (z, npts, TY_REAL)

	# Subtract the continuum and scale the data.
	wxc = wx1
	wyc = wy1
	slope = (wy2-wy1) / (wx2-wx1)
	scale = 0.
	do i = 1, npts {
	    w = x1 + (i1+i-2) * dx
	    Memr[y+i-1] = pix[i1+i-1] - (wyc + slope * (w-wxc))
	    scale = max (scale, abs (Memr[y+i-1]))
	    Memr[x+i-1] = w
	}
	call adivkr (Memr[y], scale, Memr[y], npts)

	# Select the lines to be fit.  If no lines return.
	maxlines = 4
	nlines = 0
	call printf ("Lines ('m' to mark, 't' to type, 'q' to quit):")
	while (clgcur ("cursor", wx, wy, wc, key, Memc[cmd], SZ_FNAME) != EOF) {
	    switch (key) {
	    case 'm':
	    case 't':
		wx = clgetr ("wavelength")
		call printf (
		    "Lines ('m' to mark, 't' to type, 'q' to quit):")
	    case 'q':
		call printf ("\n")
		break
	    case 'I':
		call fatal (0, "Interrupt")
	    default:
		call printf (
		    "Lines ('m' to mark, 't' to type, 'q' to quit):\007")
		next
	    }
	    for (i = 1; i <= nlines && wx != waves[i]; i = i + 1)
		;
	    if (i > nlines) {
	        nlines = nlines + 1
		waves[nlines] = wx
		call gmark (gfd, wx, wy, GM_VLINE, 3., 3.)
	    }
	    if (nlines == maxlines) {
	        call printf ("\n")
		break
	    }
	}
	if (nlines == 0)
	    goto done_

	# Do fits.
	fit = false
	call printf (OP)
	while (clgcur ("cursor", wx, wy, wc, op, Memc[cmd], SZ_FNAME) != EOF) {
	    switch (op) {
	    case '?':
		    call gpagefile (gfd, HELP, "Splot Deblending Options")
		    call printf (OP)
		    next
	    case 'a', 'b', 'c', 'd', 'e', 'f':
	    case 'q':
		call printf ("\n")
		break
	    case 'I':
		call fatal (0, "Interrupt")
	    default:
		call printf ("%s\007")
		    call pargstr (OP)
		next
	    }

	    # Convert line postions to relative to first line.
	    a[1] = waves[1]
	    a[2] = 0.25 * abs (Memr[x+npts-1] - Memr[x]) / nlines
	    do i = 1, nlines {
	        call pixind (x1, x2, dx, waves[i], j)
	        a[3*i] = (pix[j] - (wyc + slope * (waves[i]-wxc))) / scale
	        a[3*i+1] = waves[i] - waves[1]
	        a[3*i+2] = 1.
	    }

	    switch (op) {
	    case 'a':
		iferr {
	            call dofit ('a', Memr[x], Memr[y], npts, a, nlines, chisq)
	            call dofit ('a', Memr[x], Memr[y], npts, a, nlines, chisq)
		} then {
	            call erract (EA_WARN)
	            next
		}
	    case 'b':
		iferr {
	            call dofit ('a', Memr[x], Memr[y], npts, a, nlines, chisq)
	            call dofit ('b', Memr[x], Memr[y], npts, a, nlines, chisq)
		} then {
	            call erract (EA_WARN)
	            next
		}
	    case 'c':
		iferr {
	            call dofit ('a', Memr[x], Memr[y], npts, a, nlines, chisq)
	            call dofit ('b', Memr[x], Memr[y], npts, a, nlines, chisq)
	            call dofit ('c', Memr[x], Memr[y], npts, a, nlines, chisq)
		} then {
	            call erract (EA_WARN)
	            next
		}
	    case 'd':
		iferr {
	            call dofit ('a', Memr[x], Memr[y], npts, a, nlines, chisq)
	            call dofit ('d', Memr[x], Memr[y], npts, a, nlines, chisq)
		} then {
	            call erract (EA_WARN)
	            next
		}
	    case 'e':
		iferr {
	            call dofit ('a', Memr[x], Memr[y], npts, a, nlines, chisq)
	            call dofit ('b', Memr[x], Memr[y], npts, a, nlines, chisq)
	            call dofit ('e', Memr[x], Memr[y], npts, a, nlines, chisq)
		} then {
	            call erract (EA_WARN)
	            next
		}
	    case 'f':
		iferr {
		    call dofit ('a', Memr[x], Memr[y], npts, a, nlines, chisq)
		    call dofit ('b', Memr[x], Memr[y], npts, a, nlines, chisq)
		    call dofit ('c', Memr[x], Memr[y], npts, a, nlines, chisq)
		    call dofit ('f', Memr[x], Memr[y], npts, a, nlines, chisq)
		} then {
	            call erract (EA_WARN)
	            next
		}
	    }

	    # Compute model spectrum with continuum and plot.
	    fit = true
	    do i = 1, npts {
	        w = x1 + (i1+i-2) * dx
	        Memr[z+i-1] = model (w, a, 3*nlines+2)
	        Memr[z+i-1] = scale*Memr[z+i-1] + (wyc+slope*(w-wxc))
	    }

	    call gvline (gfd, Memr[z], npts, wx1, wx2)
	    call gline (gfd, wx1, wy1, wx2, wy2)
	    call gflush (gfd)

	    # Print computed values on status line.
	    i = 1
	    key = ''
	    repeat {
	        switch (key) {
	        case '-':
		    i = i - 1
		    if (i < 1)
		        i = nlines
	        case '+':
		    i = i + 1
		    if (i > nlines)
		        i = 1
	        case 'q':
		    call printf ("\n")
		    break
	        }

	        height = scale * a[3*i]
	        w = a[1] + a[3*i+1]
	        sigma = abs (a[2]*a[3*i+2])
	        flux = sigma * height * SQ2PI
	        cont = wyc + slope * (w - wxc)
	        if (cont > 0.)
		    eqw = abs (flux) / cont
	        else
		    eqw = INDEF

		if (key == 'r') {
		    call printf ("\nrms = %8.4g")
			call pargr (scale * sqrt (chisq / npts))
		} else {
	            call printf (
	        "\n%d: center = %8.6g, flux = %8.4g, eqw = %6.4g, fwhm = %6.4g")
			call pargi (i)
	                call pargr (w)
	                call pargr (flux)
	                call pargr (eqw)
	                call pargr (2.355 * sigma)
		}

	        call printf ("  (+,-,r,q):")
	        call flush (STDOUT)
	    } until (clgkey ("ukey", key, Memc[cmd], SZ_FNAME) == EOF)

	    # Log computed values
	    nans = nlines
	    do i = 1, nlines {
	        w = a[1] + a[3*i+1]
	        cont = wyc + slope * (w - wxc)
	        height = scale * a[3*i]
	        sigma = abs (a[2]*a[3*i+2])
	        flux = sigma * height * SQ2PI
	        if (cont > 0.)
		    eqw = abs (flux) / cont
	        else
		    eqw = INDEF

		call sprintf (ans[1,i], 2*SZ_LINE,
		    " %9.7g %9.7g %9.6g %9.4g %9.6g %9.4g %9.4g\n")
		    call pargr (w)
		    call pargr (cont)
		    call pargr (flux)
		    call pargr (eqw)
		    call pargr (height)
		    call pargr (sigma)
		    call pargr (2.355 * sigma)
	    }
	    call printf (OP)
	}


done_	call sfree (sp)
	return


# SUBBLEND -- Subtract last fit.

entry subblend (gfd, pix, x1, x2, dx, wx1, wy1)

	call smark (sp)
	call salloc (cmd, SZ_FNAME, TY_CHAR)

	# Subtract continuum subtracted curve from spectrum
	if (!fit) {
	    call sfree (sp)
	    return
	}

	# Determine fit range
	call printf ("- again:")
	call flush (STDOUT)
	if (clgcur ("cursor", wx2, wy2, wc, key, Memc[cmd], SZ_FNAME) == EOF) {
	    call sfree (sp)
	    return
	}

	call fixx (wx1, wx2, wy1, wy2, x1, x2)
	call pixind (x1, x2, dx, wx1, i1)
	call pixind (x1, x2, dx, wx2, j)
	npts = j - i1 + 1

	do i = 1, npts {
	    w = x1 + (i1+i-2) * dx
	    pix[i1+i-1] = pix[i1+i-1] - scale * model (w, a, 3*nlines+2)
	}

	# Plot subtracted curve
	call gvline (gfd, pix[i1], npts, wx1, wx2)
	call gflush (gfd)

	fit = false
	call sfree (sp)
end



# DOFIT -- Perform nonlinear iterative fit for the specified parameters.
# This uses the Levenberg-Marquardt method from NUMERICAL RECIPES.

procedure dofit (key, x, y, npts, a, nlines, chisq)

int	key		# Fitting option
real	x[npts]		# X data
real	y[npts]		# Y data
int	npts		# Number of points
real	a[ARB]		# Fitting parameters
int	nlines		# Number of lines
real	chisq		# Chi squared

int	i, np, nfit
real	mr, chi2
pointer	sp, flags
errchk	mr_solve

begin
	# Number of terms is 3 for each line plus common center and sigma.
	np = 3 * nlines + 2

	call smark (sp)
	call salloc (flags, np, TY_INT)

	# Peaks are always fit.
	switch (key) {
	case 'a': # Solve one sigma.
	    nfit = 1 + nlines
	    Memi[flags] = 2
	    do i = 1, nlines
	        Memi[flags+i] = 3 * i
	case 'b': # Solve one position and one sigma.
	    nfit = 2 + nlines
	    Memi[flags] = 1
	    Memi[flags+1] = 2
	    do i = 1, nlines
	        Memi[flags+1+i] = 3 * i
	case 'c': # Solve independent positions and one sigma.
	    nfit = 1 + 2 * nlines
	    Memi[flags] = 2
	    do i = 1, nlines {
	        Memi[flags+2*i-1] = 3 * i
	        Memi[flags+2*i] = 3 * i + 1
	    }
	case 'd': # Solve for sigmas.
	    nfit = 2 * nlines
	    do i = 1, nlines {
	        Memi[flags+2*i-2] = 3 * i
	        Memi[flags+2*i-1] = 3 * i + 2
	    }
	case 'e': # Solve for one position and sigmas.
	    nfit = 1 + 2 * nlines
	    Memi[flags] = 1
	    do i = 1, nlines {
	        Memi[flags+2*i-1] = 3 * i
	        Memi[flags+2*i] = 3 * i + 2
	    }
	case 'f': # Solve for positions and sigmas.
	    nfit = 3 * nlines
	    do i = 1, nfit
	        Memi[flags+i-1] = i + 2
	}


	mr = -1.
	i = 0
	chi2 = MAX_REAL
	repeat {
	    call mr_solve (x, y, npts, a, Memi[flags], np, nfit, mr, chisq)
	    if (chi2 - chisq > 1.)
		i = 0
	    else
		i = i + 1
	    chi2 = chisq
	} until (i == 3)

	mr = 0.
	call mr_solve (x, y, npts, a, Memi[flags], np, nfit, mr, chisq)

	call sfree (sp)
end


# MODEL -- Compute model from fitted parameters.
#
#	I(x) = I(i) exp {[(x - xc - dx(i)) / (sig sig(i))] ** 2 / 2.}
#
# where the parameters are xc, sig, I(i), dx(i), and sig(i) (i=1,nlines).

real procedure model (x, a, na)

real	x		# X value to be evaluated
real	a[na]		# Parameters
int	na		# Number of parameters

int	i
real	y, arg

begin
	y = 0.
	do i = 3, na, 3 {
	    arg = (x - a[1] - a[i+1]) / (a[2] * a[i+2])
	    if (abs (arg) < 7.)
		y = y + a[i] * exp (-arg**2 / 2.)
	}
	return (y)
end


# DERIVS -- Compute model and derivatives for MR_SOLVE procedure.
#
#	I(x) = I(i) exp {[(x - xc - dx(i)) / (sig sig(i))] ** 2 / 2.}
#
# where the parameters are xc, sig, I(i), dx(i), and sig(i) (i=1,nlines).

procedure derivs (x, a, y, dyda, na)

real	x		# X value to be evaluated
real	a[na]		# Parameters
real	y		# Function value
real	dyda[na]	# Derivatives
int	na		# Number of parameters

int	i
real	sig, arg, ex, fac

begin
	y = 0.
	dyda[1] = 0.
	dyda[2] = 0.
	do i = 3, na, 3 {
	    sig = a[2] * a[i+2]
	    arg = (x - a[1] - a[i+1]) / sig
	    if (abs (arg) < 7.)
	        ex = exp (-arg**2 / 2.)
	    else
		ex = 0.
	    fac = a[i] * ex * arg

	    y = y + a[i] * ex
	    dyda[1] = dyda[1] + fac / sig
	    dyda[2] = dyda[2] + fac * arg / a[2]
	    dyda[i] = ex
	    dyda[i+1] = fac / sig
	    dyda[i+2] = fac * arg / a[i+2]
	}
end


# MR_SOLVE -- Levenberg-Marquardt nonlinear chi square minimization.
#
# Use the Levenberg-Marquardt method to minimize the chi squared of a set
# of paraemters.  The parameters being fit are indexed by the flag array.
# To initialize the Marquardt parameter, MR, is less than zero.  After that
# the parameter is adjusted as needed.  To finish set the parameter to zero
# to free memory.  This procedure requires a subroutine, DERIVS, which
# takes the derivatives of the function being fit with respect to the
# parameters.  There is no limitation on the number of parameters or
# data points.  For a description of the method see NUMERICAL RECIPES
# by Press, Flannery, Teukolsky, and Vetterling, p523.

procedure mr_solve (x, y, npts, params, flags, np, nfit, mr, chisq)

real	x[npts]			# X data array
real	y[npts]			# Y data array
int	npts			# Number of data points
real	params[np]		# Parameter array
int	flags[np]		# Flag array indexing parameters to fit
int	np			# Number of parameters
int	nfit			# Number of parameters to fit
real	mr			# MR parameter
real	chisq			# Chi square of fit

int	i
real	chisq1
pointer	new, a1, a2, delta1, delta2

errchk	mr_invert

begin
	# Allocate memory and initialize.
	if (mr < 0.) {
	    call mfree (new, TY_REAL)
	    call mfree (a1, TY_REAL)
	    call mfree (a2, TY_REAL)
	    call mfree (delta1, TY_REAL)
	    call mfree (delta2, TY_REAL)

	    call malloc (new, np, TY_REAL)
	    call malloc (a1, nfit*nfit, TY_REAL)
	    call malloc (a2, nfit*nfit, TY_REAL)
	    call malloc (delta1, nfit, TY_REAL)
	    call malloc (delta2, nfit, TY_REAL)

	    call amovr (params, Memr[new], np)
	    call mr_eval (x, y, npts, Memr[new], flags, np, Memr[a2],
	        Memr[delta2], nfit, chisq)
	    mr = 0.001
	}

	# Restore last good fit and apply the Marquardt parameter.
	call amovr (Memr[a2], Memr[a1], nfit * nfit)
	call amovr (Memr[delta2], Memr[delta1], nfit)
	do i = 1, nfit
	    Memr[a1+(i-1)*(nfit+1)] = Memr[a2+(i-1)*(nfit+1)] * (1. + mr)

	# Matrix solution.
	call mr_invert (Memr[a1], Memr[delta1], nfit)

	# Compute the new values and curvature matrix.
	do i = 1, nfit
	    Memr[new+flags[i]-1] = params[flags[i]] + Memr[delta1+i-1]
	call mr_eval (x, y, npts, Memr[new], flags, np, Memr[a1],
	    Memr[delta1], nfit, chisq1)

	# Check if chisq has improved.
	if (chisq1 < chisq) {
	    mr = 0.1 * mr
	    chisq = chisq1
	    call amovr (Memr[a1], Memr[a2], nfit * nfit)
	    call amovr (Memr[delta1], Memr[delta2], nfit)
	    call amovr (Memr[new], params, np)
	} else
	    mr = 10. * mr

	if (mr == 0.) {
	    call mfree (new, TY_REAL)
	    call mfree (a1,  TY_REAL)
	    call mfree (a2,  TY_REAL)
	    call mfree (delta1, TY_REAL)
	    call mfree (delta2, TY_REAL)
	}
end


# MR_EVAL -- Evaluate curvature matrix.  This calls procedure DERIVS.

procedure mr_eval (x, y, npts, params, flags, np, a, delta, nfit, chisq)

real	x[npts]			# X data array
real	y[npts]			# Y data array
int	npts			# Number of data points
real	params[np]		# Parameter array
int	flags[np]		# Flag array indexing parameters to fit
int	np			# Number of parameters
real	a[nfit,nfit]		# Curvature matrix
real	delta[nfit]		# Delta array
int	nfit			# Number of parameters to fit
real	chisq			# Chi square of fit

int	i, j, k
real	ymod, dy, dydpj, dydpk
pointer	sp, dydp

begin
	call smark (sp)
	call salloc (dydp, np, TY_REAL)

	do j = 1, nfit {
	   do k = 1, j
	       a[j,k] = 0.
	    delta[j] = 0.
	}

	chisq = 0.
	do i = 1, npts {
	    call derivs (x[i], params, ymod, Memr[dydp], np)
	    dy = y[i] - ymod
	    do j = 1, nfit {
		dydpj = Memr[dydp+flags[j]-1]
		delta[j] = delta[j] + dy * dydpj
		do k = 1, j {
		    dydpk = Memr[dydp+flags[k]-1]
		    a[j,k] = a[j,k] + dydpj * dydpk
		}
	    }
	    chisq = chisq + dy * dy
	}

	do j = 2, nfit
	    do k = 1, j-1
		a[k,j] = a[j,k]

	call sfree (sp)
end
	    

# MR_INVERT -- Solve a set of linear equations using Householder transforms.

procedure mr_invert (a, b, n)

real	a[n,n]		# Input matrix and returned inverse
real	b[n]		# Input RHS vector and returned solution
int	n		# Dimension of input matrices

int	krank
real	rnorm
pointer	sp, h, g, ip

begin
	call smark (sp)
	call salloc (h, n, TY_REAL)
	call salloc (g, n, TY_REAL)
	call salloc (ip, n, TY_INT)

	call hfti (a, n, n, n, b, n, 1, 0.001, krank, rnorm,
	    Memr[h], Memr[g], Memi[ip])

	call sfree (sp)
end
