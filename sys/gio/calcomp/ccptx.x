# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<math.h>
include	<gset.h>
include	<gki.h>
include	"ccp.h"

define	BASECS_X	12	# Base (size 1.0) char width in GKI coords.
define	BASECS_Y	12	# Base (size 1.0) char height in GKI coords.


# CCP_TEXT -- Draw a text string.  The string is drawn at the position (X,Y)
# using the text attributes set by the last GKI_TXSET instruction.  The text
# string to be drawn may contain embedded set font escape sequences of the
# form \fR (roman), \fG (greek), etc.  We break the input text sequence up
# into segments at font boundaries and draw these on the output device,
# setting the text size, color, font, and position at the beginning of each
# segment.

procedure ccp_text (xc, yc, text, n)

int	xc, yc			# where to draw text string
short	text[ARB]		# text string
int	n			# number of characters

real	g_dx, g_dy			# scale GKI to window coords
int	g_x1, g_y1			# origin of device window
int	g_x2, g_y2			# upper right corner of device window
real	x, y, dx, dy, tsz, xto_nicesize, yto_nicesize
int	x1, x2, y1, y2, orien
int	x0, y0, gki_dx, gki_dy, ch, cw
int	xstart, ystart, newx, newy
int	totlen, polytext, font, seglen, quality
pointer	sp, seg, ip, op, tx, first, pl
int	ccx_segment()
include	"ccp.com"

data	g_dx /1.0/, g_dy /1.0/
data	g_x1 /0/, g_y1 /0/, g_x2 /GKI_MAXNDC/, g_y2 / GKI_MAXNDC/

begin
	call smark (sp)
	call salloc (seg, n + 2, TY_CHAR)

	# Keep track of the number of drawing instructions since the last frame
	# clear.
	g_ndraw = g_ndraw + 1

	# Set pointer to the text attribute structure.
	tx = CCP_TXAP(g_cc)

	# Set the text size and color if not already set.  Both should be
	# invalidated when the screen is cleared.  Text color should be
	# invalidated whenever another color is set.  The text size was
	# set by ccp_txset, and is just a scaling factor.

	CCP_TXSIZE(g_cc) = TX_SIZE(tx)
	if (TX_COLOR(tx) != CCP_COLOR(g_cc)) {
	    call ccp_color (TX_COLOR(tx))
	    CCP_COLOR(g_cc) = TX_COLOR(tx)
	}

	# Set the character-generator quality.  Only low (Calcomp "symbol")
	# and other (ccp_font; see NSPP doc. on its font) are supported.
	if (g_txquality == 0) {
	    quality = TX_QUALITY(tx)	# param was specified "normal" to task
	} else
	    quality = g_txquality	# param was explicit to task

	# Set the linetype to a solid line, and invalidate last setting.
	call ccp_linetype (GL_SOLID)	# for use in ccp_polyline
	CCP_LTYPE(g_cc) = -1		# PL_LTYPE still contains current settng

	# Set pointer to polyline attribute structure and set line width
	# if necessary.
	pl = CCP_PLAP(g_cc)

	if (CCP_WIDTH(g_cc) != PL_WIDTH(pl)) {
	    if (GKI_UNPACKREAL(PL_WIDTH(pl)) < 1.5) {
		CCP_WIDTH(g_cc) = GKI_PACKREAL(PL_SINGLE)
	    } else
	        CCP_WIDTH(g_cc) = PL_WIDTH(pl)
	}
	# Break the text string into segments at font boundaries and count
	# the total number of printable characters.

	totlen = ccx_segment (text, n, Memc[seg], TX_FONT(tx))

	# Compute the text drawing parameters, i.e., the coordinates of the
	# first character to be drawn, the step between successive characters,
	# and the polytext flag (GKI coords).

	call ccx_parameters (xc,yc, totlen, x0,y0, gki_dx,gki_dy, polytext,
	    orien)

	# Scale the base sizes.
	tsz = GKI_UNPACKREAL(TX_SIZE(tx))	# scale factor
	ch = CCP_CHARHEIGHT(g_cc,1) * tsz
	cw = CCP_CHARWIDTH(g_cc,1) * tsz

	# Compute correction factors for absolute physical character sizes.
	# This also corrects for distortion of high-qual text if xscale<>yscale.
	xto_nicesize = g_xdefault_scale / g_xndcto_p
	yto_nicesize = g_ydefault_scale / g_yndcto_p

	# The first segment is drawn at (X0,Y0).  The separation between
	# characters is DX,DY.  A segment is drawn as a block if the polytext
	# flag is set, otherwise each character is drawn individually.

	x  = x0 * g_dx + g_x1
	y  = y0 * g_dy + g_y1
	dx = gki_dx * g_dx
	dy = gki_dy * g_dy

	for (ip=seg;  Memc[ip] != EOS;  ip=ip+1) {
	    # Process the font control character heading the next segment.
	    font = Memc[ip]
	    ip = ip + 1
	    
	    # Draw the segment.
	    while (Memc[ip] != EOS) {
		# Clip leading out of bounds characters.
		for (;  Memc[ip] != EOS;  ip=ip+1) {
		    x1 = x
		    x2 = x1 + cw * xto_nicesize
		    y1 = y
		    y2 = y1 + ch * yto_nicesize

		    if (x1 >= g_x1 && x2 <= g_x2 && y1 >= g_y1 && y2 <= g_y2)
			break
		    else {
			x = x + dx
			y = y + dy
		    }

		    if (polytext == NO) {
			ip = ip + 1
			break
		    }
		}

		# Coords of first char to be drawn.
		xstart = x
		ystart = y

		# Move OP to first out of bounds char.
		for (op=ip;  Memc[op] != EOS;  op=op+1) {
		    x1 = x
		    x2 = x1 + cw * xto_nicesize
		    y1 = y
		    y2 = y1 + ch * yto_nicesize

		    if (x1 <= g_x1 || x2 >= g_x2 || y1 <= g_y1 || y2 >= g_y2)
			break
		    else {
			x = x + dx
			y = y + dy
		    }

		    if (polytext == NO) {
			op = op + 1
			break
		    }
		}

		# Count number of inbounds chars.
		seglen = op - ip

		# Leave OP pointing to the end of this segment.
		if (polytext == NO)
		    op = ip + 1
		else {
		    while (Memc[op] != EOS)
			op = op + 1
		}

		# Compute X,Y of next segment.
		newx = xstart + (dx * (op - ip))
		newy = ystart +  dy

		# Quit if no inbounds chars.
		if (seglen == 0) {
		    x = newx
		    y = newy
		    ip = op
		    next
		}

		# Output the inbounds chars.

		first = ip
		x = xstart
		y = ystart

		while (seglen > 0 && (polytext == YES || ip == first)) {
		    call ccp_drawchar (Memc[ip], nint(x), nint(y), cw, ch,
			orien, font, quality)
		    ip = ip + 1
		    seglen = seglen - 1
		    x = x + dx
		    y = y + dy
		}

		x = newx
		y = newy
		ip = op
	    }
	}

	call sfree (sp)
