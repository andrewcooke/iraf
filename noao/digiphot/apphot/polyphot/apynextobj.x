include <fset.h>
include "../lib/polyphot.h"

# AP_YNEXTOBJ -- Procedure to fetch the next polygon from the list.

int procedure ap_ynextobj (py, id, pl, cl, delim, x, y, maxnver, prev_num,
    req_num, ld, pd)

pointer	py		# pointer to the apphot structre
pointer	id		# pointer to image display stream
int	pl		# polygons file descriptor
int	cl		# coordinates file descriptor
int	delim		# delimiter character
real	x[ARB]		# x coordinates of the polygon vertices
real	y[ARB]		# y coordinates of the polygon vertices
int	maxnver		# maximum number of vertices
int	prev_num	# previous object
int	req_num		# requested object
int	ld		# current object
int	pd		# current polygon

int	stdin, nskip, ncount, nver, stat
pointer	sp, fname
real	xshift, yshift
int	strncmp(), ap_yget(), ap_ycoords()
real	apstatr()
errchk	greactivate, gdeactivate, gscur

begin

	if (cl == NULL) {

	    call smark (sp)
	    call salloc (fname, SZ_FNAME, TY_CHAR)

	    # Compute the number of polygons that must be skipped.
	    call fstats (pl, F_FILENAME, Memc[fname], SZ_FNAME)
	    if (strncmp ("STDIN", Memc[fname], 5) == 0) {
		stdin = YES
		nskip = 1
	    } else {
		stdin = NO
		if (req_num <= prev_num) {
		    call seek (pl, BOF)
		    nskip = req_num
		} else
		    nskip = req_num - prev_num
	    }

	    # Find the correct polygon.
	    ncount = 0
	    pd = prev_num
	    repeat {
		call apsetr (py, PYX, apstatr (py, PYCX))
		call apsetr (py, PYY, apstatr (py, PYCY))
		nver = ap_yget (py, pl, delim, x, y, maxnver)
		if (nver == EOF)
		    ncount = EOF
		else if (nver > 0) {
		    ncount = ncount + 1
		    pd = pd + 1
		}
	    } until (ncount == EOF || ncount == nskip)

	    if (req_num <= prev_num)
		pd = ncount 
	    ld = pd

	    call sfree (sp)
	    if (ncount == EOF)
		return (EOF)
	    else {
	        if (id != NULL) {
		    iferr {
		        call greactivate (id, 0)
		        call gscur (id, apstatr (py, PYCX), apstatr (py, PYCY))
		        call gdeactivate (id, 0)
		    } then
		        ;
	        }
		return (nver)
	    }

	} else {

	    call smark (sp)
	    call salloc (fname, SZ_FNAME, TY_CHAR)
	    call fstats (cl, F_FILENAME, Memc[fname], SZ_FNAME)

	    # Compute the number of objects that must be skipped.
	    if (strncmp ("STDIN", Memc[fname], 5) == 0) {
		stdin = YES
		nskip = 1
	    } else {
		stdin = NO
		if (req_num <= prev_num) {
		    call seek (cl, BOF)
		    call seek (pl, BOF)
		    pd = 0
		    nskip = req_num
		} else
		    nskip = req_num - prev_num
	    }

	    # Find the correct object and shift the coordinates.
	    ncount = 0
	    ld = prev_num
	    repeat {
		stat = ap_ycoords (cl, delim, xshift, yshift, stdin)
		if (stat == EOF)
		    ncount = EOF
		else if (stat == NEXT_POLYGON || pd == 0) {
		    call apsetr (py, PYX, apstatr (py, PYCX))
		    call apsetr (py, PYY, apstatr (py, PYCY))
		    nver = ap_yget (py, pl, delim, x, y, maxnver)
		    if (nver == EOF)
		        ncount = EOF
		    else if (nver > 0)
		        pd = pd + 1
		}
		if (stat == THIS_OBJECT && ncount != EOF && nver > 0) {
		    call aaddkr (x, (xshift - apstatr (py, PYCX)), x, nver + 1)
		    call aaddkr (y, (yshift - apstatr (py, PYCY)), y, nver + 1)
		    call apsetr (py, PYCX, xshift)
		    call apsetr (py, PYCY, yshift)
		    ncount = ncount + 1
		    ld = ld + 1
		}
	    } until (ncount == EOF || ncount == nskip)
	    if (req_num <= prev_num)
		ld = ncount

	    call sfree (sp)
	    if (ncount == EOF)
		return (EOF)
	    else {
	        if (id != NULL) {
		    iferr {
		        call greactivate (id, 0)
		        call gscur (id, apstatr (py, PYCX), apstatr (py, PYCY))
		        call gdeactivate (id, 0)
		    } then
		        ;
	        }
		return (nver)
	    }
	}

end
