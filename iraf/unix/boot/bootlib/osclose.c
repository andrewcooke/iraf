/* Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.
 */

#include "bootlib.h"
#include <unistd.h>

/* OS_CLOSE -- Close a file created (opened) by OSCREATE.  If writing to a
 * text file flush any incomplete (non newline terminated) output line.
 */
int os_close ( int fd )
{
	XINT	junk;
	XINT	nchars;
	XINT	x_fd;

	x_fd = fd;
	if (osfiletype == BINARY_FILE)
	    close (fd);
	else {
	    if (txop > text) {
		nchars = txop - text;
		ZPUTTX (&x_fd, text, &nchars, &junk);
	    }
	    ZCLSTX (&x_fd, &junk);
	}

	return 0;
}