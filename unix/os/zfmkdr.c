#include <stdio.h>
#define	import_kernel
#define	import_knames
#define import_spp
#include <iraf.h>

/* ZFMKDR -- Create a new directory.
 */
ZFMKDR (newdir, status)
PKCHAR	*newdir;
XINT	*status;
{
	char	osdir[SZ_PATHNAME];
	register char *ip, *op;

	/* Change pathnames like "a/b/c/" to "a/b/c".  Probably not necessary,
	 * but...
	 */
	for (ip=(char *)newdir, op=osdir;  (*op = *ip++) != EOS;  op++)
	    ;
	if (*--op == '/')
	    *op = EOS;

	if (mkdir (osdir, 0755) == ERR)
	    *status = XERR;
	else
	    *status = XOK;
}
