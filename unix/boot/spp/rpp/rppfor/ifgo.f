      SUBROUTINE IFGO (LAB)
      INTEGER LAB
      COMMON /CDEFIO/ BP, BUF (4096)
      INTEGER BP
      INTEGER BUF
      COMMON /CFNAME/ FCNAME (30)
      INTEGER FCNAME
      COMMON /CFOR/ FORDEP, FORSTK (200)
      INTEGER FORDEP
      INTEGER FORSTK
      COMMON /CGOTO/ XFER
      INTEGER XFER
      COMMON /CLABEL/ LABEL, RETLAB, MEMFLG, COL, LOGIC0
      INTEGER LABEL
      INTEGER RETLAB
      INTEGER MEMFLG
      INTEGER COL
      INTEGER LOGIC0
      COMMON /CLINE/ LEVEL, LINECT (5), INFILE (5), FNAMP, FNAMES ( 150)
      INTEGER LEVEL
      INTEGER LINECT
      INTEGER INFILE
      INTEGER FNAMP
      INTEGER FNAMES
      COMMON /CMACRO/ CP, EP, EVALST (500), DEFTBL
      INTEGER CP
      INTEGER EP
      INTEGER EVALST
      INTEGER DEFTBL
      COMMON /COUTLN/ OUTP, OUTBUF (74)
      INTEGER OUTP
      INTEGER OUTBUF
      COMMON /CSBUF/ SBP, SBUF(2048), SMEM(240)
      INTEGER SBP
      INTEGER SBUF
      INTEGER SMEM
      COMMON /CSWTCH/ SWTOP, SWLAST, SWSTAK(1000), SWVNUM, SWVLEV, SWVST
     *K(10), SWINRG
      INTEGER SWTOP
      INTEGER SWLAST
      INTEGER SWSTAK
      INTEGER SWVNUM
      INTEGER SWVLEV
      INTEGER SWVSTK
      INTEGER SWINRG
      COMMON /CKWORD/ RKWTBL
      INTEGER RKWTBL
      COMMON /CLNAME/ FKWTBL, NAMTBL, GENTBL, ERRTBL, XPPTBL
      INTEGER FKWTBL
      INTEGER NAMTBL
      INTEGER GENTBL
      INTEGER ERRTBL
      INTEGER XPPTBL
      COMMON /ERCHEK/ ERNAME, BODY, ESP, ERRSTK(30)
      INTEGER ERNAME
      INTEGER BODY
      INTEGER ESP
      INTEGER ERRSTK
      INTEGER MEM( 60000)
      COMMON/CDSMEM/MEM
      INTEGER IFNOT(10)
      INTEGER SERRC0(21)
      DATA IFNOT(1)/105/,IFNOT(2)/102/,IFNOT(3)/32/,IFNOT(4)/40/,IFNOT(5
     *)/46/,IFNOT(6)/110/,IFNOT(7)/111/,IFNOT(8)/116/,IFNOT(9)/46/,IFNOT
     *(10)/-2/
      DATA SERRC0(1)/46/,SERRC0(2)/97/,SERRC0(3)/110/,SERRC0(4)/100/,SER
     *RC0(5)/46/,SERRC0(6)/40/,SERRC0(7)/46/,SERRC0(8)/110/,SERRC0(9)/11
     *1/,SERRC0(10)/116/,SERRC0(11)/46/,SERRC0(12)/120/,SERRC0(13)/101/,
     *SERRC0(14)/114/,SERRC0(15)/102/,SERRC0(16)/108/,SERRC0(17)/103/,SE
     *RRC0(18)/41/,SERRC0(19)/41/,SERRC0(20)/32/,SERRC0(21)/-2/
      CALL OUTTAB
      CALL OUTSTR (IFNOT)
      CALL BALPAR
      IF (.NOT.(ERNAME .EQ. 1))GOTO 23000
      CALL OUTSTR (SERRC0)
      GOTO 23001
23000 CONTINUE
      CALL OUTCH (41)
      CALL OUTCH (32)
23001 CONTINUE
      CALL OUTGO (LAB)
      CALL ERRGO
      END
C     LOGIC0  LOGICAL_COLUMN
C     SERRC0  SERRCHK
