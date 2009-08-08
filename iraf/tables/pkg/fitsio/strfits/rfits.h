# FITS Definitions

# The FITS standard readable by the FITS reader using these definitions:
# 
# 1.  8 bits / byte
# 2.  ASCII character code
# 3.  MII data format (i.e. 8 bit unsigned integers and 16 and 32 bit signed
#     twos complement integers with most significant bytes first.)
#     See mii.h.
#
# The following deviations from the FITS standard are allowed:
# 
# The number of FITS bytes per record is normally 2880 but may be specified
# by the user.

# Define the bits per pixel and precision of the 3 basic FITS types

define	SZ_MAXCOL	999	# Maximum number of columns

define	FITS_BYTE	8	# Bits in a FITS byte
define	FITS_SHORT	16	# Bits in a FITS short
define	FITS_LONG	32	# Bits in a FITS long
define	FITS_LONGLONG	64	# Bits in a FITS longlong

define	FITSB_PREC	3	# Decimal digits of precision in a FITS byte
define	FITSS_PREC	5	# Decimal digits of precision in a FITS short
define	FITSL_PREC	10	# Decimal digits of precision in a FITS long
define	FITSLL_PREC	19	# Decimal digits of precision in a FITS longlong

define	LSBF		NO	# Least significant byte first
define	LEN_CARD	80	# Length of FITS card in characters
define	COL_VALUE	11	# Starting column for parameter values


define  IM_MAXDIM	7
define	SZ_OBJECT	79
define	SZ_EXTN		31	# default extension size
define	DEF_GPB		1	# gkey value for default group parameter desc.
define	NONDEF_GPB	2       # Non default gpb desc.; needs template
define	NON_GPB		3       # For image w/o gpb
define  TO_MG		4       # For immediate FITS w/xdim to multigroup.
define	IMAGE		5
define	IMH		6
define	TO_FITS		7

# Values for the following keywords are stored in the structure below.
define	MAX_PCSTF	7		# max param descriptors for STF files
define	LEN_PDSTF	70

define	LEN_FITS	(67 + 2*70 + 1 + MAX_PCSTF*LEN_PDSTF)

define  FITS_BSCALE     Memd[P2D($1)]         # FITS scaling parameter
define  FITS_BZERO      Memd[P2D($1+2)]       # FITS zero parameter
define  BLANK_VALUE     Meml[P2L($1+4)]       # Blank value
define  BLANKS          Memi[P2I($1+5)]       # YES if blank keyword in header
define  BITPIX          Memi[P2I($1+6)]       # Bits per pixel (Must be an MII type)
define  SCALE           Memi[P2I($1+7)]       # Scale the data?
define  SIMPLE          Memi[P2I($1+8)]       # Standard FITS format 
define  NRECORDS        Meml[P2L($1+9)]       # Number of FITS logical records
define  EXTEND          Memi[P2I($1+10)]      # Standard extension flag (tables)
define  SDASMGNU        Memi[P2I($1+11)]      # SDASMGNU keyword present
define  FITS_NROWS      Meml[P2L($1+12)]      # Number of lines in table
define  FITS_ROWLEN     Meml[P2L($1+13)]      # Number of character per row
define  NAXIS           Memi[P2I($1+14)]      # Number of dimensions 
define  NAXISN          Meml[P2L($1+15)+$2-1] # Length of each axis (up to 7)
define  GCOUNT          Memi[P2I($1+23)]
define  OPSIZE          Memi[P2I($1+24)]
define  FITS_XTEN       Memi[P2I($1+25)]      # Kind of FITS Xtension (TABLE, BINTABLE
                                              # or IMAGE).
# extra space
define  DATE            Memc[P2C($1+48)]
define  FITSTYPE        Memc[P2C($1+57)]
define  MAKE_CD         Memi[P2I($1+64)]
define  OBJECT          Memc[P2C($1+67)]      # Up to 70 characters long
define  IRAFNAME        Memc[P2C($1+138)]     # idem

