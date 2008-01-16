/* Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#define import_spp
#define import_kernel
#define import_knames
#include <iraf.h>

static const char *_ev_scaniraf ( const char * );
static int _ev_loadcache ( const char * );
static int _ev_streq ( const char *, const char *, int );

/* ZGTENV -- Get the value of a host system environment variable.  Look first
 * in the process environment.  If no entry is found there and the variable is
 * one of the standard named variables, get the system wide default value from
 * the file <iraf.h>, which is assumed to be located in /usr/include.
 */
/* envvar : name of variable to be fetched	*/
/* outstr : output string			*/
int ZGTENV ( PKCHAR *envvar, PKCHAR *outstr, XINT *maxch, XINT *status )
{
	const char *ip;
	char *op, *maxop;
	size_t bufsize = *maxch + 1;

	maxop = (char *)outstr + bufsize -1;
	op = (char *)outstr;
	if ((ip = getenv ((const char *)envvar)) == NULL)
	    ip = _ev_scaniraf ((const char *)envvar);

	if (ip == NULL) {
	    *op = EOS;
	    *status = XERR;
	} else {
	    *status = 0;
	    for ( ; op < maxop && (*ip) ; op++, ip++ ) {
		*op = *ip;
		(*status)++;
	    }
	    if ( op <= maxop ) *op = EOS;
	}

	return *status;
}


/*
 * Code to bootstrap the IRAF environment list for UNIX.
 */

#define TABLE		"/usr/include/iraf.h"	/* table file		*/
#define DELIM		"/* ###"		/* delimits defs area	*/
#define NENV		3			/* n variables		*/
#define SZ_NAME		10
#define SZ_VALUE	80

struct	env {
	char	ev_name[SZ_NAME+1];
	char	ev_value[SZ_VALUE+1];
};

static int	ev_cacheloaded = 0;
static struct	env ev_table[NENV] = {
	{ "host", "" },
	{ "iraf", "" },
	{ "tmp",  "" }
};


/* SCANIRAF -- If the referenced environment variable is a well known standard
 * variable, scan the file <iraf.h> for its system wide default value.  This
 * is done at run time rather than compile time to make it possible to make
 * changes to these variables (e.g., relocate iraf to a different root
 * directory) without recompiling major parts of the system.
 *
 * Virtually all IRAF environment variables are defined in the source code and
 * are portable.  In particular, virtually all source directories are defined
 * relative to the IRAF root directory "iraf$".  Only those definitions which
 * are both necessarily machine dependent and required for operation of the
 * bootstrap C programs (e.g., the CL, XC, etc.) are satisfied at this level.
 * These variables are the following.
 *
 *	iraf		The root directory of IRAF; if this is incorrect,
 *			    bootstrap programs like the CL will not be able
 *			    to find IRAF files.
 *
 *	host		The machine dependent subdirectory of iraf$.  The
 *			    actual name of this directory varies from system
 *			    to system (to avoid name collisions on tar tapes),
 *			    hence we cannot use "iraf$host/".
 *			    Examples: iraf$unix/, iraf$vms/, iraf$sun/, etc.
 *
 *	tmp		The place where IRAF is to put its temporary files.
 *			    This is normally /tmp/ for a UNIX system.  TMP
 *			    also serves as the default IMDIR.
 *	
 * The entries for these variables in the <iraf.h> must adhere to a standard
 * format, e.g. (substituting @ for *):
 *
 *	/@ ### Start of run time definitions @/
 *	#define	iraf		"/iraf/"
 *	#define	host		"/iraf/unix/"
 *	#define	tmp		"/tmp/"
 *	/@ ### End of run time definitions @/
 *
 * Although the definitions are entered as standard C #defines, they should not
 * be directly referenced in C programs.
 */
static const char *_ev_scaniraf ( const char *envvar )
{
	int	i;

	for (i=0;  i < NENV;  i++)
	    if (strcmp (ev_table[i].ev_name, envvar) == 0)
		break;

	if (i >= NENV)
	    return (NULL);

	if (!ev_cacheloaded) {
	    if (_ev_loadcache (TABLE) == ERR)
		return (NULL);
	    else
		ev_cacheloaded++;
	}

	return (ev_table[i].ev_value);
}


/* _EV_LOADCACHE -- Scan <iraf.h> for the values of the standard variables.
 * Cache these in case we are called again (they do not change so often that we
 * cannot cache them in memory).  Any errors in accessing the table probably
 * indicate an error in installing IRAF hence should be reported immediately.
 */
static int _ev_loadcache ( const char *fname )
{
	static char delim[] = DELIM;
	char lbuf[SZ_LINE+1];
	char *op, *maxop;
	const char *ip;
	FILE *fp;
	int len_delim, i;

	if ((fp = fopen (fname, "r")) == NULL) {
	    fprintf (stderr, "os.zgtenv: cannot open `%s'\n", fname);
	    return (ERR);
	}

	len_delim = strlen (delim);
	while (fgets (lbuf, SZ_LINE+1, fp) != NULL)
	    if (strncmp (lbuf, delim, len_delim) == 0)
		break;

	/* Extract the values of the variables from the table.  The format is
	 * rather rigid; in particular, the variables must be given in the
	 * table in the same order in which they appear in the in core table,
	 * i.e., alphabetic order.
	 */
	for (i=0;  i < NENV;  i++) {
	    if (fgets (lbuf, SZ_LINE+1, fp) == NULL)
		goto error;
	    if (strncmp (lbuf, "#define", 7) != 0)
		goto error;

	    /* Verify the name of the variable.  */
	    ip = ev_table[i].ev_name;
	    if (!_ev_streq (lbuf+8, ip, strlen(ip)))
		goto error;

	    /* Extract the quoted value string.  */
	    for ( ip=lbuf+8 ; *ip != '"' ; ip++ ) {
		if ( *ip == EOS ) goto error;
	    }
	    ip++;
	    op = ev_table[i].ev_value;
	    maxop = ev_table[i].ev_value + SZ_VALUE+1 -1;
	    for ( ; op < maxop && *ip != '"' ; op++, ip++ ) {
		if ( *ip == EOS ) goto error;
		*op = *ip;
	    }
	    *op = EOS;
	}

	if (fgets (lbuf, SZ_LINE+1, fp) == NULL)
	    goto error;
	if (strncmp (lbuf, delim, len_delim) != 0)
	    goto error;

	fclose (fp);
	return (OK);
error:
	fprintf (stderr, "os.zgtenv: error scanning `%s'\n", fname);
	fclose (fp);
	return (ERR);
}


#define	to_lower(c)        ((c)+'a'-'A')

/* EV_STREQ -- Compare two strings for equality, ignoring case.  The logical
 * names are given in upper case in <iraf.h> since they are presented as
 * macro defines.
 */
static int _ev_streq ( const char *s1, const char *s2, int n )
{
	int ch1, ch2;

	for ( ; 0 < n ; n-- ) {
	    ch1 = *s1++;
	    if (isupper (ch1))
		ch1 = to_lower(ch1);
	    ch2 = *s2++;
	    if (isupper (ch2))
		ch2 = to_lower(ch2);
	    if (ch1 != ch2)
		return (0);
	}

	return (1);
}