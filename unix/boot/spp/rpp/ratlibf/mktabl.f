      INTEGER FUNCTION MKTABL (NODSIZ)
      INTEGER NODSIZ
      INTEGER MEM( 1)
      COMMON/CDSMEM/MEM
      INTEGER ST
      INTEGER DSGET
      INTEGER I
      ST = DSGET (43 + 1)
      MEM (ST) = NODSIZ
      MKTABL = ST
      DO 23000 I = 1, 43
      ST = ST + 1
      MEM (ST) = 0
23000 CONTINUE
23001 CONTINUE
      RETURN
      END