# temporary storage for wcs information to be put on the STF files rigth
# before closing the images.
define	WCS_PDES	(($1) + 67 + 2*70 + ((($2)-1)*LEN_PDSTF))

define	SZ_WCSCTYPE	8
# GPB Parameter descriptor.
define  CRVAL           Memd[P2D($1)]
define  CRPIX           Memr[P2R($1+2)]
define  CDELT           Memd[P2D($1+4)]
define  CROTA           Memd[P2D($1+6)]
define  CDMATRIX        Memr[P2R($1+8)+($2-1)*7]
define  CTYPE           Memc[P2C($1+61)]

# Setup for FITS extensions

define	LEN_EXTENSION   (19 + SZ_FNAME)

define  EXT_BITPIX      Memi[P2I($1)]    # BITPIX value for extension
define  EXT_ROWLEN      Meml[P2L($1+2)]  # Number characters per row
define  EXT_NROWS       Meml[P2L($1+3)]  # Number of rows in table extension
define  EXT_PBCOL       Memp[$1+4]       # Pointer the array of columns
define  EXT_PCW         Memp[$1+5]       # Pointer to array of column widths
define  EXT_PNULL       Memp[$1+6]       # Pointer to array of null values
define  EXT_PZERO       Memp[$1+7]       # Pointer to array of zero offsets
define  EXT_PSCAL       Memp[$1+8]       # Pointer to array of scaling values
define  EXT_PUNIT       Memp[$1+9]       # Pointer to array of TUNITs values.
define  EXT_PTYPE       Memp[$1+10]      # Pointer to array of TTYPEs values.
define  EXT_PDTYPE      Memp[$1+11]      # Pointer to array of Tdatatype values.
define  EXT_PDSIZE      Memp[$1+12]      # Pointer to array of Tdatatype sizes
                                         # or number of elements for a BINTABlE
                                         # column.
define  EXT_PFORM       Memp[$1+13]      # Pointer to array of TFORMs values.
define  EXT_PDISP       Memp[$1+14]      # Pointer to array of TDISP values.
define  EXTVER          Memi[P2I($1+15)] # External version of extension
define  BIN_DTYNSP      Memb[P2B($1+16)] # Flag to BINTABLE datype not supported.
define  TAB_TYPE        Memi[P2I($1+17)] # ST Table type (tab or ascii)
define  BIN_MAXLEN      Memi[P2I($1+18)] # Maximun number of characters for a
                                         # character col in a BINTABLE.
define  EXTNAME         Memc[P2C($1+19)] # Name of file with Extension

define	TABLE		1
define	BINTABLE	2

define  BYTE2SHORT	1
define  SHORT2INT	2
define  SHORT2REAL	3
define  INT2REAL	4
define  LONG2REAL	5

# if the extension is a TABLE it can be converted to 3 types.
define  TRAILER_FILE	1
define  TXT_FILE	2
define	SDAS_TABLE	3

# Additional IRAF header parameters

define	PIXTYPE		IM_PIXTYPE($1)
define	NBPIX		IM_NBPIX($1)
define	IRAFMAX		IM_MAX($1)
define	IRAFMIN		IM_MIN($1)
define	LIMTIME		IM_LIMTIME($1)

# Mapping of FITS Keywords to IRAF image header

define	SZ_OBJECT	SZ_IMTITLE
define	SZ_HISTORY	SZ_IMHIST
define	SZ_FCTYPE	SZ_CTYPE

define  ENAXIS	1
define  ENAXISN	2
define  ECRVAL	3
define  ECRPIX	4
define  ECDELT	5
define  ECROTA	6
define  ECTYPE	7
define  ECD1	8
define  ECD2	9

# List of text extensions

define	TEXT_EXTLIST  "|trl|txt|log|ocx|pdq|pod|cmh|trx|rpt|cgr|dgr|dta|poa"
