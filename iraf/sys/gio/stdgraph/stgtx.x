# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<math.h>
include	<mach.h>
include	<gki.h>
include	<gset.h>
include	"stdgraph.h"

# STG_TEXT -- Draw a text string.  The string is drawn at the position (X,Y)
# using the text attributes set by the last GKI_TXSET instruction.  The text
# string to be drawn may contain embedded set font escape sequences of the
# form \fR (roman), \fG (greek), etc.  We break the input text sequence up
# into segments at font boundaries and draw these on the output device,
# setting the text size, color, font, and position at the beginning of each
# segment.  Two levels of character quality are implemented: MEDIUM and HIGH,
# wherein characters are generated in software, and everything else, wherein
# the characters are generated by the hardware.

procedure stg_text (xc, yc, text, n)

int	xc, yc			# where to draw text string
short	text[ARB]		# text string
int	n			# number of characters

bool	hard
real	x, y
int	x1, x2, y1, y2, mx, my
int	x0, y0, dx, dy, ch, cw, sz
int	xstart, ystart, newx, newy
int	totlen, polytext, font, seglen, orien, hwsz
pointer	sp, seg, ip, op, tx, first
int	stx_segment(), stg_encode()
include	"stdgraph.com"

begin
	call smark (sp)
	call salloc (seg, n + 2, TY_CHAR)

	if (g_enable == NO)
	    call stg_genab()

	# Set pointer to the text attribute structure.
	tx = SG_TXAP(g_sg)

	# Break the text string into segments at font boundaries and count
	# the total number of printable characters.

	totlen = stx_segment (text, n, Memc[seg], TX_FONT(tx), 0, 0)

	# Compute the text drawing parameters, i.e., the coordinates of the
	# first character to be drawn, the step between successive characters,
	# and the polytext flag (GKI coords).

	call stx_parameters (xc,yc, totlen, 0, x0,y0, dx,dy, polytext, orien)

	# Set the text size and color if not already set.  Both should be
	# invalidated when the screen is cleared.  Text color should be
	# invalidated whenever another color is set.  If software (!hard)
	# character generation is indicated then size 1 is simply scaled by
	# the indicated factor, otherwise the text size is  converted to a
	# hardware size index by stg_txsize.

	call stx_chars (tx, ch, cw, hwsz, hard, orien)
	sz = TX_SIZE(tx)

	if (hard)
	    if (SG_TXSIZE(g_sg) != sz) {
		call stg_ctrl1 ("TH", hwsz)
		SG_TXSIZE(g_sg) = sz
	    }

	if (TX_COLOR(tx) != SG_COLOR(g_sg)) {
	    call stg_ctrl1 ("TC", TX_COLOR(tx))
	    SG_COLOR(g_sg) = TX_COLOR(tx)
	}

	# Draw the segments, setting the font at the beginning of each segment.
	# The first segment is drawn at (X0,Y0).  The separation between
	# characters is DX,DY.  A segment is drawn as a block if the polytext
	# flag is set, otherwise each character is drawn individually.
	# All computations are in GKI coordinates.

	x = x0
	y = y0

	for (ip=seg;  Memc[ip] != EOS;  ip=ip+1) {
	    # Process the font control character heading the next segment.
	    font = Memc[ip]
	    ip = ip + 1
	    if (hard)
		if (SG_TXFONT(g_sg) != font) {
		    call stg_ctrl1 ("TF", font - GT_ROMAN + 1)
		    SG_TXFONT(g_sg) = font
		}
	    
	    # Draw the segment.
	    while (Memc[ip] != EOS) {
		# Clip leading out of bounds characters.
		for (;  Memc[ip] != EOS;  ip=ip+1) {
		    x1 = x; x2 = x1 + cw
		    y1 = y; y2 = y1 + ch

		    if (x1 >= 0 && x2 <= GKI_MAXNDC &&
			y1 >= 0 && y2 <= GKI_MAXNDC) {

			break

		    } else {
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
		    x1 = x; x2 = x1 + cw
		    y1 = y; y2 = y1 + ch

		    if (x1 <= 0 || x2 >= GKI_MAXNDC ||
			y1 <= 0 || y2 >= GKI_MAXNDC) {

			break

		    } else {
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
		if (hard) {
		    g_reg[1] = xstart * g_dx + g_x1
		    g_reg[2] = ystart * g_dy + g_y1
		    g_reg[E_IOP] = 1
		    if (stg_encode (Memc[SG_STARTTEXT(g_sg)],g_mem,g_reg) == OK)
			call write (g_out, g_mem, g_reg[E_IOP] - 1)
		}

		first = ip
		x = xstart
		y = ystart

		# Draw the characters.
		while (seglen > 0 && (polytext == YES || ip == first)) {
		    if (hard)
			call putc (g_out, Memc[ip])
		    else {
			mx = nint(x)
			my = nint(y)
			call stg_drawchar (Memc[ip], mx,my, cw, ch, orien, font)
			x = x + dx
			y = y + dy
		    }

		    ip = ip + 1
		    seglen = seglen - 1
		}

		x = newx
		y = newy
		ip = op

		if (hard) {
		    g_reg[E_IOP] = 1
		    if (stg_encode (Memc[SG_ENDTEXT(g_sg)], g_mem, g_reg) == OK)
			call write (g_out, g_mem, g_reg[E_IOP] - 1)
		}
	    }
	}

	call sfree (sp)
end


# STX_SEGMENT -- Process the text string into segments, in the process
# converting from type short to char.  The only text attribute that can
# change within a string is the font, so segments are broken by \fI, \fG,
# etc. font select sequences embedded in the text.  The segments are encoded
# sequentially in the output string.  The first character of each segment is
# the font number.  A segment is delimited by EOS.  A font number of EOS
# marks the end of the segment list.  The output string is assumed to be
# large enough to hold the segmented text string.

int procedure stx_segment (text, n, out, start_font, cw, totwidth)

short	text[ARB]		# input text
int	n			# number of characters in text
char	out[ARB]		# output string
int	start_font		# initial font code
int	cw			# default character width
int	totwidth		# seg width in GKI units

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


# STX_PARAMETERS -- Set the text drawing parameters, i.e., the coordinates
# of the lower left corner of the first character to be drawn, the spacing
# between characters, and the polytext flag.  Input consists of the coords
# of the text string, the length of the string, and the text attributes
# defining the character size, justification in X and Y of the coordinates,
# and orientation of the string.  All coordinates are in GKI units.

procedure stx_parameters (xc, yc, totlen, totwidth, x0, y0, dx, dy, polytext,
   orien)

int	xc, yc			# coordinates at which string is to be drawn
int	totlen			# number of characters to be drawn
int	totwidth		# width of characters to be drawn (unused)
int	x0, y0			# lower left corner of first char to be drawn
int	dx, dy			# step in X and Y between characters
int	polytext		# OK to output text segment all at once
int	orien			# rotation angle of characters

pointer	tx
bool	hard
int	up, path, hwsz, ch, cw, i
real	dir, cosv, sinv, space
real	xsize, ysize, xvlen, yvlen, xu, yu, xv, yv, p, q
include	"stdgraph.com"

begin
	tx = SG_TXAP(g_sg)

	# Compute the character rotation angle.  This is independent of the
	# direction in which characters are drawn.  A character up vector of
	# 90 degrees (normal) corresponds to a rotation angle of zero.

	up = TX_UP(tx)
	orien = up - 90

	# Get character sizes in GKI(NSPP) coords.
	call stx_chars (tx, ch, cw, hwsz, hard, orien)

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

	# If hardware character generation is enabled the character up vector
	# is constrained to 90 degrees.  Flip the direction in which characters
	# will be drawn if necessary to draw from left to right or from top
	# down, the readable directions.

	if (hard) {
	    # Constrain the up vector.
	    orien = 0

	    # Flip direction vector if in 2nd or 3rd quadrant.
	    i = nint(dir)
	    if (i < 0)
		i = i + 360
	    if (i >= 90 && i < 180)
		i = i + 180
	    if (i >= 360)
		i = i - 360
	    dir = real(i)
	}

	# ------- DX, DY ---------
	# Convert the direction vector into the step size between characters.
	# Note CW and CH are in GKI coordinates, hence DX and DY are too.
	# Additional spacing of some fraction of the character size is used
	# if TX_SPACING is nonzero.

	dir = -DEGTORAD(dir)
	cosv = cos (dir)
	sinv = sin (dir)

	# Correct for spacing (unrotated).
	space = (1.0 + TX_SPACING(tx))
	if ((path == GT_UP || path == GT_DOWN) ||
	    (hard && abs(cosv) < .9)) {
	    p = ch * space
	} else
	    p = cw * space
	q = 0

	# Correct for rotation.
	dx =  p * cosv + q * sinv
	dy = -p * sinv + q * cosv

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

	# Compute the rotated character in size X and Y.
	xsize = abs ( cw * cosv + ch * sinv)
	ysize = abs (-cw * sinv + ch * cosv)

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

	x0 = x0 + ( p * cosv + q * sinv)
	y0 = y0 + (-p * sinv + q * cosv)

	# ------- POLYTEXT ---------
	# Set the polytext flag.  Polytext output is possible only if chars
	# are to be drawn to the right with no extra spacing between chars.

	if (abs(dy) == 0 && dx == cw)
	    polytext = YES
	else
	    polytext = NO
end


# STX_CHARS -- Get the character drawing parameters, i.e., the size of a
# character in X and Y and whether or not to use the hardware character
# generator.  The decision whether or not to use the hardware character
# generator is based on the text attribute QUALITY, unless overridden by
# the g_hardchar switch in common (set explicitly in cursor mode or by a
# stdgraph task parameter).

procedure stx_chars (tx, ch, cw, hwsz, hard, orien)

pointer	tx			# pointer to text attribute structure
int	ch, cw			# character height, width, GKI coords
int	hwsz			# size index if hardware character
bool	hard			# use/dontuse hardware character generation
int	orien			# rotation angle of character (0=normal)

int	sz, quality
real	txsize, aspect, q
int	stg_txsize()
real	ttygetr()
include	"stdgraph.com"

begin
	sz = TX_SIZE(tx)
	if (g_hardchar == 0)
	    quality = TX_QUALITY(tx)
	else
	    quality = g_hardchar
	hard = (quality != GT_MEDIUM && quality != GT_HIGH)

	# Get character size in GKI units.
	if (hard) {
	    hwsz = stg_txsize (sz)
	    ch = SG_CHARHEIGHT(g_sg,hwsz)
	    cw = SG_CHARWIDTH (g_sg,hwsz)

	} else {
	    # If character generation is in software scale character sizes
	    # by the size of the size 1 hardware character.  If the character
	    # is rotated correct for the device aspect ratio so that the
	    # character comes out the same size regardless of the orientation.

	    txsize = GKI_UNPACKREAL(sz)
	    cw = SG_CHARWIDTH (g_sg,1) * txsize
	    ch = SG_CHARHEIGHT(g_sg,1) * txsize

	    if (orien != 0) {
		aspect = ttygetr (g_tty, "ar")
		if (aspect > EPSILON && abs (aspect - 1.0) > .01) {
		    q = 1.0 + abs(sin(real(orien))) * (aspect - 1.0)
		    cw = cw / q
		    ch = ch * q
		}
	    }
	}
end