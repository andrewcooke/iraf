      DOUBLE PRECISION FUNCTION slARMS (ZD)
*+
*     - - - - - - -
*      A R M S
*     - - - - - - -
*
*  Air mass at given zenith distance (double precision)
*
*  Given:
*     ZD     d     Observed zenith distance (radians)
*
*  The result is an estimate of the air mass, in units of that
*  at the zenith.
*
*  Notes:
*
*  1)  The "observed" zenith distance referred to above means "as
*      affected by refraction".
*
*  2)  Uses Hardie's (1962) polynomial fit to Bemporad's data for
*      the relative air mass, X, in units of thickness at the zenith
*      as tabulated by Schoenberg (1929). This is adequate for all
*      normal needs as it is accurate to better than 0.1% up to X =
*      6.8 and better than 1% up to X = 10. Bemporad's tabulated
*      values are unlikely to be trustworthy to such accuracy
*      because of variations in density, pressure and other
*      conditions in the atmosphere from those assumed in his work.
*
*  3)  The sign of the ZD is ignored.
*
*  4)  At zenith distances greater than about ZD = 87 degrees the
*      air mass is held constant to avoid arithmetic overflows.
*
*  References:
*     Hardie, R.H., 1962, in "Astronomical Techniques"
*        ed. W.A. Hiltner, University of Chicago Press, p180.
*     Schoenberg, E., 1929, Hdb. d. Ap.,
*        Berlin, Julius Springer, 2, 268.
*
*  Original code by P.W.Hill, St Andrews
*  Adapted by P.T.Wallace, Starlink, 5 December 1990
*
*  Copyright (C) 1995 Rutherford Appleton Laboratory
*  Copyright (C) 1995 Association of Universities for Research in Astronomy Inc.
*-

      IMPLICIT NONE

      DOUBLE PRECISION ZD

      DOUBLE PRECISION SECZM1


      SECZM1 = 1D0/(COS(MIN(1.52D0,ABS(ZD))))-1D0
      slARMS = 1D0 + SECZM1*(0.9981833D0
     :             - SECZM1*(0.002875D0 + 0.0008083D0*SECZM1))

      END
