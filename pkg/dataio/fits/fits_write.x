# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include <fset.h>
include	<error.h>
include <mach.h>
include <imhdr.h>
include "wfits.h"

# WFT_WRITE_FITZ -- Procedure to convert a single IRAF file to a FITS file.
# If the make_image switch is set the header and pixel files are output
# to the output destination. If the make_image switch is off the header
# is printed to the standard output.

procedure wft_write_fitz (iraf_file, fits_file)

char	iraf_file[SZ_FNAME]	# IRAF file name
char	fits_file[SZ_FNAME]	# FITS file name

pointer	im, sp, fits
int	fits_fd, chars_rec, dev_blk, nchars, ip

pointer	immap()
int	mtfile(), mtopen(), open(), fnldir(), fstati(), ctowrd()
errchk	immap, imunmap, open, mtopen, close, smark, salloc, sfree
errchk	delete, wft_write_header, wft_write_image, wft_data_limits
include "wfits.com"

begin
	# Open input image.
	im = immap (iraf_file, READ_ONLY, 0)

	# Allocate memory for program data structure.
	call smark (sp)
	call salloc (fits, LEN_FITS, TY_STRUCT)
	call imgcluster (iraf_file, IRAFNAME(fits), SZ_FNAME)
	nchars = fnldir (IRAFNAME(fits), IRAFNAME(fits), SZ_FNAME)
	call imgcluster (iraf_file, IRAFNAME(fits), SZ_FNAME)
	ip = nchars + 1
	if (ctowrd (IRAFNAME(fits), ip, IRAFNAME(fits), SZ_FNAME) <= 0)
	    IRAFNAME(fits) = EOS

	# Open output file.
	if (make_image == NO)
	    call strcpy ("dev$null", fits_file, SZ_FNAME)

	if (mtfile (fits_file) == YES) {
	    if (blkfac > 10)
		chars_rec = (blkfac * FITS_BYTE) / (SZB_CHAR * NBITS_BYTE)
	    else
	        chars_rec = (blkfac * len_record * FITS_BYTE) / (SZB_CHAR *
	            NBITS_BYTE)
	    fits_fd = mtopen (fits_file, WRITE_ONLY, chars_rec)
	    dev_blk = fstati (fits_fd, F_MAXBUFSIZE)
	    if (dev_blk != 0 && chars_rec > dev_blk)
		call error (0, "Blocking factor too large for tape drive")
	} else {
	    blkfac = 1
	    fits_fd = open (fits_file, NEW_FILE, BINARY_FILE)
	}

	# Write header and image.
	iferr {

	    if (short_header == YES || long_header == YES) {
	        if (make_image == YES) {
		    call printf (" -> %s ")
		        call pargstr (fits_file)
	        }
		if (long_header == YES)
		    call printf ("\n")
	    }

	    call wft_write_header (im, fits, fits_fd)

	    if (make_image == YES)
		call wft_write_image (im, fits, fits_fd)

	    if (long_header == YES)
	        call printf ("\n")

	} then {

	    # print the error message
	    call erract (EA_WARN)

	    # Close files and cleanup.
	    call imunmap (im)
	    call close (fits_fd)
	    if (make_image == NO)
	        call delete (fits_file)
	    call sfree (sp)

	    # assert an error
	    call erract (EA_ERROR)

	} else {
	    # Close files and cleanup.
	    call imunmap (im)
	    call close (fits_fd)
	    if (make_image == NO)
	        call delete (fits_file)
	    call sfree (sp)
	}

end


# WFT_DATA_LIMITS -- Procedure to calculate the maximum and minimum data values
# in an IRAF image. Values are only calculated if the max and min are unknown
# or the image has been modified since the last values were calculated.

procedure wft_data_limits (im, irafmin, irafmax)

pointer	im		# image pointer
real	irafmin		# minimum picture value
real	irafmax		# maximum picture value

pointer	buf
int	npix
long	v[IM_MAXDIM]
real	maxval, minval
int	imgnlr()
errchk	imgnlr

begin
	if (LIMTIME(im) < MTIME(im) && NAXIS(im) > 0) {
	    irafmax = -MAX_REAL
	    irafmin = MAX_REAL
	    npix = NAXISN(im,1)

	    call amovkl (long(1), v, IM_MAXDIM)
	    while (imgnlr (im, buf, v) != EOF) {
	        call alimr (Memr[buf], npix, minval, maxval)
	        irafmin = min (irafmin, minval)
	        irafmax = max (irafmax, maxval)
	    }

	} else {
	    irafmax = IM_MAX(im)
	    irafmin = IM_MIN(im)
	}
end
