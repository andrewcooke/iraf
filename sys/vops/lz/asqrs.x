# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

# ASQR -- Compute the square root of a vector (generic).  If the square root
# is undefined (x < 0) a user supplied function is called to compute the value.

procedure asqrs (a, b, npix, errfcn)

short	a[ARB], b[ARB]
int	npix, i
extern	errfcn()
short	errfcn()
errchk	errfcn

begin
	do i = 1, npix {
		if (a[i] <= 0)
		    b[i] = errfcn (a[i])
		else
		{
			b[i] = sqrt (real (a[i]))
		}
	}
end