end


# CCX_SEGMENT -- Process the text string into segments, in the process
# converting from type short to char.  The only text attribute that can
# change within a string is the font, so segments are broken by \fI, \fG,
# etc. font select sequences embedded in the text.  The segments are encoded
# sequentially in the output string.  The first character of each segment is
# the font number.  A segment is delimited by EOS.  A font number of EOS
# marks the end of the segment list.  The output string is assumed to be
# large enough to hold the segmented text string.

int procedure ccx_segment (text, n, out, start_font)

short	text[ARB]		# input text
int	n			# number of characters in text
char	out[ARB]		# output string
int	start_font		# initial font code

int	ip, op
int	totlen, font

begin
	out[1] = start_font
	totlen = 0
	op = 2

	for (ip=1;  ip <= n;  ip=ip+1) {
	    if (text[ip] == '\\' && text[ip+1] == 'f') {
		# Select font.
		out[op] = EOS
		op = op + 1
		ip = ip + 2

		switch (text[ip]) {
		case 'B':
		    font = GT_BOLD
		case 'I':
		    font = GT_ITALIC
		case 'G':
		    font = GT_GREEK
		default:
		    font = GT_ROMAN
		}

		out[op] = font
		op = op + 1

	    } else {
		# Deposit character in segment.
		out[op] = text[ip]
		op = op + 1
		totlen = totlen + 1
	    }
	}

	# Terminate last segment and add null segment.

	out[op] = EOS
	out[op+1] = EOS

	return (totlen)
end


# CCX_PARAMETERS -- Set the text drawing parameters, i.e., the coordinates
# of the lower left corner of the first character to be drawn, the spacing
# between characters, and the polytext flag.  Input consists of the coords
# of the text string, the length of the string, and the text attributes
# defining the character size, justification in X and Y of the coordinates,
# and orientation of the string.  All coordinates are in GKI units.

procedure ccx_parameters (xc, yc, totlen, x0, y0, dx, dy, polytext, orien)

int	xc, yc			# coordinates at which string is to be drawn
int	totlen			# number of characters to be drawn
int	x0, y0			# lower left corner of first char to be drawn
int	dx, dy			# step in X and Y between characters
int	polytext		# OK to output text segment all at once
int	orien			# rotation angle of characters

pointer	tx
int	up, path
real	dir, sz, ch, cw, cosv, sinv, space, xto_nicesize, yto_nicesize
real	xsize, ysize, xvlen, yvlen, xu, yu, xv, yv, p, q, xtmp, ytmp
include	"ccp.com"

