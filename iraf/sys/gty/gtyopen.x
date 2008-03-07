include	<error.h>
include	<syserr.h>
include	<ctype.h>
include	<chars.h>
include	"gty.h"

# GTYOPEN -- Scan the named TERMCAP style file for the entry for the named
# device, and if found allocate a TTY descriptor structure, leaving the
# termcap entry for the device in the descriptor.  If any UFIELDS are given
# these will be prepended to the output device capability list, overriding
# the device file entries.  If no termcap file is named (null string) then
# UFIELDS is taken as the device entry and opened on a GTY descriptor.

pointer procedure gtyopen (termcap_file, device, ufields)

char	termcap_file[ARB]	#I termcap file to be scanned
char	device[ARB]		#I name of device to be extracted
char	ufields[ARB]		#I user specified capabilities

size_t	sz_val
int	nchars, ip
pointer	caplist, tty, op
errchk	calloc, realloc, gty_index_caps
pointer	coerce()
int	strlen()

begin
	# Allocate and initialize the tty descriptor structure.
	sz_val = LEN_DEFTTY
	call calloc (tty, sz_val, TY_STRUCT)

	T_LEN(tty) = LEN_DEFTTY
	T_OP(tty) = 1

	# Place any user specified capabilities in the caplist.  These will
	# override any values given in the file entry.

	for (ip=1;  ufields[ip] != EOS && ufields[ip] != ':';  ip=ip+1)
	    ;
	nchars = strlen (ufields[ip])
	if (nchars > 0) {
	    caplist = coerce (tty + T_OFFCAP, TY_STRUCT, TY_CHAR)
	    call strcpy (ufields[ip], Memc[caplist], T_LEN(tty) - T_OFFCAP)
	    op = caplist + nchars
	    if (Memc[op-1] == ':')
		op = op - 1
	    Memc[op] = EOS
	    T_OP(tty) = op - caplist + 1
	    T_CAPLEN(tty) = T_OP(tty)
	}

	# Scan the source file, if given.
	if (termcap_file[1] != EOS)
	    iferr (call gty_scan_termcap_file (tty, termcap_file, device)) {
		call mfree (tty, TY_STRUCT)
		call erract (EA_ERROR)
	    }

	# Call realloc to return any unused space in the descriptor.
	T_LEN(tty) = T_OFFCAP + (T_OP(tty) + SZ_STRUCT-1) / SZ_STRUCT
	sz_val = T_LEN(tty)
	call realloc (tty, sz_val, TY_STRUCT)

	# Prepare index of fields in the descriptor, so that we can more
	# efficiently search for fields later.

	call gty_index_caps (tty, T_CAPCODE(tty), T_CAPINDEX(tty),
	    T_NCAPS(tty))

	return (tty)
end


# TTY_SCAN_TERMCAP_FILE -- Open and scan the named TERMCAP format database
# file for the named device.  Fetch termcap entry, expanding any and all
# "tc" references by repeatedly rescanning file.

procedure gty_scan_termcap_file (tty, termcap_file, devname)

pointer	tty			# tty descriptor structure
char	termcap_file[ARB]	# termcap format file to be scanned
char	devname[ARB]		# termcap entry to be scanned for

size_t	sz_val
long	lval
int	fd, ntc
pointer	sp, device, ip, op, caplist
int	open(), strlen(), strncmp()
pointer	coerce()
errchk	open, syserrs

begin
	call smark (sp)
	sz_val = SZ_FNAME
	call salloc (device, sz_val, TY_CHAR)

	fd = open (termcap_file, READ_ONLY, TEXT_FILE)
	call strcpy (devname, Memc[device], SZ_FNAME)

	ntc = 0
	repeat {
	    iferr (call gty_fetch_entry (fd, Memc[device], tty)) {
		call close (fd)
		call erract (EA_ERROR)
	    }

	    # Back up to start of last field in entry.
	    caplist = coerce (tty + T_OFFCAP, TY_STRUCT, TY_CHAR)
	    ip = caplist + T_OP(tty)-1 - 2
	    while (ip > caplist && Memc[ip] != ':')
		ip = ip - 1

	    # If last field is "tc", backup op so that the tc field gets
	    # overwritten with the referenced entry.

	    if (strncmp (Memc[ip+1], "tc", 2) == 0) {
		# Check for recursive tc reference.
		ntc = ntc + 1
		if (ntc > MAX_TC_NESTING) {
		    call close (fd)
		    call syserrs (SYS_TTYTC, Memc[device])
		}

		# Set op to point to the ":" in ":tc=file".
		T_OP(tty) = ip - caplist + 1

		# Get device name from tc field, and loop again to fetch new
		# entry.
		ip = ip + strlen (":tc=")
		for (op=device;  Memc[ip] != EOS && Memc[ip] != ':';  ip=ip+1) {
		    Memc[op] = Memc[ip]
		    op = op + 1
		}
		Memc[op] = EOS
		lval = BOFL
		call seek (fd, lval)
	    } else
		break
	}

	call close (fd)
	call sfree (sp)
end


