# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<syserr.h>
include	<plset.h>
include	<plio.h>

# PL_LOADF -- Load a mask stored in external format in a binary file.  This
# simple code permits only one mask per file; more sophisticated storage
# facilities are planned; these will probably obsolete this routine.

procedure pl_loadf (pl, fname, title, maxch)

pointer	pl			#I mask descriptor
char	fname[ARB]		#I file
char	title[maxch]		#O mask title
int	maxch			#I max chars out

int	fd, nchars
pointer	sp, bp, sv, text
int	open(), read(), mii_readc(), mii_readi()
errchk	open, read, syserrs

begin
	call smark (sp)
	fd = open (fname, READ_ONLY, BINARY_FILE)

	# Get savefile header.
	call salloc (sv, LEN_SVDES, TY_STRUCT)
	if (mii_readi (fd, Memi[sv], LEN_SVDES) != LEN_SVDES)
	    call syserrs (SYS_PLBADSAVEF, fname)

	# Verify file type.
	if (SV_MAGIC(sv) != PLIO_SVMAGIC)
	    call syserrs (SYS_PLBADSAVEF, fname)

	# Get descriptive text.
	call salloc (text, SV_TITLELEN(sv), TY_CHAR)
	if (mii_readc (fd, Memc[text], SV_TITLELEN(sv)) != SV_TITLELEN(sv))
	    call syserrs (SYS_PLBADSAVEF, fname)
	else
	    call strcpy (Memc[text], title, maxch)

	# Get encoded mask.
	call salloc (bp, SV_MASKLEN(sv), TY_SHORT)
	nchars = read (fd, Mems[bp], SV_MASKLEN(sv) * SZ_SHORT)
	call close (fd)

	call pl_load (pl, bp) 
	call sfree (sp)
end
