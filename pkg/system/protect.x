# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<protect.h>
include	<error.h>

# PROTECT -- Protect a list of files.

procedure t_protect()

char	fname[SZ_FNAME]
int	list, clpopns(), clgfil()

begin
	list = clpopns ("files")

	while (clgfil (list, fname, SZ_FNAME) != EOF)
	    iferr (call protect (fname, SET_PROTECTION))
		call erract (EA_WARN)

	call clpcls (list)
end
