#include <stdio.h>
#define	import_spp
#define	import_xnames
#include <iraf.h>

#define	isspace(c)	((c)==' '||(c)=='\t'||(c)=='\n')
#define	SETENV		"zzsetenv.def"
#define	SZ_VALUE	1024
#define	MAXLEV		8

extern	char *_os_getenv();
extern	char *os_getenv();
extern	char *os_strpak();
extern	char *vfn2osfn();
extern	int bdebug;


/* LOADPKGENV -- Load the environment definitions for the named package.
 * [e.g., loadpkgenv ("noao")].  This assumes that the root directory of
 * the named package is already defined, and that this directory contains
 * a subdirectory lib containing the file zzsetenv.def.  If none of these
 * assumptions are true, call loadenv(osfn) with the host filename of the
 * file to be loaded.
 */
loadpkgenv (pkg)
char	*pkg;
{
	char	osfn[SZ_PATHNAME+1];
	char	vfn[SZ_PATHNAME+1];

	_envinit();

	strcpy (vfn, pkg);
	strcat (vfn, "$lib/");
	strcat (vfn, SETENV);

	loadenv (vfn2osfn (vfn, 0));
}


#ifdef NOVOS
_envinit(){}
loadenv (osfn) char *osfn; { printf ("HSI is compiled NOVOS\n"); }
#else

/* ENVINIT -- Initialize the VOS environment list by scanning the file
 * hlib$zzsetenv.def.  HLIB is defined in terms of HOST which is sufficiently
 * well known to have a value before the environment list is loaded.
 */
_envinit()
{
	static	int initialized = 0;
	char	osfn[SZ_PATHNAME+1], *hlib;

	if (initialized++)
	    return;

	if (hlib = os_getenv ("hlib")) {
	    strcpy (osfn, hlib);
	    strcat (osfn, SETENV);
	} else {
	    printf (stderr, "cannot translate logical name `hlib'");
	    fflush (stdout);
	}

	ENVINIT();
	loadenv (osfn);
}


/* LOADENV -- Load environment definitions from the named host file.
 */
loadenv (osfn)
char	*osfn;
{
	register char	*ip;
	register XCHAR	*op;

	char	lbuf[SZ_LINE+1];
	char	pkname[SZ_FNAME+1], old_value[SZ_LINE+1];
	XCHAR	name[SZ_FNAME+1], value[SZ_VALUE+1];
	FILE	*fp, *sv_fp[MAXLEV];
	int	lev=0;

	if ((fp = fopen (osfn, "r")) == NULL) {
	    printf ("envinit: cannot open `%s'\n", osfn);
	    fflush (stdout);
	    return;
	}

	for (;;) {
	    /* Get next line from input file. */
	    if (fgets (lbuf, SZ_LINE, fp) == NULL) {
		/* End of file. */
		if (lev > 0) {
		    fclose (fp);
		    fp = sv_fp[--lev];
		    continue;
		} else
		    break;

	    } else {
		/* Skip comments and blank lines. */
		for (ip=lbuf;  isspace(*ip);  ip++)
		    ;
		if (strncmp (lbuf, "set", 3) != 0) {
		    if (strncmp (lbuf, "reset", 5) != 0)
			continue;
		    else
			ip += 5;
		} else
		    ip += 3;

		/* Check for @file inclusion. */
		while (isspace(*ip))
		    ip++;

		if (*ip == '@') {
		    sv_fp[lev++] = fp;
		    if (lev >= MAXLEV) {
			printf ("envinit: nesting too deep\n");
			fflush (stdout);
			break;

		    } else {
			char *fname = ++ip;

			while (*ip)
			    if (isspace(*ip)) {
				*ip = '\0';
				break;
			    } else
				ip++;

			if ((fp = fopen (vfn2osfn(fname,0), "r")) == NULL) {
			    printf ("envinit: cannot open `%s'\n", fname);
			    fflush (stdout);
			    break;
			}
		    }
		    continue;
		}

		/* fall through */
	    }

	    /* Extract name field. */
	    for (op=name;  *ip && *ip != '=' && !isspace(*ip);  op++)
		*op = *ip++;
	    *op = XEOS;

	    /* Extract value field; may be quoted.  Newline may be escaped
	     * to break a long value string over several lines of the input
	     * file.
	     */
	    for (;  *ip && *ip == '=' || *ip == '"' || isspace (*ip);  ip++)
		;
	    for (op=value;  *ip && *ip != '"' && *ip != '\n';  op++)
		if (*ip == '\\' && *(ip+1) == '\n') {
again:		    if (fgets (lbuf, SZ_LINE, fp) == NULL)
			break;
		    for (ip=lbuf;  isspace(*ip);  ip++)
			;
		    if (*ip == '#')
			goto again;
		} else
		    *op = *ip++;
	    *op = XEOS;

	    /* Allow the user to override the values of environment variables
	     * by defining them in their host environment.
	     */
	    os_strpak (name, pkname, SZ_FNAME);
	    if (_os_getenv (pkname, old_value, SZ_LINE)) {
		if (bdebug)
		    printf ("%s = %s\n", pkname, old_value);
	    } else
		ENVPUTS (name, value);
	}

	fclose (fp);
}
#endif
