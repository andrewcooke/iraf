include <pkg/gtools.h>
include <gset.h>
include "../lib/apphotdef.h"
include "../lib/apphot.h"
include "../lib/noise.h"
include "../lib/centerdef.h"
include "../lib/center.h"

# APCPLOT -- Procedure to compute radial profile plots for the centering
# routine.

procedure apcplot (ap, sid, cier, gd, makeplot)

pointer	ap		# pointer to the apphot structure
int	sid		# id number of the star
int	cier		# centering error
pointer	gd		# graphics stream
int	makeplot	# make a plot

int	nx, ny
pointer	ctr, sp, str, r, gt
real	xcenter, ycenter, xc, yc, rmin, rmax, imin, imax
real	u1, u2, v1, v2, x1, x2, y1, y2
pointer	ap_gtinit()
real	apstatr()

begin
	# Initialize.
	if (gd == NULL || makeplot == NO)
	    return

	# Check for defined center.
	xcenter = apstatr (ap, XCENTER)
	ycenter = apstatr (ap, YCENTER)
	if (IS_INDEFR(xcenter) || IS_INDEFR(ycenter))
	    return

	# Get the pixel buffer parameters.
	ctr = AP_PCENTER(ap)
	nx = AP_CNX(ctr)
	ny = AP_CNY(ctr)
	xc = AP_CXC(ctr) + (xcenter - apstatr (ap, CXCUR))
	yc = AP_CYC(ctr) + (ycenter - apstatr (ap, CYCUR))

	# Allocate working space.
	call smark (sp)
	call salloc (str, SZ_LINE, TY_CHAR)
	call salloc (r, nx * ny, TY_REAL)

	# Compute the radii and the plot limits.
	call ap_ijtor2 (Memr[r], nx, ny, xc, yc)
	call alimr (Memr[r], nx * ny, rmin, rmax)
	call alimr (Memr[AP_CTRPIX(ctr)], nx * ny, imin, imax)

	# Reactivate the work station.
	call greactivate (gd, 0)

	# Save old viewport and window coordinates.
	call ggview (gd, u1, u2, v1, v2)
	call ggwind (gd, x1, x2, y1, y2)

	# Initialize the plot.
	call apstats (ap, IMNAME, Memc[str], SZ_LINE)
	call sprintf (Memc[str], SZ_LINE, "%s  Star %d")
	    call pargstr (Memc[str])
	    call pargi (sid)
	gt = ap_gtinit (Memc[str], xcenter - apstatr (ap, XSHIFT), ycenter -
	    apstatr (ap, YSHIFT))

	# Make the plot.
	call gclear (gd)
	call ap_cpset (gd, gt, ap, cier, rmin, rmax, imin, imax)
	call ap_plotrad (gd, gt, Memr[r], Memr[AP_CTRPIX(ctr)], nx * ny, "plus")
	call ap_cpreset (gd, gt, ap, rmin, rmax, imin, imax)
	call ap_cpannotate (gd, gt, ap)

	# Restore the viewport and window coordinates.
	call gsview (gd, u1, u2, v1, v2)
	call gswind (gd, x1, x2, y1, y2)

	# Free the space.
	call ap_gtfree (gt)
	call gdeactivate (gd, 0)
	call sfree (sp)
end


# AP_CPSET -- Procedure to set up the parameters for the center radial profile
# plot.

procedure ap_cpset (gd, gt, ap, cier, xmin, xmax, ymin, ymax)

pointer	gd		# graphics stream
pointer	gt		# gtools pointer
pointer	ap		# apphot pointer
int	cier		# centering error
real	xmin, xmax	# minimum and maximum radial distance
real	ymin, ymax	# min and max of x axis

int	fd
pointer	sp, str, title
real	scale, aspect, datalimit, threshold, vx1, vx2, vy1, vy2
int	stropen(), apstati()
real	apstatr(), gstatr()

begin
	call smark (sp)
	call salloc (str, SZ_LINE, TY_CHAR)
	call salloc (title, SZ_LINE, TY_CHAR)

	# Encode the parameter string.
	fd = stropen (Memc[str], SZ_LINE, WRITE_ONLY)

	call sysid (Memc[title], SZ_LINE)
	call fprintf (fd, "%s\n")
	    call pargstr (Memc[title])

	call fprintf (fd,
	    "Center: xc=%0.2f yc=%0.2f xerr=%0.2f yerr=%0.2f\n")
	    call pargr (apstatr (ap, XCENTER))
	    call pargr (apstatr (ap, YCENTER))
	    call pargr (apstatr (ap, XERR))
	    call pargr (apstatr (ap, YERR))

	call gt_gets (gt, GTTITLE, Memc[title], SZ_LINE)
	call fprintf (fd, "%s\n")
	    call pargstr (Memc[title])

	call strclose (fd)

	# Set the labels and window.
	scale = apstatr (ap, SCALE)
	aspect = gstatr (gd, G_ASPECT)
	call gsetr (gd, G_ASPECT, 0.75)
	datalimit = apstatr (ap, DATALIMIT)
	threshold = apstatr (ap, CTHRESHOLD)

	if (apstati (ap, POSITIVE) == YES) {
	    call gseti (gd, G_XDRAWAXES, 2)
	    call gswind (gd, xmin / scale, xmax / scale, datalimit + threshold,
		datalimit + threshold + ymax)
	    call glabax (gd, Memc[str], "", "Intensity")
	    call gseti (gd, G_YDRAWAXES, 0)
	    call gseti (gd, G_XDRAWAXES, 1)
	    call ggview (gd, vx1, vx2, vy1, vy2)
	    call gswind (gd, vx1, vx2, vy1, vy2)
	    call gswind (gd, xmin, xmax, datalimit + threshold,
		datalimit + threshold + ymax)
	    call glabax (gd, "",
	        "Radial Distance (lower-pixels, upper-scale units)", "")
	} else {
	    call gseti (gd, G_XDRAWAXES, 2)
	    call gswind (gd, xmin / scale, xmax / scale, datalimit -
	        threshold - ymax, datalimit - threshold)
	    call glabax (gd, Memc[str], "", "Intensity")
	    call gseti (gd, G_YDRAWAXES, 0)
	    call gseti (gd, G_XDRAWAXES, 1)
	    call ggview (gd, vx1, vx2, vy1, vy2)
	    call gswind (gd, vx1, vx2, vy1, vy2)
	    call gswind (gd,  xmin,  xmax, datalimit - threshold - ymax,
	        datalimit - threshold)
	    call glabax (gd, "",
	        "Radial Distance (lower-pixels, upper-scale units)", "")
	}

	call gseti (gd, G_YDRAWAXES, 3)
	call gseti (gd, G_XDRAWAXES, 3)
	call gsetr (gd, G_ASPECT, aspect)
	call gt_sets (gt, GTTYPE, "mark")

	call sfree (sp)
