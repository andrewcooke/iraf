# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<error.h>
include	<pkg/gtools.h>
include	"names.h"
include	"icfit.h"

# ICG_FIT -- Interactive curve fitting with graphics.  This is the main
# entry point for the interactive graphics part of the icfit package.

procedure icg_fitd (ic, gp, cursor, gt, cv, x, y, wts, npts)

pointer	ic			# ICFIT pointer
pointer	gp			# GIO pointer
char	cursor[ARB]		# GIO cursor input
pointer	gt			# GTOOLS pointer
pointer	cv			# CURFIT pointer
double	x[npts]			# Ordinates
double	y[npts]			# Abscissas
double	wts[npts]		# Weights
int	npts			# Number of points

real	wx, wy
int	wcs, key
char	cmd[SZ_LINE]

int	i, newgraph, axes[2], xtype
double	x1
real	rx1, rx2, ry1, ry2
pointer	sp, userwts

int	gt_gcur1(), stridxs(), scan(), nscan()
int	icg_nearestd()
double	dcveval()
errchk	ic_fitd()

begin
	# Allocate memory for the fit and a copy of the weights.
	# The weights are copied because they are changed when points are
	# deleted.

	call smark (sp)
	call salloc (userwts, npts, TY_DOUBLE)
	call amovd (wts, Memd[userwts], npts)

	# Initialize
	IC_OVERPLOT(ic) = NO
	IC_NEWX(ic) = YES
	IC_NEWY(ic) = YES
	IC_NEWWTS(ic) = YES
	IC_NEWFUNCTION(ic) = YES

	# Read cursor commands.

	key = 'f'
	newgraph = YES
	axes[1] = IC_AXES(ic, IC_GKEY(ic), 1)
	axes[2] = IC_AXES(ic, IC_GKEY(ic), 2)
	xtype = 0

	repeat {
	    switch (key) {
	    case '?': # Print help text.
		call gpagefile (gp, Memc[IC_HELP(ic)], IC_PROMPT)

	    case ':': # List or set parameters
		if (cmd[1] == '/')
	            call gt_colon (cmd, gp, gt, newgraph)
		else
		    call icg_colond (ic, cmd, newgraph, gp, gt, cv, x, y, wts,
			npts)

	    case 'c': # Print the positions of data points.
		i = icg_nearestd (ic, gp, gt, cv, x, y, npts, wx, wy)

	    	if (i != 0) {
		    call printf ("x = %g  y = %g  fit = %g\n")
			call pargd (x[i])
			call pargd (y[i])
			call pargd (dcveval (cv, x[i]))
		}

	    case 'd': # Delete data points.
		call icg_deleted (ic, gp, gt, cv, x, y, wts, Memd[userwts],
		    npts, wx, wy)

	    case 'f': # Fit the function and reset the flags.
		iferr {
		    call ic_fitd (ic, cv, x, y, wts, npts, IC_NEWX(ic),
			IC_NEWY(ic), IC_NEWWTS(ic), IC_NEWFUNCTION(ic))

		    IC_NEWX(ic) = NO
		    IC_NEWY(ic) = NO
		    IC_NEWWTS(ic) = NO
		    IC_NEWFUNCTION(ic) = NO
		    IC_FITERROR(ic) = NO
		    newgraph = YES
		} then {
		    IC_FITERROR(ic) = YES
		    call erract (EA_WARN)
		}

	    case 'g':	# Set graph axes types.
		call printf ("Graph key to be defined: ")
		call flush (STDOUT)
		if (scan() == EOF)
		    goto 10
		call gargc (cmd[1])

		switch (cmd[1]) {
		case '\n':
		case 'h', 'i', 'j', 'k', 'l':
		    switch (cmd[1]) {
		    case 'h':
		        key = 1
		    case 'i':
		        key = 2
		    case 'j':
		        key = 3
		    case 'k':
		        key = 4
		    case 'l':
		        key = 5
		    }

		    call printf ("Set graph axes types (%c, %c): ")
		        call pargi (IC_AXES(ic, key, 1))
		        call pargi (IC_AXES(ic, key, 2))
		    call flush (STDOUT)
		    if (scan() == EOF)
		        goto 10
		    call gargc (cmd[1])

		    switch (cmd[1]) {
		    case '\n':
		    default:
		        call gargc (cmd[2])
		        call gargc (cmd[2])
		        if (cmd[2] != '\n') {
			    IC_AXES(ic, key, 1) = cmd[1]
			    IC_AXES(ic, key, 2) = cmd[2]
			    if (IC_GKEY(ic) == key)
				newgraph = YES
		        }
		    }
		default:
		    call printf ("Not a graph key\n")
		}

	    case 'h':
		if (IC_GKEY(ic) != 1) {
		    IC_GKEY(ic) = 1
		    newgraph = YES
		}

	    case 'i':
		if (IC_GKEY(ic) != 2) {
		    IC_GKEY(ic) = 2
		    newgraph = YES
		}

	    case 'j':
		if (IC_GKEY(ic) != 3) {
		    IC_GKEY(ic) = 3
		    newgraph = YES
		}

	    case 'k':
		if (IC_GKEY(ic) != 4) {
		    IC_GKEY(ic) = 4
		    newgraph = YES
		}

	    case 'l':
		if (IC_GKEY(ic) != 5) {
		    IC_GKEY(ic) = 5
		    newgraph = YES
		}

	    case 't': # Initialize the sample string and erase from the graph.
		call icg_sampled (ic, gp, gt, x, npts, 0)
		call sprintf (Memc[IC_SAMPLE(ic)], SZ_LINE, "*")
		IC_NEWX(ic) = YES

	    case 'o': # Set overplot flag
		IC_OVERPLOT(ic) = YES

	    case 'r': # Redraw the graph
		newgraph = YES

	    case 's': # Set sample regions with the cursor.
		if ((IC_AXES(ic,IC_GKEY(ic),1) == 'x') ||
		    (IC_AXES(ic,IC_GKEY(ic),2) == 'x')) {
		    if (stridxs ("*", Memc[IC_SAMPLE(ic)]) > 0)
		        Memc[IC_SAMPLE(ic)] = EOS

		    rx1 = wx
		    ry1 = wy
		    call printf ("again:\n")
		    if (gt_gcur1(gt, cursor, wx, wy, wcs, key, cmd, SZ_LINE)
			== EOF)
		        break
		    call printf ("\n")
		    rx2 = wx
		    ry2 = wy

		    # Determine if the x vector is integer.
		    if (xtype == 0) {
			xtype = TY_INT
			do i = 1, npts
			    if (x[i] != int (x[i])) {
				xtype = TY_REAL
				break
			    }
		    }

		    if (IC_AXES(ic,IC_GKEY(ic),1) == 'x') {
		        if (xtype == TY_INT) {
		            call sprintf (cmd, SZ_LINE, " %d:%d")
		                call pargi (nint (rx1))
		                call pargi (nint (rx2))
			} else {
		            call sprintf (cmd, SZ_LINE, " %g:%g")
		                call pargr (rx1)
		                call pargr (rx2)
			}
		    } else {
		        if (xtype == TY_INT) {
		            call sprintf (cmd, SZ_LINE, " %d:%d")
		                call pargi (nint (ry1))
		                call pargi (nint (ry2))
			} else {
		            call sprintf (cmd, SZ_LINE, " %g:%g")
		                call pargr (ry1)
		                call pargr (ry2)
			}
		    }
		    call strcat (cmd, Memc[IC_SAMPLE(ic)], SZ_LINE)
		    call icg_sampled (ic, gp, gt, x, npts, 1)
		    IC_NEWX(ic) = YES
		}

	    case 'u': # Undelete data points.
		call icg_undeleted (ic, gp, gt, cv, x, y, wts, Memd[userwts],
		    npts, wx, wy)

	    case 'w':  # Window graph
		call gt_window (gt, gp, cursor, newgraph)

	    case 'x': # Reset the value of the x point.
		i = icg_nearestd (ic, gp, gt, cv, x, y, npts, wx, wy)

	    	if (i != 0) {
		    call printf ("x = (%g) ")
			call pargd (x[i])
		    call flush (STDOUT)
		    if (scan() != EOF) {
		        call gargd (x1)
		        if (nscan() == 1) {
			    if (!IS_INDEF (x1)) {
			        x[i] = x1
			        IC_NEWX(ic) = YES
			    }
			}
		    }
		}

	    case 'y': # Reset the value of the y point.
		i = icg_nearestd (ic, gp, gt, cv, x, y, npts, wx, wy)

	    	if (i != 0) {
		    call printf ("y = (%g) ")
			call pargd (y[i])
		    call flush (STDOUT)
		    if (scan() != EOF) {
		        call gargd (x1)
		        if (nscan() == 1) {
			    if (!IS_INDEF (x1)) {
			        y[i] = x1
			        IC_NEWY(ic) = YES
			    }
			}
		    }
		}

	    case 'I': # Interrupt
		call fatal (0, "Interrupt")

	    default: # Let the user decide on any other keys.
		call icg_user (ic, gp, gt, cv, wx, wy, wcs, key, cmd)
	    }

	    # Redraw the graph if necessary.
10	    if (newgraph == YES) {
		if (IC_AXES(ic, IC_GKEY(ic), 1) != axes[1]) {
		    axes[1] = IC_AXES(ic, IC_GKEY(ic), 1)
		    call gt_setr (gt, GTXMIN, INDEFR)
		    call gt_setr (gt, GTXMAX, INDEFR)
		}
		if (IC_AXES(ic, IC_GKEY(ic), 2) != axes[2]) {
		    axes[2] = IC_AXES(ic, IC_GKEY(ic), 2)
		    call gt_setr (gt, GTYMIN, INDEFR)
		    call gt_setr (gt, GTYMAX, INDEFR)
		}
	    	call icg_graphd (ic, gp, gt, cv, x, y, wts, npts)
		newgraph = NO
	    }
	    if (cursor[1] == EOS)
		break
	} until (gt_gcur1 (gt, cursor, wx, wy, wcs, key, cmd, SZ_LINE) == EOF)

	call sfree (sp)
end
