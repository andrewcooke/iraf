# definitions for the gsurfit package

# define the permitted types of curves

define	GS_CHEBYSHEV	1
define	GS_LEGENDRE	2
define	GS_POLYNOMIAL	3
define	NTYPES		3

# define the weighting flags

define	WTS_USER	1	# user enters weights
define	WTS_UNIFORM	2	# equal weights
define	WTS_SPACING	3	# weight proportional to spacing of data points

# error conditions

define	SINGULAR	1
define	NO_DEG_FREEDOM	2

# gsstat definitions

define	GSTYPE		1
define	GSXORDER	2
define	GSYORDER	3
define	GSXTERMS	4
define	GSNXCOEFF	5
define	GSNYCOEFF	6
define	GSNCOEFF	7
define	GSNSAVE		8
define	GSXMIN		9
define	GSXMAX		10
define	GSYMIN		11
define	GSYMAX		12

define	GS_SAVECOEFF	8
