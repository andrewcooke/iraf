      subroutine doarth (argstk, i, j)
      integer argstk (100), i, j
      common /cdefio/ bp, buf (4096)
      integer bp
      integer buf
      common /cfname/ fcname (30)
      integer fcname
      common /cfor/ fordep, forstk (200)
      integer fordep
      integer forstk
      common /cgoto/ xfer
      integer xfer
      common /clabel/ label, retlab, memflg, col, logic0
      integer label
      integer retlab
      integer memflg
      integer col
      integer logic0
      common /cline/ level, linect (5), infile (5), fnamp, fnames ( 150)
      integer level
      integer linect
      integer infile
      integer fnamp
      integer fnames
      common /cmacro/ cp, ep, evalst (500), deftbl
      integer cp
      integer ep
      integer evalst
      integer deftbl
      common /coutln/ outp, outbuf (74)
      integer outp
      integer outbuf
      common /csbuf/ sbp, sbuf(2048), smem(240)
      integer sbp
      integer sbuf
      integer smem
      common /cswtch/ swtop, swlast, swstak(1000), swvnum, swvlev, swvst
     *k(10), swinrg
      integer swtop
      integer swlast
      integer swstak
      integer swvnum
      integer swvlev
      integer swvstk
      integer swinrg
      common /ckword/ rkwtbl
      integer rkwtbl
      common /clname/ fkwtbl, namtbl, gentbl, errtbl, xpptbl
      integer fkwtbl
      integer namtbl
      integer gentbl
      integer errtbl
      integer xpptbl
      common /erchek/ ername, body, esp, errstk(30)
      integer ername
      integer body
      integer esp
      integer errstk
      integer mem( 60000)
      common/cdsmem/mem
      integer k, l
      integer ctoi
      integer op
      k = argstk (i + 2)
      l = argstk (i + 4)
      op = evalst (argstk (i + 3))
      if (.not.(op .eq. 43))goto 23000
      call pbnum (ctoi (evalst, k) + ctoi (evalst, l))
      goto 23001
23000 continue
      if (.not.(op .eq. 45))goto 23002
      call pbnum (ctoi (evalst, k) - ctoi (evalst, l))
      goto 23003
23002 continue
      if (.not.(op .eq. 42 ))goto 23004
      call pbnum (ctoi (evalst, k) * ctoi (evalst, l))
      goto 23005
23004 continue
      if (.not.(op .eq. 47 ))goto 23006
      call pbnum (ctoi (evalst, k) / ctoi (evalst, l))
      goto 23007
23006 continue
      call remark (11Harith error)
23007 continue
23005 continue
23003 continue
23001 continue
      return
      end
c     logic0  logical_column
