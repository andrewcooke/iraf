include "../lib/daophotdef.h"
include "../lib/psfdef.h"

# DP_PLOTPSF -- Plot the psf using the default plot type. 

procedure dp_plotpsf (dao, subrast, ncols, nlines, x1, y1, gd)

pointer	dao			# pointer to the daophot structure
real	subrast[ncols,nlines]	# image subraster
int	ncols, nlines		# dimensions of the subraster
int	x1, y1			# coordinates of the lower left corner
pointer	gd			# pointer to the graphics stream

pointer	sp, title
int	dp_pstati()
real	dp_pstatr()

begin
	# Return if the graphics stream is undefined.
	if (gd == NULL)
	    return

	# Construct the title.
	call smark (sp)
	call salloc (title, SZ_LINE, TY_CHAR)
	call sprintf (Memc[title], SZ_LINE, "Star: %d  X: %g  Y: %g  Mag: %g")
	    call pargi (dp_pstati (dao, CUR_PSFID))
	    call pargr (dp_pstatr (dao, CUR_PSFX))
	    call pargr (dp_pstatr (dao, CUR_PSFY))
	    call pargr (dp_pstatr (dao, CUR_PSFMAG))

	# Initialize plot.
	if (dp_pstati (dao, PLOTTYPE) == PSF_MESHPLOT)
	    call dp_surfpsf (dao, subrast, ncols, nlines, Memc[title], gd)
	else if (dp_pstati (dao, PLOTTYPE) == PSF_CONTOURPLOT)
	    call dp_contpsf (dao, subrast, ncols, nlines, Memc[title], gd)
	else if (dp_pstati (dao, PLOTTYPE) == PSF_RADIALPLOT)
	    call dp_radpsf (dao, subrast, ncols, nlines, x1, y1,
	        Memc[title], gd)

	call gdeactivate (gd, 0)
	call sfree (sp)
end
