      INTEGER FUNCTION INDEX (STR, C)
      INTEGER STR (100), C
      INDEX = 1
23000 IF (.NOT.(STR (INDEX) .NE. -2))GOTO 23002
      IF (.NOT.(STR (INDEX) .EQ. C))GOTO 23003
      RETURN
23003 CONTINUE
23001 INDEX = INDEX + 1
      GOTO 23000
23002 CONTINUE
      INDEX = 0
      RETURN
      END
