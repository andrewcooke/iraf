      REAL FUNCTION slVDV (VA, VB)
*+
*     - - - -
*      V D V
*     - - - -
*
*  Scalar product of two 3-vectors  (single precision)
*
*  Given:
*      VA      real(3)     first vector
*      VB      real(3)     second vector
*
*  The result is the scalar product VA.VB (single precision)
*
*  P.T.Wallace   Starlink   November 1984
*
*  Copyright (C) 1995 Rutherford Appleton Laboratory
*  Copyright (C) 1995 Association of Universities for Research in Astronomy Inc.
*-

      IMPLICIT NONE

      REAL VA(3),VB(3)


      slVDV=VA(1)*VB(1)+VA(2)*VB(2)+VA(3)*VB(3)

      END
