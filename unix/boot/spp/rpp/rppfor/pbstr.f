      SUBROUTINE PBSTR (S)
      INTEGER S(100)
      INTEGER LENSTR, I
      INTEGER LENGTH
      LENSTR = LENGTH (S)
      IF (.NOT.(S(1) .EQ. 46 .AND. S(LENSTR) .EQ. 46))GOTO 23000
      IF (.NOT.(LENSTR .EQ. 4))GOTO 23002
      IF (.NOT.(S(2) .EQ. 103))GOTO 23004
      IF (.NOT.(S(3) .EQ. 116))GOTO 23006
      CALL PUTBAK (62)
      RETURN
23006 CONTINUE
      IF (.NOT.(S(3) .EQ. 101))GOTO 23008
      CALL PUTBAK (61)
      CALL PUTBAK (62)
      RETURN
23008 CONTINUE
23007 CONTINUE
      GOTO 23005
23004 CONTINUE
      IF (.NOT.(S(2) .EQ. 108))GOTO 23010
      IF (.NOT.(S(3) .EQ. 116))GOTO 23012
      CALL PUTBAK (60)
      RETURN
23012 CONTINUE
      IF (.NOT.(S(3) .EQ. 101))GOTO 23014
      CALL PUTBAK (61)
      CALL PUTBAK (60)
      RETURN
23014 CONTINUE
23013 CONTINUE
      GOTO 23011
23010 CONTINUE
      IF (.NOT.(S(2) .EQ. 101 .AND. S(3) .EQ. 113))GOTO 23016
      CALL PUTBAK (61)
      CALL PUTBAK (61)
      RETURN
23016 CONTINUE
      IF (.NOT.(S(2) .EQ. 110 .AND. S(3) .EQ. 101))GOTO 23018
      CALL PUTBAK (61)
      CALL PUTBAK (33)
      RETURN
23018 CONTINUE
      IF (.NOT.(S(2) .EQ. 111 .AND. S(3) .EQ. 114))GOTO 23020
      CALL PUTBAK (124)
      RETURN
23020 CONTINUE
23019 CONTINUE
23017 CONTINUE
23011 CONTINUE
23005 CONTINUE
      GOTO 23003
23002 CONTINUE
      IF (.NOT.(LENSTR .EQ. 5))GOTO 23022
      IF (.NOT.(S(2) .EQ. 110 .AND. S(3) .EQ. 111 .AND. S(4) .EQ. 116))G
     *OTO 23024
      CALL PUTBAK (33)
      RETURN
23024 CONTINUE
      IF (.NOT.(S(2) .EQ. 97 .AND. S(3) .EQ. 110 .AND. S(4) .EQ. 100))GO
     *TO 23026
      CALL PUTBAK (38)
      RETURN
23026 CONTINUE
23025 CONTINUE
23022 CONTINUE
23003 CONTINUE
23000 CONTINUE
      I=LENSTR
23028 IF (.NOT.(I .GT. 0))GOTO 23030
      CALL PUTBAK (S(I))
23029 I=I-1
      GOTO 23028
23030 CONTINUE
      END
