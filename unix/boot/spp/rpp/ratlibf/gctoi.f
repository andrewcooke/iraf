      INTEGER FUNCTION GCTOI (STR, I, RADIX)
      INTEGER STR (100)
      INTEGER I, RADIX
      INTEGER BASE, V, D, J
      EXTERNAL INDEX
      INTEGER INDEX
      INTEGER CLOWER
      LOGICAL NEG
      INTEGER DIGITS(17)
      DATA DIGITS(1)/48/,DIGITS(2)/49/,DIGITS(3)/50/,DIGITS(4)/51/,DIGIT
     *S(5)/52/,DIGITS(6)/53/,DIGITS(7)/54/,DIGITS(8)/55/,DIGITS(9)/56/,D
     *IGITS(10)/57/,DIGITS(11)/97/,DIGITS(12)/98/,DIGITS(13)/99/,DIGITS(
     *14)/100/,DIGITS(15)/101/,DIGITS(16)/102/,DIGITS(17)/-2/
      V = 0
      BASE = RADIX
23000 IF (.NOT.(STR (I) .EQ. 32 .OR. STR (I) .EQ. 9))GOTO 23001
      I = I + 1
      GOTO 23000
23001 CONTINUE
      NEG = (STR (I) .EQ. 45)
      IF (.NOT.(STR (I) .EQ. 43 .OR. STR (I) .EQ. 45))GOTO 23002
      I = I + 1
23002 CONTINUE
      IF (.NOT.(STR (I + 2) .EQ. 114 .AND. STR (I) .EQ. 49 .AND. (48.LE.
     *STR (I + 1).AND.STR (I + 1).LE.57) .OR. STR (I + 1) .EQ. 114 .AND.
     * (48.LE.STR (I).AND.STR (I).LE.57)))GOTO 23004
      BASE = STR (I) - 48
      J = I
      IF (.NOT.(STR (I + 1) .NE. 114))GOTO 23006
      J = J + 1
      BASE = BASE * 10 + (STR (J) - 48)
23006 CONTINUE
      IF (.NOT.(BASE .LT. 2 .OR. BASE .GT. 16))GOTO 23008
      BASE = RADIX
      GOTO 23009
23008 CONTINUE
      I = J + 2
23009 CONTINUE
23004 CONTINUE
23010 IF (.NOT.(STR (I) .NE. -2))GOTO 23012
      IF (.NOT.((48.LE.STR (I).AND.STR (I).LE.57)))GOTO 23013
      D = STR (I) - 48
      GOTO 23014
23013 CONTINUE
      D = INDEX (DIGITS, CLOWER (STR (I))) - 1
23014 CONTINUE
      IF (.NOT.(D .LT. 0 .OR. D .GE. BASE))GOTO 23015
      GOTO 23012
23015 CONTINUE
      V = V * BASE + D
23011 I = I + 1
      GOTO 23010
23012 CONTINUE
      IF (.NOT.(NEG))GOTO 23017
      GCTOI=(-V)
      RETURN
23017 CONTINUE
      GCTOI=(+V)
      RETURN
23018 CONTINUE
      END