end


# AP_CPANNOTATE -- Procedure to annotate the radial plot in center.

procedure ap_cpannotate (gd, gt, ap)

pointer	gd		# graphics stream
pointer	gt		# gtools stream
pointer	ap		# apphot structure

pointer	sp, str
real	fwhmpsf, capert, datalimit, threshold, sigma
real	xmin, xmax, ymin, ymax
int	apstati()
real	apstatr()

begin
	call smark (sp)
	call salloc (str, SZ_LINE, TY_CHAR)
	call gseti (gd, G_PLTYPE, GL_DASHED)
	call ggwind (gd, xmin, xmax, ymin, ymax)

	fwhmpsf = 0.5 * apstatr (ap, FWHMPSF) * apstatr (ap, SCALE)
	capert = 2.0 * fwhmpsf * apstatr (ap, CAPERT)
	datalimit = apstatr (ap, DATALIMIT)
	threshold = apstatr (ap, CTHRESHOLD)
	if (apstati (ap, POSITIVE) == YES)
	    threshold = datalimit + threshold
	else
	    threshold = datalimit - threshold

	# Plot the full width half maximum of the radial profile.
	if (fwhmpsf >= xmin && fwhmpsf <= xmax) {
	    call gamove (gd, fwhmpsf, ymin)
	    call gadraw (gd, fwhmpsf, ymax)
	    call sprintf (Memc[str], SZ_LINE, "hwhm = %0.2f")
	        call pargr (fwhmpsf)
	    call gtext (gd, fwhmpsf, ymax, Memc[str], "q=h;u=180;v=t;p=r")
	}

	# Mark the centering aperture.
	if (capert >= xmin && capert <= xmax) {
	    call gamove (gd, capert, ymin)
	    call gadraw (gd, capert, ymax)
	    call sprintf (Memc[str], SZ_LINE, "cbox half-width = %0.2f")
	        call pargr (capert)
	    call gtext (gd, capert, ymax, Memc[str], "q=h;u=180;v=t;p=r")
	}

	# Mark the threshold level for centering.
        call sprintf (Memc[str], SZ_LINE, "threshold = %g")
	    call pargr (threshold)
	call gtext (gd, xmin, ymin, Memc[str], "q=h")

	# Mark the sky sigma if defined.
	sigma = apstatr (ap, SKYSIGMA)
	if (! IS_INDEFR(sigma) && sigma >= ymin && sigma <= ymax) {
	    call gmark (gd, (xmin + xmax) / 2.0, (ymin + ymax) / 2.0, 
		GM_VEBAR, -0.25, -sigma)
	    call sprintf (Memc[str], SZ_LINE, "sigma = %g")
		call pargr (sigma)
	    call gtext (gd, (xmin + xmax) / 2.0, (ymin + ymax + sigma) / 2.0,
		Memc[str], "q=h;h=c")
	}

	call sfree (sp)
end


# AP_CPRSET -- Procedure to reset the plot window after the data points
# have been plotted.

procedure ap_cpreset (gd, gt, ap, xmin, xmax, ymin, ymax)

pointer	gd		# graphics stream
pointer	gt		# gtools pointer
pointer	ap		# apphot pointer
real	xmin, xmax	# minimum and maximum radial distance
real	ymin, ymax	# min and max of x axis

real	threshold, datalimit
int	apstati()
real	apstatr()

begin
	# Set the data window.
	datalimit = apstatr (ap, DATALIMIT)
	threshold = apstatr (ap, CTHRESHOLD)
	call gt_setr (gt, GTXMIN, xmin)
	call gt_setr (gt, GTXMAX, xmax)
	if (apstati (ap, POSITIVE) == YES) {
	    call gt_setr (gt, GTYMIN, datalimit + threshold)
	    call gt_setr (gt, GTYMAX, ymax + datalimit + threshold)
	} else {
	    call gt_setr (gt, GTYMIN, datalimit - ymax - threshold)
	    call gt_setr (gt, GTYMAX, datalimit - threshold)
	}
	call gt_swind (gd, gt)
end
