# POLYPHOT header file

define	LEN_PYSTRUCT	(25 + SZ_FNAME + 1)

# polygon parameters

define	AP_PYXMEAN	Memr[$1]	# Original mean X of polygon
define	AP_PYYMEAN	Memr[$1+1]	# Original mean Y of polygon
define  AP_PYCX		Memr[$1+2]	# Current mean X of polygon
define	AP_PYCY		Memr[$1+3]	# Current mean Y of polygon
define	AP_PYX		Memr[$1+4]	# Previous mean x of polygon
define	AP_PYY		Memr[$1+5]	# Previous mean y of polygon
define	AP_PYNVER	Memi[$1+6]	# Number of vertices
define	AP_PYMINRAD	Memr[$1+7]	# Minimum sky fitting radius in scale

# polyphot answers

define	AP_PYFLUX	Memr[$1+8]	# Flux
define	AP_PYNPIX	Memr[$1+9]	# Polygon area
define	AP_PYMAG	Memr[$1+10]	# Magnitude
define	AP_PYMAGERR	Memr[$1+11]	# Magnitude error

# polyphot parameters

define	AP_PYZMAG	Memr[$1+15]		# Zero point of mag scale
define	AP_PYNAME	Memc[P2C($1+21)]	# Polygons file name

# polyphot defaults

define	DEF_PYZMAG	26.0
