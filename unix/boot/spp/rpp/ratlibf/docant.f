      SUBROUTINE DOCANT(NAME)
      INTEGER NAME(100), PROG(30)
      INTEGER LENGTH
      INTEGER GETARG
      LENGTH = GETARG(0, PROG, 30)
      IF (.NOT.(LENGTH .NE. -1))GOTO 23000
      CALL PUTLIN(PROG, 2)
      CALL PUTCH(58, 2)
      CALL PUTCH(32, 2)
23000 CONTINUE
      CALL CANT(NAME)
      RETURN
      END