begin
	tx = CCP_TXAP(g_cc)

	# Compute correction factors for absolute physical character sizes.
	# This also removes any warping due to different xscale, yscale.
	xto_nicesize = g_xdefault_scale / g_xndcto_p
	yto_nicesize = g_ydefault_scale / g_yndcto_p

	# Get character sizes in GKI(plotter) coords; scale y (ch) dimension
	# to that of x for absolute scale systems that are different in x,y.

	sz = GKI_UNPACKREAL (TX_SIZE(tx))
	ch = CCP_CHARHEIGHT(g_cc,1) * sz
	cw = CCP_CHARWIDTH(g_cc,1) * sz

	# Compute the character rotation angle.  This is independent of the
	# direction in which characters are drawn.  A character up vector of
	# 90 degrees (normal) corresponds to a rotation angle of zero.

	up = TX_UP(tx)
	orien = up - 90

	# Determine the direction in which characters are to be plotted.
	# This depends on both the character up vector and the path, which
	# is defined relative to the up vector.

	path = TX_PATH(tx)
	switch (path) {
	case GT_UP:
	    dir = up
	case GT_DOWN:
	    dir = up - 180
	case GT_LEFT:
	    dir = up + 90
	default:		# GT_NORMAL, GT_RIGHT
	    dir = up - 90
	}

	# ------- DX, DY ---------
	# Convert the direction vector into the step size between characters.
	# Note CW and CH are in GKI coordinates, hence DX and DY are too.
	# Additional spacing of some fraction of the character size is used
	# if TX_SPACING is nonzero.

	dir = -DEGTORAD(dir)
	cosv = cos (dir)
	sinv = sin (dir)

	# Correct for spacing (unrotated and unscaled).
	space = (1.0 + TX_SPACING(tx))
	if (path == GT_UP || path == GT_DOWN)
	    p = ch * space
	else
	    p = cw * space
	q = 0

	# Correct for rotation, scaling differences, and absolute size.
	dx = ( p * cosv + q * sinv) * xto_nicesize 
	dy = (-p * sinv + q * cosv) * yto_nicesize

	# ------- XU, YU ---------
	# Determine the coordinates of the center of the first character req'd
	# to justify the string, assuming dimensionless characters spaced on
	# centers DX,DY apart.

	xvlen = dx * (totlen - 1)
	yvlen = dy * (totlen - 1)

	switch (TX_HJUSTIFY(tx)) {
	case GT_CENTER:
	    xu = - (xvlen / 2.0)
	case GT_RIGHT:
	    # If right justify and drawing to the left, no offset req'd.
	    if (xvlen < 0)
		xu = 0
	    else
		xu = -xvlen
	default:		# GT_LEFT, GT_NORMAL
	    # If left justify and drawing to the left, full offset right req'd.
	    if (xvlen < 0)
		xu = -xvlen
	    else
		xu = 0
	}

	switch (TX_VJUSTIFY(tx)) {
	case GT_CENTER:
	    yu = - (yvlen / 2.0)
	case GT_TOP:
	    # If top justify and drawing downward, no offset req'd.
	    if (yvlen < 0)
		yu = 0
	    else
		yu = -yvlen
	default:		# GT_BOTTOM, GT_NORMAL
	    # If bottom justify and drawing downward, full offset up req'd.
	    if (yvlen < 0)
		yu = -yvlen
	    else
		yu = 0
	}

	# ------- XV, YV ---------
	# Compute the offset from the center of a single character required
	# to justify that character, given a particular character up vector.
	# (This could be combined with the above case but is clearer if
	# treated separately.)

	p = -DEGTORAD(orien)
	cosv = cos(p)
	sinv = sin(p)

	# Compute the rotated character size in X and Y.
	xsize = abs ( cw * cosv + ch * sinv) * xto_nicesize
	ysize = abs (-cw * sinv + ch * cosv) * yto_nicesize

	switch (TX_HJUSTIFY(tx)) {
	case GT_CENTER:
	    xv = 0
	case GT_RIGHT:
	    xv = - (xsize / 2.0)
	default:		# GT_LEFT, GT_NORMAL
	    xv = xsize / 2
	}

	switch (TX_VJUSTIFY(tx)) {
	case GT_CENTER:
	    yv = 0
	case GT_TOP:
	    yv = - (ysize / 2.0)
	default:		# GT_BOTTOM, GT_NORMAL
	    yv = ysize / 2
	}

	# ------- X0, Y0 ---------
	# The center coordinates of the first character to be drawn are given
	# by the reference position plus the string justification vector plus
	# the character justification vector.

	x0 = xc + xu + xv
	y0 = yc + yu + yv

	# The character drawing primitive requires the coordinates of the
	# lower left corner of the character (irrespective of orientation).
	# Compute the vector from the center of a character to the lower left
	# corner of a character, rotate to the given orientation, and correct
	# the starting coordinates by addition of this vector.

	p = - (cw / 2.0)
	q = - (ch / 2.0)

	xtmp = ( p * cosv + q * sinv) * xto_nicesize 
	ytmp = (-p * sinv + q * cosv) * yto_nicesize

	x0 = x0 + xtmp
	y0 = y0 + ytmp

	# ------- POLYTEXT ---------
	# Set the polytext flag.  Polytext output is possible only if chars
	# are to be drawn to the right with no extra spacing between chars.

	if (abs(dy) == 0 && dx == cw)
	    polytext = YES
	else
	    polytext = NO
end
