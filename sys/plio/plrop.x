# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<syserr.h>
include <plset.h>
include	<plio.h>

# PL_ROP -- Perform a rasterop operation from the source mask to the
# destination mask at the given offsets.  The source and destination need
# not be the same size or dimensionality, but out of bounds references are
# not permitted.  If the source is of lesser dimensionality than the
# indicated section of the destination, then the source will be rewound
# and reread as necessary to operate upon the entire destination subregion,
# e.g., a line source mask may be applied to successive lines of a plane,
# or a plane mask may be applied to successive planes of a 3D mask.
# The source and destination masks may be the same if desired, but if the 
# source and destination regions overlap feedback may occur (this could be
# fixed).  With some rasterops, e.g, PIX_SET or PIX_CLR, no source mask is
# required, and pl_src=NULL is permitted.

procedure pl_rop (pl_src, vs_src, pl_dst, vs_dst, vn, rop)

pointer	pl_src			#I source mask or NULL
long	vs_src[PL_MAXDIM]	#I start vector in source mask
pointer	pl_dst			#I destination mask (required)
long	vs_dst[PL_MAXDIM]	#I start vector in destination mask
long	vn[PL_MAXDIM]		#I vector giving subregion size
long	rop			#I rasterop

bool	need_src
pointer	sp, ll_out, ll_src, ll_dst, ol_src, ol_dst
long	v_src[PL_MAXDIM], v_dst[PL_MAXDIM]
long	ve_src[PL_MAXDIM], ve_dst[PL_MAXDIM]

int	plloop(), pl_access()
errchk	syserr, plvalid, plsslv, pl_access

begin
	call plvalid (pl_dst)
	need_src = R_NEED_SRC(rop)
	if (need_src && pl_src == NULL)
	    call syserr (SYS_PLNULLSRC)

	call smark (sp)
	call salloc (ll_out, LL_MAXLEN(pl_dst), TY_SHORT)

	# Initialize the N-dimensional loop counters.
	call plsslv (pl_dst, vs_dst, vn, v_dst, ve_dst)
	if (need_src)
	    call plsslv (pl_src, vs_src, vn, v_src, ve_src)
	else
	    ll_src = ll_out	# any valid pointer will do

	# Perform the operation.
	ol_dst = -1
	repeat {
	    # Get a line from each mask.  The DST linelist is required,
	    # even if R_NEED_DST(rop) is false, because the DST size
	    # parameters determine the size of the output list, and the
	    # rop may only apply to a portion of the DST list.

	    ll_dst = Ref (pl_dst, pl_access(pl_dst,v_dst))
	    if (need_src)
		ll_src = Ref (pl_src, pl_access(pl_src,v_src))

	    # Perform the rasterop operation upon one line of the mask.
	    # Note that if successive mask lines point to the same encoded
	    # line list, we only have to compute the result once.

	    if (ll_src != ol_src || ll_dst != ol_dst) {
		call pl_linerop (Mems[ll_src], vs_src[1], PL_MAXVAL(pl_src),
				 Mems[ll_dst], vs_dst[1], PL_MAXVAL(pl_dst),
				 Mems[ll_out], vn[1], rop)
		ol_src = ll_src
		ol_dst = ll_dst
	    }

	    # Update the affected line of the destination mask.
	    call pl_update (pl_dst, v_dst, Mems[ll_out])

	    # If the end of the input mask is reached, rewind it and go again.
	    if (need_src)
		if (plloop (v_src,vs_src,ve_src,PL_NAXES(pl_src)) == LOOP_DONE)
		    call amovi (vs_src, v_src, PL_NAXES(pl_src))

	} until (plloop (v_dst, vs_dst, ve_dst, PL_NAXES(pl_dst)) == LOOP_DONE)

	# Compress the mask if excessive free space has accumulated.
	if (PL_NEEDCOMPRESS(pl_dst))
	    call pl_compress (pl_dst)

	call sfree (sp)
end
