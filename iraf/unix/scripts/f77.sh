#!/bin/sh
#PATH=/v/bin:/bin:/usr/bin:/usr/local/bin
# f77-style shell script to compile and load fortran, C, and assembly codes
#	usage:	f77 [-g] [-O|-O[23456]] [-o absfile] [-c] files [-l library]
#		-o objfile	Override default executable name a.out.
#		-c		Do not call linker, leave relocatables in *.o.
#		-S		leave assembler output on file.s
#		-l library	(passed to ld).
#		-u		complain about undeclared variables
#		-w		omit all warning messages
#		-w66		omit Fortran 66 compatibility warning messages
#		-f*		pass thru gcc optimizer options
#		-W*		pass thru gcc warning options
#		files		FORTRAN source files ending in .f .
#				C source files ending in .c .
#				Assembly language files ending in .s .
#				efl source files ending in .e .
#		-I includepath	passed to C compiler (for .c files)
#		-Ntnnn		allow nnn entries in table t
#		-cpp -Dxxx	pipe through cpp
#
# [IRAF] -- For IRAF we had to modify the f77 script that came with Linux
# to remove the "f2ctmp_XX" prefix that the script was adding to the Fortran
# file names when compiling.  The main problem with this is that it prevents
# source code debugging from working since the file that was compiled (e.g.
# f2ctmp_foo.f) no longer exists at run time.  A lesser problem was that the
# code which deletes the f2ctmp_ files would return an exit 4 status, causing
# problems with XC (XC was modified for Linux to ignore this but it is still
# a bug with the f77 script).  NOTE -- the old behavior is still present if
# the Fortran file has a .F extension.  The modified (no f2ctmp_) behavior is
# for .f files.

iraf="`echo $iraf/ | tr -s '/'`"

s=/tmp/stderr_$$
t=/tmp/f77_$$
#CC=${CC_f2c:-'/usr/bin/cc -m486'}
CC=${CC_f2c:-'gcc'}
#CFLAGS=${CFLAGS:-"-I${iraf}unix/include"}
CFLAGS=${CFLAGS}
EFL=${EFL:-/v/bin/efl}
EFLFLAGS=${EFLFLAGS:-'system=portable deltastno=10'}
F2C=${F2C:-/usr/bin/f2c}
F2CFLAGS=${F2CFLAGS:='-ARw8 -Nn802'}
keepc=0
warn=1
xsrc=0
rc=0
#lib=/lib/num/lib.lo
trap "rm -f $s ; exit \$rc" 0
OUTF=a.out
cOPT=1
G=
CPP=cat
CPPFLAGS=
# set -- `getopt cD:gI:N:Oo:Suw6 "$@"`
case $? in 0);; *) exit 1;; esac
while
	test X"$1" != X--
do
	case "$1"
	in
	-b)	CFLAGS="$CFLAGS -b $2"
		shift 2
		;;

	-K)	keepc=1
		shift
		;;

	-c)	cOPT=0
		shift
		;;

	-D)	CPPFLAGS="$CPPFLAGS -D$2"
		shift 2
		;;

	-D*)	CPPFLAGS="$CPPFLAGS $1"
		shift 1
		;;

	-f2c)	F2C="$2"
		shift 2
		;;

	-f*)	CFLAGS="$CFLAGS $1"
		shift 1
		;;

	-g)	CFLAGS="$CFLAGS -g"
		F2CFLAGS="$F2CFLAGS -g"
		G="-g"
		shift;;

	-I)	CFLAGS="$CFLAGS -I$2"
		shift 2
		;;

	-I*)	CFLAGS="$CFLAGS $1"
		shift 1
		;;

	-m*)	CFLAGS="$CFLAGS $1"
		shift 1
		;;

	-o)	OUTF=$2
		shift 2
		;;

	-O*)
		CFLAGS="$CFLAGS $1"
		shift
		;;

	-arch)	CFLAGS="$CFLAGS -arch $2"
		shift 2
		;;

	-U)	CFLAGS="$CFLAGS -arch ppc -arch i386"
		shift
		;;

	-u)	F2CFLAGS="$F2CFLAGS -u"
		shift
		;;

	-W*)	CFLAGS="$CFLAGS $1"
		warn=1
		shift 1
		;;

	-w)	F2CFLAGS="$F2CFLAGS -w"
		CFLAGS="$CFLAGS -w"
		warn=0
		case $2 in -6) F2CFLAGS="$F2CFLAGS"66; shift
			case $2 in -6) shift;; esac;; esac
		shift
		;;

	-x)	xsrc=1
		shift
		;;

	-N)	F2CFLAGS="$F2CFLAGS $1""$2"
		shift 2
		;;

	-N*|-C)	F2CFLAGS="$F2CFLAGS $1"
		shift 1
		;;

	-cpp)	CPP="/lib/cpp -traditional"
		shift 1
		;;

	-S)	CFLAGS="$CFLAGS -S"
		cOPT=0
		shift
		;;

	-*)
		echo "invalid parameter $1" 1>&2
		shift
		;;

	*)	set -- -- $@
		;;
	esac
