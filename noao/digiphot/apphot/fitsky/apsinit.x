include "../lib/apphotdef.h"
include "../lib/fitskydef.h"
include "../lib/fitsky.h"

# APSINIT - Procedure to initialize the sky fitting structure and parameters.

procedure apsinit (ap, function, annulus, dannulus, fwhmpsf, noise)

pointer	ap		# pointer to the apphot structure
int	function	# sky fitting algorithm
real	annulus		# radius of sky annulus
real	dannulus	# width of sky annulus
real	fwhmpsf		# FWHM of the PSF
int	noise		# noise function

begin
	# Set up the object parameters.
	call malloc (ap, LEN_APSTRUCT, TY_STRUCT)
	AP_IMNAME(ap) = EOS
	AP_CWX(ap) = INDEFR
	AP_CWY(ap) = INDEFR
	AP_WX(ap) = INDEFR
	AP_WY(ap) = INDEFR
	AP_FWHMPSF(ap) = fwhmpsf
	AP_SCALE(ap) = DEF_SCALE
	AP_POSITIVE(ap) = DEF_POSITIVE
	AP_EXPOSURE(ap) = EOS
	AP_DATAMIN(ap) = INDEFR
	AP_DATAMAX(ap) = INDEFR
	AP_ITIME(ap) = DEF_ITIME

	# Set up the noise model parameters.
	call ap_noisesetup (ap, noise)

	# Set up the display options.
	call ap_dispsetup (ap)

	# Initialize the sky fitting parameters.
	call ap_skysetup (ap, function, annulus, dannulus)

	# Unused structures are set to null.
	AP_PCENTER(ap) = NULL
	AP_PPHOT(ap) = NULL
	AP_POLY(ap) = NULL
	AP_PPSF(ap) = NULL
	AP_RPROF(ap) = NULL
end


# AP_SKYSETUP -- Procedure to set up the sky fitting arrays and parameters.

procedure ap_skysetup (ap, function, annulus, dannulus)

pointer	ap		# pointer to apphot structure
int	function	# sky fitting function
real	annulus		# inner radius of sky annulus
real	dannulus	# outer radius of sky annulus

pointer	sky

begin
	call malloc (AP_PSKY(ap), LEN_SKYSTRUCT, TY_STRUCT)
	sky = AP_PSKY(ap)
	AP_SXCUR(sky) = INDEFR
	AP_SYCUR(sky) = INDEFR

	# Initialize the sky fitting parameters.
	AP_SKYFUNCTION(sky) = function
	switch (function) {
	case AP_CONSTANT:
	    call strcpy ("constant", AP_SSTRING(sky), SZ_FNAME)
	case AP_MODE:
	    call strcpy ("mode", AP_SSTRING(sky), SZ_FNAME)
	case AP_CENTROID:
	    call strcpy ("centroid", AP_SSTRING(sky), SZ_FNAME)
	case AP_SKYFILE:
	    call strcpy ("file", AP_SSTRING(sky), SZ_FNAME)
	case AP_HISTPLOT:
	    call strcpy ("histplot", AP_SSTRING(sky), SZ_FNAME)
	case AP_RADPLOT:
	    call strcpy ("radplot", AP_SSTRING(sky), SZ_FNAME)
	case AP_MEDIAN:
	    call pargstr ("median", AP_SSTRING(sky), SZ_FNAME)
	case AP_GAUSS:
	    call strcpy ("gauss", AP_SSTRING(sky), SZ_FNAME)
	case AP_OFILT:
	    call strcpy ("ofilt", AP_SSTRING(sky), SZ_FNAME)
	case AP_CROSSCOR:
	    call strcpy ("crosscor", AP_SSTRING(sky), SZ_FNAME)
	default:
	    AP_SKYFUNCTION(sky) = DEF_SKYFUNCTION
	    call strcpy ("mode", AP_SSTRING(sky), SZ_FNAME)
	}

	AP_ANNULUS(sky) = annulus
	AP_DANNULUS(sky) = dannulus
	AP_K1(sky) = DEF_K1
	AP_K2(sky) = DEF_K2
	AP_SMAXITER(sky) = DEF_SMAXITER
	AP_BINSIZE(sky) = DEF_BINSIZE
	AP_SMOOTH(sky) = DEF_SMOOTH
	AP_RGROW(sky) = DEF_RGROW
	AP_SKYBACKGROUND(sky) = DEF_SKYVALUE
	AP_SNREJECT(sky) = DEF_SNREJECT

	# Initialize the sky pixel buffers.
	AP_LENSKYBUF(sky) = 0
	AP_NSKYPIX(sky) = 0
	AP_SKYPIX(sky) = NULL
	AP_INDEX(sky) = NULL
	AP_COORDS(sky) = NULL

	# Initialize results parameters.
	AP_SKY_MODE(sky) = INDEFR
	AP_SKY_SIG(sky) = INDEFR
	AP_SKY_SKEW(sky) = INDEFR
	AP_NSKY(sky) = 0
	AP_NSKY_REJECT(sky) = 0
end
