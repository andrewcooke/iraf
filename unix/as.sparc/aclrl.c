#define import_spp
#define import_knames
#include <iraf.h>

/* ACLRL -- Clear a block of memory.
 * [Specially optimized for Sun/IRAF].
 */
ACLRL (a, n)
XLONG	*a;
XINT	*n;
{
	bzero ((char *)a, *n * sizeof(*a));
}
