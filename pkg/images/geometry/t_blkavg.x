# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<imhdr.h>

define	OPTIONS		"|average|sum|"		# Values of task param options
define	AVG		1			# Arithmetic average in block
define	SUM		2			# Sum of pixels within block
define	DEF_BLKFAC	1			# Default blocking factor

# T_BLKAVG -- Block average or sum on n-dimensional images.
#
# The input and output images are given by image template lists.  The
# number of output images must match the number of input images.  Image
# sections are allowed in the input images and are ignored in the output
# images.  If the input and output image names are the same then the
# blocking operation is performed to a temporary file which then replaces
# the input image.

procedure t_blkavg()

char	imtlist1[SZ_LINE]			# Input image list
char	imtlist2[SZ_LINE]			# Output image list
int	option					# Type of operation
int	blkfac[IM_MAXDIM]			# Block sizes

char	image1[SZ_FNAME]			# Input image name
char	image2[SZ_FNAME]			# Output image name
char	imtemp[SZ_FNAME]			# Temporary file

int	list1, list2, i
pointer	im1, im2

int	imtopen(), imtgetim(), imtlen(), clgeti(), clgwrd()
pointer	immap()

string	blk_param	"bX"

begin
	# Get input and output image template lists and the block sizes.

	call clgstr ("input", imtlist1, SZ_LINE)
	call clgstr ("output", imtlist2, SZ_LINE)
	option = clgwrd ("option", image1, SZ_FNAME, OPTIONS)
	call amovki (INDEFI, blkfac, IM_MAXDIM)

	# Expand the input and output image lists.

	list1 = imtopen (imtlist1)
	list2 = imtopen (imtlist2)

	if (imtlen (list1) != imtlen (list2)) {
	    call imtclose (list1)
	    call imtclose (list2)
	    call error (0, "Number of input and output images not the same")
	}

	# Do each set of input/output images.

	while ((imtgetim (list1, image1, SZ_FNAME) != EOF) &&
	    (imtgetim (list2, image2, SZ_FNAME) != EOF)) {

	    call xt_mkimtemp (image1, image2, imtemp, SZ_FNAME)

	    im1 = immap (image1, READ_ONLY, 0)
	    im2 = immap (image2, NEW_COPY, im1)

	    do i = 1, IM_NDIM(im1) {
		if (IS_INDEFI(blkfac[i])) {
		    call sprintf (blk_param[2], SZ_CHAR, "%1d")
			call pargi (i)
		    blkfac[i] = max (1, min (clgeti (blk_param),
		        IM_LEN(im1, i)))
		}
	    }

	    # Perform the block operation.
	    switch (IM_PIXTYPE (im1)) {
	    case TY_SHORT, TY_INT, TY_LONG:
		call blkavl (im1, im2, blkfac, option)
	    case TY_DOUBLE:
		call blkavd (im1, im2, blkfac, option)
	    default:
		call blkavr (im1, im2, blkfac, option)
	    }

	    call imunmap (im2)
	    call imunmap (im1)

	    call xt_delimtemp (image2, imtemp)
	}

	call imtclose (list1)
	call imtclose (list2)
end
