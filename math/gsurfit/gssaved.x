# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include <math/gsurfit.h>

include "dgsurfitdef.h"

# GSSAVE -- Procedure to save the surface fit for later use by the
# evaluate routines. After a call to SIFSAVE the first six elements
# of fit contain the surface type, xorder (or number of polynomial pieces
# in x), yorder (or the number of polynomial pieces in y), xterms, ncols
# and nlines. The remaining spaces are filled by the GS_NYCOEFF(sf) *
# GS_NXCOEFF(sf) surface coefficients. The coefficient of B(i,x) * B(j,y)
# is located in element number 6 + (i - 1) * GS_NYCOEFF(sf) + j of the
# array fit where i <= GS_NXCOEFF(sf) and j <= GS_NYCOEFF(sf).

procedure dgssave (sf, fit)

pointer	sf		# pointer to the surface descriptor
double	fit[ARB]	# array for storing fit

begin
	# get the surface parameters
	if (sf == NULL)
	    return

	# order is surface type dependent
	switch (GS_TYPE(sf)) {
	case GS_LEGENDRE, GS_CHEBYSHEV, GS_POLYNOMIAL:
	    GS_SAVEXORDER(fit) = GS_XORDER(sf)
	    GS_SAVEYORDER(fit) = GS_YORDER(sf)
	default:
	    call error (0, "GSSAVE: Unknown surface type.")
	}

	# save remaining parameters
	GS_SAVETYPE(fit) = GS_TYPE(sf)
	GS_SAVEXMIN(fit) = GS_XMIN(sf)
	GS_SAVEXMAX(fit) = GS_XMAX(sf)
	GS_SAVEYMIN(fit) = GS_YMIN(sf)
	GS_SAVEYMAX(fit) = GS_YMAX(sf)
	GS_SAVEXTERMS(fit) = GS_XTERMS(sf)

	# save the coefficients
	call amovd (COEFF(GS_COEFF(sf)), fit[GS_SAVECOEFF+1], GS_NCOEFF(sf))
end
