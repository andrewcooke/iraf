# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<error.h>
include	<imhdr.h>
include	<imio.h>
include	"stf.h"

# STF_OPEN -- Open/create an STF group format image.

procedure stf_open (im, o_im,
	root, extn, ksection, gr_arg, gc_arg, acmode, status)

pointer	im			# image descriptor
pointer	o_im			# other descriptor for NEW_COPY image
char	root[ARB]		# root image name
char	extn[ARB]		# extension, if any
char	ksection[ARB]		# NOT USED
int	gr_arg			# index of group to be accessed
int	gc_arg			# number of groups in STF image
int	acmode			# access mode
int	status

pointer	sp, fname, stf, stf_extn, ua
bool	fnullfile()
int	group, gcount, hmode, sz_gpbhdr, newimage
int	open()
errchk	fmkcopy
define	err_ 91

begin
	call smark (sp)
	call salloc (fname, SZ_PATHNAME, TY_CHAR)
	call salloc (stf_extn, MAX_LENEXTN, TY_CHAR)

	ua = IM_USERAREA(im)

	# Allocate internal STF image descriptor.
	call calloc (stf, LEN_STFDES, TY_STRUCT)
	IM_KDES(im) = stf

	group  = max (1, gr_arg)
	gcount = max (group, gc_arg)

	STF_GROUP(stf)  = group
	STF_GCOUNT(stf) = gcount
	STF_ACMODE(stf) = acmode
	STF_PFD(stf)    = NULL

	# If a nonzero gcount is specified when a new-image or new-copy image
	# is opened (e.g., [1/10] we assume that an entire new group format
	# image is to be created with the given group count.  If neither the
	# group or gcount values are specified we assume that a new image is
	# to be created.  If the gcount field is zero (e.g., [1/0] or just [1])
	# then we assume that the image already exists and that we are being
	# asked to rewrite the indexed image.

	newimage = NO
	if (acmode == NEW_IMAGE || acmode == NEW_COPY)
	    if (gc_arg > 0 || (gr_arg == 0 && gc_arg == 0))
		newimage= YES
	STF_NEWIMAGE(stf) = newimage

	# Generate full header file name.
	if (extn[1] == EOS) {
	    call stf_gethdrextn (Memc[stf_extn], MAX_LENEXTN)
	    call iki_mkfname (root, Memc[stf_extn], Memc[fname], SZ_PATHNAME)
	    call strcpy (Memc[stf_extn], extn, MAX_LENEXTN)
	} else
	    call iki_mkfname (root, extn, Memc[fname], SZ_PATHNAME)

	call strcpy (Memc[fname], IM_HDRFILE(im), SZ_IMHDRFILE)

	# Generate full pixel file name.
	call stf_mkpixfname (root, extn, Memc[fname], SZ_PATHNAME)
	call strcpy (Memc[fname], IM_PIXFILE(im), SZ_IMPIXFILE)

	# Open the image header file.  Since STF header files have a weird
	# VMS specific file type, we must create a new header file with
	# FMKCOPY rather than OPEN.

	if (STF_NEWIMAGE(stf) == YES && !fnullfile (IM_HDRFILE(im))) {
	    iferr (call fmkcopy (HDR_TEMPLATE, IM_HDRFILE(im)))
		goto err_
	}

	hmode = acmode
	if (acmode != READ_ONLY)
	    hmode = READ_WRITE
	iferr (IM_HFD(im) = open (IM_HDRFILE(im), hmode, TEXT_FILE))
	    goto err_

	# If opening an existing image, read the image header into the STF
	# image descriptor.

	switch (acmode) {
	case NEW_IMAGE:
	    # For group formatted images, open NEW_IMAGE can mean either
	    # creating a new group format image, or opening a new group
	    # within an existing group format image.  The latter case is
	    # indicated by a group index greater than 1.  If we are creating
	    # a new group format image, wait until the user has set up the
	    # dimension parameters before doing anything further (in stfopix).

	    if (STF_NEWIMAGE(stf) == NO)
		iferr (call stf_rdheader (im, group, acmode))
		    goto err_

	case NEW_COPY:
	    # Make sure the FITS encoded user area we inherited is blocked.

	    ### For now, always reblock the old header as the blocked flag
	    ### does not seem to be reliable and a header with variable length
	    ### lines can cause the header update to fail.  This should be
	    ### fixed as a reblock of the full header is expensive.

	    ### if (IM_UABLOCKED(o_im) != YES)
		call stf_reblock (im)

	    if (STF_NEWIMAGE(stf) == NO) {
		# Open new group within existing GF image.  The FITS header and
		# GPB structure of the image being opened must be used, but the
		# default data values for the GPB parameters are inherited from
		# the image being copied.

		sz_gpbhdr = 0
		if (IM_KDES(o_im) != NULL && IM_KERNEL(o_im) == IM_KERNEL(im)) {
		    # Truncate the copied user area after the GPB data cards.
		    sz_gpbhdr = STF_SZGPBHDR(IM_KDES(o_im))
		    Memc[ua+sz_gpbhdr] = EOS
		}

		# Read in the FITS header of the new image after the inherited
		# GPB data cards, and set up the STF descriptor for the new GPB
		# as defined in the new FITS header.

		iferr (call stf_rdheader (im, group, acmode))
		    goto err_
		else
		    STF_SZGPBHDR(stf) = sz_gpbhdr

	    } else {
		# Completely new copy of an existing image, which may or may
		# not be an STF format image.  IMIO has already copied the
		# size parameters of the old image as well as the cards in the
		# user area of the old image (but without leaving space for
		# the GPB cards if not an STF image).  Copy old STF descriptor
		# if the old image is also an STF format image, to inherit
		# GPB structure.  Wait until opix time to init the rest of the
		# descriptor.  

		if (IM_KDES(o_im) != NULL && IM_KERNEL(o_im) == IM_KERNEL(im)) {
		    call amovi (Memi[IM_KDES(o_im)], Memi[stf], LEN_STFDES)
		    STF_ACMODE(stf)   = acmode
		    STF_GROUP(stf)    = group
		    STF_GCOUNT(stf)   = gcount
		    STF_NEWIMAGE(stf) = newimage
		    STF_PFD(stf)      = NULL
		    if (gcount > 1)
			STF_GROUPS(stf) = YES
		} else
		    STF_GROUPS(stf) = YES

		# Inherit datatype of input template image if specified,
		# otherwise default datatype to real.

		if (IM_PIXTYPE(o_im) != NULL)
		    IM_PIXTYPE(im) = IM_PIXTYPE(o_im)
		else
		    IM_PIXTYPE(im) = TY_REAL
	    }

	default:
	    # Open an existing group within an existing image.
	    iferr (call stf_rdheader (im, group, acmode))
		goto err_
	}

	# Set group number and count for the external world if this is a group
	# format image.

	if (STF_GROUPS(stf) == YES) {
	    IM_CLINDEX(im) = STF_GROUP(stf)
	    IM_CLSIZE(im)  = STF_GCOUNT(stf)
	}

	call sfree (sp)
	status = OK
	return
err_
	status = ERR
	call mfree (stf, TY_STRUCT)
	call sfree (sp)
	call erract (EA_ERROR)
end
