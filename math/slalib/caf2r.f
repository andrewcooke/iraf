      SUBROUTINE slCAFR (IDEG, IAMIN, ASEC, RAD, J)
*+
*     - - - - - -
*      C A F R
*     - - - - - -
*
*  Convert degrees, arcminutes, arcseconds to radians
*  (single precision)
*
*  Given:
*     IDEG        int       degrees
*     IAMIN       int       arcminutes
*     ASEC        real      arcseconds
*
*  Returned:
*     RAD         real      angle in radians
*     J           int       status:  0 = OK
*                                    1 = IDEG outside range 0-359
*                                    2 = IAMIN outside range 0-59
*                                    3 = ASEC outside range 0-59.999...
*
*  Notes:
*
*  1)  The result is computed even if any of the range checks
*      fail.
*
*  2)  The sign must be dealt with outside this routine.
*
*  P.T.Wallace   Starlink   March 1986
*
*  Copyright (C) 1995 Rutherford Appleton Laboratory
*  Copyright (C) 1995 Association of Universities for Research in Astronomy Inc.
*-

      IMPLICIT NONE

      INTEGER IDEG,IAMIN
      REAL ASEC,RAD
      INTEGER J

*  Arc seconds to radians
      REAL AS2R
      PARAMETER (AS2R=0.4848136811095359949E-05)



*  Preset status
      J=0

*  Validate arcsec, arcmin, deg
      IF (ASEC.LT.0.0.OR.ASEC.GE.60.0) J=3
      IF (IAMIN.LT.0.OR.IAMIN.GT.59) J=2
      IF (IDEG.LT.0.OR.IDEG.GT.359) J=1

*  Compute angle
      RAD=AS2R*(60.0*(60.0*REAL(IDEG)+REAL(IAMIN))+ASEC)

      END
