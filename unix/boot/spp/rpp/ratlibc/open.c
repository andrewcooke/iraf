#include "ratdef.h"

FINT
OPEN(rname, mode)
RCHAR *rname;
register FINT *mode;
{
	register FILE  *fp;
	char	       cname[FILENAMESIZE];

	r4tocstr(rname, cname);

	if (*mode == APPEND)
		fp = fopen(cname, "a");
	else if (*mode == READWRITE || *mode == WRITE)
		fp = fopen(cname, "w");
	else
		fp = fopen(cname, "r");

	if (fp == NULL)
		return(RERR);	/* unable to open file */

	_fdtofile[fileno(fp)] = fp;
	return(fileno(fp));
}