done
shift

while
	test -n "$1"
do
	case "$1"
	in
	*.f)
		case "$1" in *.f) f=".f";; *.F) f=".F";; esac
		b=`basename $1 $f`
		if [ $warn = 0 ]; then
		    $F2C $F2CFLAGS $b.f 2>$s
		    sed '/^	arg .*: here/d' $s 1>&2
		else
		    $F2C $F2CFLAGS $b.f
		fi
		if [ $xsrc = 1 ]; then
		    sed -e "s/$b\\.f/$b.x/" < $b.c > $b.t; mv $b.t $b.c
		fi
		#
		# erase "/* Subroutine */ " comments
		#
		cat $b.c | sed -e 's|/\* Subroutine \*/ ||' > $b.t
		mv $b.t $b.c
		#
		# split comma-separated extern functions
		# i.e., extern int foo(...), boo(...);
		#       -> extern int foo(...); extern int boo(...);
		#
		while [ "`cat $b.c | grep 'extern [a-zA-Z0-9_][a-zA-Z0-9_]* [a-zA-Z0-9_][a-zA-Z0-9_]*([^()]*),'`" != "" ]; do
		  cat $b.c | sed -e 's/\(extern [a-zA-Z0-9_][a-zA-Z0-9_]* \)\([a-zA-Z0-9_][a-zA-Z0-9_]*([^()]*)\)\(, \)/\1\2; \1/g' > $b.t
		  mv $b.t $b.c
		done
		#
		if [ "$F2C_AUTO_INCLUDE" = "true" -a -f f2c_include.h ]; then
		  # erase extern prototypes
		  cat $b.c | sed -e 's/\(extern [a-zA-Z0-9_][a-zA-Z0-9_]* [a-zA-Z0-9_][a-zA-Z0-9_]*(\)\([^()]*\)\()\)//g' \
			         -e 's/#include [<"]f2c.h[>"]/#include "f2c_include.h"/' > $b.t
		  mv $b.t $b.c
		else
		  if [ "$F2C_AUTO_INCLUDE" = "true" ]; then
		    echo "WARNING: f2c_include.h is not found."
		  fi
		  # erase args of extern prototypes
		  # i.e., extenr int foo( int ); -> extern int foo();
		  cat $b.c | sed -e 's/\(extern [a-zA-Z0-9_][a-zA-Z0-9_]* [a-zA-Z0-9_][a-zA-Z0-9_]*(\)\([^()]*\)\()\)/\1\3/g' > $b.t
		  mv $b.t $b.c
		fi
		#
		# construct prototype declarations
		#
		NEW_PROTOS="`cat $b.c | grep -e '^[a-zA-Z0-9_][a-zA-Z0-9_]* [a-zA-Z0-9_][a-zA-Z0-9_]*_(.*)$'`"
		FUNC_GLIST="`echo \"$NEW_PROTOS\" | sed -e 's/^\([a-zA-Z0-9_][a-zA-Z0-9_]* \)\([a-zA-Z0-9_][a-zA-Z0-9_]*\)\((.*\)/\-e \[^a-zA-Z0-9_\]\2(/'`"
		if [ "$FUNC_GLIST" != "" ]; then
		  touch f2c_proto.h
		  cat f2c_proto.h | grep -v $FUNC_GLIST > f2c_proto.t
		  echo "$NEW_PROTOS" | sed -e 's/\(.*\)/extern \1;/' >> f2c_proto.t
		  mv f2c_proto.t f2c_proto.h
		fi
		#
		# display constant arguments on function
		#
		#grep -e 'static integer c__[0-9]' -e 'static integer c_n[0-9]' $b.c
		#
		# Compile
		#
		echo "$CC $CPPFLAGS -c $CFLAGS $b.c"
                $CC $CPPFLAGS -c $CFLAGS $b.c 2>$s
		rc=$?
		sed '/parameter .* is not referenced/d;/warning: too many parameters/d' $s 1>&2
		case $rc in 0);; *) exit 5;; esac
		if [ $keepc = 0 ]; then
		    rm -f $b.c
		fi
		OFILES="$OFILES $b.o"
		case $cOPT in 1) cOPT=2;; esac
		shift
		;;
	*.F)
		case "$1" in *.f) f=".f";; *.F) f=".F";; esac
		b=`basename $1 $f`
                trap "rm -f f2ctmp_$b.* ; exit 4" 0
                sed 's/\\$/\\-/;
                     s/^ *INCLUDE *'\(.*\)'.*$/#include "\1"/' $1 |\
		 $CPP $CPPFLAGS |\
		 egrep -v '^# ' > f2ctmp_$b.f
                trap "rm -f f2ctmp_$b.* ; exit 4" 0
		$F2C $F2CFLAGS f2ctmp_$b.f
		case $? in 0);; *) rm f2ctmp_* ; exit 5;; esac
                rm -f f2ctmp_$b.f
		mv f2ctmp_$b.c $b.c
		if [ -f f2ctmp_$b.P ]; then mv f2ctmp_$b.P $b.P; fi
		case $? in 0);; *) rm -f $b.c ; exit 5;; esac
                trap "rm -f $s ; exit 4" 0
                $CC $CPPFLAGS -c $CFLAGS $b.c 2>$s
		rc=$?
		sed '/parameter .* is not referenced/d;/warning: too many parameters/d' $s 1>&2
		case $rc in 0);; *) exit 5;; esac
		if [ $keepc = 0 ]; then
		    rm -f $b.c
		fi
		OFILES="$OFILES $b.o"
		case $cOPT in 1) cOPT=2;; esac
		shift
		;;
	*.e)
		b=`basename $1 .e`
		$EFL $EFLFLAGS $1 >$b.f
		case $? in 0);; *) exit;; esac
		$F2C $F2CFLAGS $b.f
		case $? in 0);; *) exit;; esac
                $CC -c $CFLAGS $b.c
		case $? in 0);; *) exit;; esac
		OFILES="$OFILES $b.o"
		rm $b.[cf]
		case $cOPT in 1) cOPT=2;; esac
		shift
		;;
	*.s)
		echo $1: 1>&2
		OFILE=`basename $1 .s`.o
		${AS:-/usr/bin/as} -o $OFILE $AFLAGS $1
		case $? in 0);; *) exit;; esac
		OFILES="$OFILES $OFILE"
		case $cOPT in 1) cOPT=2;; esac
		shift
		;;
	*.c)
		echo $1: 1>&2
		OFILE=`basename $1 .c`.o
                $CC -c $CFLAGS $CPPFLAGS $1
		rc=$?; case $rc in 0);; *) exit;; esac
		OFILES="$OFILES $OFILE"
		case $cOPT in 1) cOPT=2;; esac
		shift
		;;
	*.o)
		OFILES="$OFILES $1"
		case $cOPT in 1) cOPT=2;; esac
		shift
		;;
	-l)
		OFILES="$OFILES -l$2"
		shift 2
		case $cOPT in 1) cOPT=2;; esac
		;;
	-l*)
		OFILES="$OFILES $1"
		shift
		case $cOPT in 1) cOPT=2;; esac
		;;
	-o)
		OUTF=$2; shift 2;;
	*)
		OFILES="$OFILES $1"
		shift
		case $cOPT in 1) cOPT=2;; esac
		;;
	esac
done

case $cOPT in 2) $CC $G -o $OUTF $OFILES -lf2c -lm;; esac
rc=$?
exit $rc