# GTY_FETCH_ENTRY -- Search the termcap file for the named entry, then read
# the colon delimited capabilities list into the caplist field of the tty
# descriptor.  If the caplist field fills up, allocate more space.

procedure gty_fetch_entry (fd, device, tty)

int	fd
char	device[ARB]
pointer	tty

size_t	sz_val
char	ch, lastch
bool	device_found
pointer	sp, ip, op, otop, lbuf, alias, caplist

char	getc()
bool	streq()
pointer	coerce()
int	getline(), gty_extract_alias()
errchk	getline, getc, realloc, salloc
define	errtn_ 91

begin
	call smark (sp)
	sz_val = SZ_LINE
	call salloc (lbuf, sz_val,  TY_CHAR)
	sz_val = SZ_FNAME
	call salloc (alias, sz_val, TY_CHAR)

	# Locate entry.  First line of each termcap entry contains a list
	# of aliases for the device.  Only first lines and comment lines
	# are left justified.

	repeat {
	    # Skip comment and continuation lines and blank lines.
	    device_found = false

	    if (getc (fd, ch) == EOF)
		goto errtn_

	    if (ch == '\n') {
		# Skip a blank line.
		next
	    } else if (ch == '#' || IS_WHITE (ch)) {
		# Discard the rest of the line and continue.
		if (getline (fd, Memc[lbuf]) == EOF)
		    goto errtn_
		next
	    }

	    # Extract list of aliases.  The first occurrence of ':' marks
	    # the end of the alias list and the beginning of the caplist.

	    Memc[lbuf] = ch
	    op = lbuf + 1

	    for (;  getc(fd,ch) != ':';  op=op+1) {
		Memc[op] = ch
		if (ch == EOF || ch == '\n') {
		    goto errtn_
		}
	    }
	    Memc[op] = EOS

	    ip = lbuf
	    while (gty_extract_alias (Memc, ip, Memc[alias], SZ_FNAME) > 0) {
		if (device[1] == EOS || streq (Memc[alias], device)) {
		    device_found = true
		    break
		} else if (Memc[ip] == '|')
		    ip = ip + 1				# skip delimiter
	    }

	    # Skip rest of line if no match.
	    if (!device_found) {
		if (getline (fd, Memc[lbuf]) == EOF) {
		    goto errtn_
		}
	    }
	} until (device_found)

	# Caplist begins at first ':'.  Each line has some whitespace at the
	# beginning which should be skipped.  Escaped newline implies
	# continuation.

	caplist = coerce (tty + T_OFFCAP, TY_STRUCT, TY_CHAR)
	op = caplist + T_OP(tty) - 1
	otop = coerce (tty + T_LEN(tty), TY_STRUCT, TY_CHAR)

	# We are already positioned to the start of the caplist.
	Memc[op] = ':'
	op = op + 1
	lastch = ':'

	# Extract newline terminated caplist string.
	while (getc (fd, ch) != EOF) {
	    if (ch == '\\') {				# escaped newline?
		if (getc (fd, ch) == '\n') {
		    while (getc (fd, ch) != EOF)
			if (!IS_WHITE(ch))
			    break
		    if (ch == EOF || ch == '\n')
			goto errtn_
		    # Avoid null entries ("::").
		    if (ch == ':' && lastch == ':')
			next
		    else
			Memc[op] = ch
		} else {				# no, keep both chars
		    Memc[op] = '\\'
		    op = op + 1
		    Memc[op] = ch
		}
	    } else if (ch == '\n') {			# normal exit
		Memc[op] = EOS
		T_OP(tty) = op - caplist + 1
		T_CAPLEN(tty) = T_OP(tty)
		call sfree (sp)
		return
	    } else
		Memc[op] = ch

	    # Increase size of buffer if necessary.  Note that realloc may 
	    # move the buffer, so we must recalculate op and otop.

	    lastch = ch
	    op = op + 1
	    if (op >= otop) {
		T_OP(tty) = op - caplist + 1
		T_LEN(tty) = T_LEN(tty) + T_MEMINCR
		sz_val = T_LEN(tty)
		call realloc (tty, sz_val, TY_STRUCT)
		op = caplist + T_OP(tty) - 1
		otop = coerce (tty + T_LEN(tty), TY_STRUCT, TY_CHAR)
	    }
	}

errtn_
 	call sfree (sp)
	call syserrs (SYS_TTYDEVNF, device)
end


# GTY_EXTRACT_ALIAS -- Extract a device alias string from the header of
# a termcap entry.  The alias string is terminated by '|' or ':'.  Leave
# ip pointing at the delimiter.  Return number of chars in alias string.

int procedure gty_extract_alias (str, ip, outstr, maxch)

char	str[ARB]		# first line of termcap entry
pointer	ip			# on input, first char of alias
char	outstr[ARB]
int	maxch

char	ch
int	op

begin
	op = 1
	for (ch=str[ip];  ch != '|' && ch != ':' && ch != EOS;  ch=str[ip]) {
	    outstr[op] = ch
	    op = min (maxch, op) + 1
	    ip = ip + 1
	}
	outstr[op] = EOS

	if (ch == EOS)
	    return (0)
	else
	    return (op-1)
end
