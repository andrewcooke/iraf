#include "bootlib.h"

/*
 * OS_DIR -- A package for accessing a directory as a list of files.
 */

/* OS_DIROPEN -- Open the directory.
 */
os_diropen (dirname)
char	*dirname;
{
	PKCHAR	osfn[SZ_PATHNAME+1];
	XINT	chan;

	strcpy ((char *)osfn, dirname);
	ZOPDIR (osfn, &chan);

	return (chan);
}


/* OS_DIRCLOSE -- Close the directory.
 */
os_dirclose (chan)
int	chan;
{
	XINT	status;

	ZCLDIR (&chan, &status);
	return (status);
}


/* OS_GFDIR -- Get the next filename from the directory.
 */
os_gfdir (chan, fname, maxch)
int	chan;
char	*fname;
int	maxch;
{
	PKCHAR	osfn[SZ_PATHNAME+1];
	XINT	x_maxch, status;

	x_maxch = maxch;
	for (;;) {
	    ZGFDIR (&chan, osfn, &x_maxch, &status);
	    if (status > 0) {
		/* Omit the self referential directory files "." and ".."
		 * or recursion may result.
		 */
		if (strcmp ((char *)osfn, ".") == 0)
		    continue;
		if (strcmp ((char *)osfn, "..") == 0)
		    continue;

		strncpy (fname, osfn2vfn ((char *)osfn), maxch);
		return (status);

	    } else {
		/* End of directory.
		 */
		*fname = EOS;
		return (0);
	    }
	}
}
