C
C $Id: cfuy.f,v 1.3 1994-03-17 01:43:04 kennison Exp $
C
      FUNCTION CFUY (RY)
C
C Given a Y coordinate RY in the fractional system, CFUY(RY) is a Y
C coordinate in the user system.
C
      COMMON /IUTLCM/ LL,MI,MX,MY,IU(96)
      SAVE /IUTLCM/
      DIMENSION WD(4),VP(4)
      CALL GQCNTN (IE,NT)
      IF (IE.NE.0) THEN
        CALL SETER ('CFUY - ERROR EXIT FROM GQCNTN',1,1)
        CFUY=0.
        RETURN
      END IF
      CALL GQNT (NT,IE,WD,VP)
      IF (IE.NE.0) THEN
        CALL SETER ('CFUY - ERROR EXIT FROM GQNT',2,1)
        CFUY=0.
        RETURN
      END IF
      I=3
      IF (MI.EQ.2.OR.MI.GE.4) I=4
      CFUY=WD(I)+(RY-VP(3))/(VP(4)-VP(3))*(WD(7-I)-WD(I))
      IF (LL.EQ.2.OR.LL.GE.4) CFUY=10.**CFUY
      RETURN
      END
