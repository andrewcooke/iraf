# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include <time.h>
include "wfits.h"

# WFT_ENCODEB -- Procedure to encode a boolean parameter into a FITS card.

procedure wft_encodeb (keyword, param, card, comment)

char	keyword[ARB]	# FITS keyword
int	param		# integer parameter equal to YES/NO
char	card[ARB]	# FITS card image
char	comment[ARB]	# FITS comment string

char	truth

begin
	if (param == YES)
	    truth = 'T'
	else
	    truth = 'F'

	call sprintf (card, LEN_CARD, "%-8.8s= %20c  /  %-45.45s")
	    call pargstr (keyword)
	    call pargc (truth)
	    call pargstr (comment)
end


# WFT_ENCODEI -- Procedure to encode an integer parameter into a FITS card.

procedure wft_encodei (keyword, param, card, comment)

char	keyword[ARB]	# FITS keyword
int	param		# integer parameter
char	card[ARB]	# FITS card image
char	comment[ARB]	# FITS comment string

begin
	call sprintf (card, LEN_CARD, "%-8.8s= %20d  /  %-45.45s")
	    call pargstr (keyword)
	    call pargi (param)
	    call pargstr (comment)
end


# WFT_ENCODEL -- Procedure to encode a long parameter into a FITS card.

procedure wft_encodel (keyword, param, card, comment)

char	keyword[ARB]		# FITS keyword
long	param			# long integer parameter
char	card[ARB]		# FITS card image
char	comment[ARB]		# FITS comment string

begin
	call sprintf (card, LEN_CARD, "%-8.8s= %20d  /  %-45.45s")
	    call pargstr (keyword)
	    call pargl (param)
	    call pargstr (comment)
end


# WFT_ENCODER -- Procedure to encode a real parameter into a FITS card.

procedure wft_encoder (keyword, param, card, comment, precision)

char	keyword[ARB]		# FITS keyword
real	param			# real parameter
char	card[ARB]		# FITS card image
char	comment[ARB]		# FITS comment card
int	precision		# precision of real

begin
	call sprintf (card, LEN_CARD, "%-8.8s= %20.*e  /  %-45.45s")
	    call pargstr (keyword)
	    call pargi (precision)
	    call pargr (param)
	    call pargstr (comment)
end


# WFT_ENCODED -- Procedure to encode a double parameter into a FITS card.

procedure wft_encoded (keyword, param, card, comment, precision)

char	keyword[ARB]		# FITS keyword
double	param			# double parameter
char	card[ARB]		# FITS card image
char	comment[ARB]		# FITS comment string
int	precision		# FITS precision

begin
	call sprintf (card, LEN_CARD, "%-8.8s= %20.*e  /  %-45.45s")
	    call pargstr (keyword)
	    call pargi (precision)
	    call pargd (param)
	    call pargstr (comment)
end


# WFT_ENCODE_AXIS -- Procedure to add the axis number to axis dependent
# keywords.

procedure wft_encode_axis (root, keyword, axisno)

char	root[ARB]		# FITS root keyword
char	keyword[ARB]		# FITS keyword
int	axisno			# FITS axis number

begin
	call strcpy (root, keyword, LEN_KEYWORD)
	call sprintf (keyword, LEN_KEYWORD, "%-5.5s%-3.3s")
	    call pargstr (root)
	    call pargi (axisno)
end


# WFT_ENCODEC -- Procedure to encode an IRAF string parameter into a FITS card.

procedure wft_encodec (keyword, param, maxch, card, comment)

char	keyword[ARB]	# FITS keyword
char	param[ARB]	# FITS string parameter
int	maxch		# maximum number of characters in string parameter
char	card[ARB]	# FITS card image
char	comment[ARB]	# comment string

int	nblanks, maxchar

begin
	maxchar = min (maxch, LEN_OBJECT)
	nblanks = LEN_OBJECT - maxchar
        call sprintf (card, LEN_CARD, "%-8.8s= '%*.*s'  /  %*.*s")
	    call pargstr (keyword)
	    call pargi (-maxchar)
	    call pargi (maxchar)
	    call pargstr (param)
	    call pargi (-nblanks)
	    call pargi (nblanks)
	    call pargstr (comment)
end


# WFT_ENCODE_BLANK -- Procedure to encode the FITS blank parameter. Necessary
# because the 32 bit blank value equals INDEFL.

procedure wft_encode_blank (keyword, blank_str, card, comment)

char	keyword[ARB]		# FITS keyword
char	blank_str[ARB]		# string containing values of FITS blank integer
char	card[ARB]		# FITS card image
char	comment[ARB]		# FITS comment string

begin
    call sprintf (card, LEN_CARD, "%-8.8s= %20.20s  /  %-45.45s")
	call pargstr (keyword)
	call pargstr (blank_str)
	call pargstr (comment)
end


# WFT_ENCODE_DATE -- Procedure to encode the date in the form dd-mm-yy.

procedure wft_encode_date (datestr, szdate)

char	datestr[ARB]	# string containing the date
int	szdate		# number of chars in the date string

long	ctime
int	time[LEN_TMSTRUCT]
long	clktime()

begin
	ctime = clktime (long (0))
	call brktime (ctime, time)

	call sprintf (datestr, szdate, "%02s-%02s-%02s")
	    call pargi (TM_MDAY(time))
	    call pargi (TM_MONTH(time))
	    call pargi (mod (TM_YEAR(time), CENTURY))
end


# WFT_FITS_CARD --  Procedure to fetch a single line from a string parameter
# padding it to a maximum of maxcols characters and trimmimg the delim
# character.

procedure wft_fits_card (instr, ip, card, col_out, maxcols, delim)

char	instr[ARB]	# input string
int	ip		# input string pointer, updated at each call
char	card[ARB]	# FITS card image
int	col_out		# pointer to column in card
int	maxcols		# maximum columns in card
int	delim		# 1 character string delimiter

int	op

begin
	op = col_out

	# Copy string
	while (op <= maxcols && instr[ip] != EOS && instr[ip] != delim) {
	    card[op] = instr[ip]
	    ip = ip + 1
	    op = op + 1
	}

	# Fill remainder of card with blanks
	while (op <= maxcols ) {
	    card[op] = ' '
	    op = op + 1
	}

	if (instr[ip] == delim)
	    ip = ip + 1

end
