C
C $Id: mprgsq.f,v 1.2 2001-07-24 20:42:56 kennison Exp $
C
C                Copyright (C)  2000
C        University Corporation for Atmospheric Research
C                All Rights Reserved
C
C This file is free software; you can redistribute it and/or modify
C it under the terms of the GNU General Public License as published
C by the Free Software Foundation; either version 2 of the License, or
C (at your option) any later version.
C
C This software is distributed in the hope that it will be useful, but
C WITHOUT ANY WARRANTY; without even the implied warranty of
C MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
C General Public License for more details.
C
C You should have received a copy of the GNU General Public License
C along with this software; if not, write to the Free Software
C Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
C USA.
C
      SUBROUTINE MPRGSQ (ICAT,ICEL,IRIM,ILAT,ILON,OLON,IFLL)
C
C This routine, given the file identifiers ICAT, ICEL, and IRIM for a
C particular level of the RANGS/GSHHS data, the integer latitude and
C longitude ILAT and ILON (-90.LE.ILAT.LE.89 and 0.LE.ILON.LE.359) of
C the lower left-hand corner of a particular 1-degree square, an offset
C longitude OLON (a multiple of 360 which is added to the longitudes of
C all points retrieved before mapping them), and a flag IFLL, retrieves
C the polygons within the specified square, maps them by calling MAPTRN,
C and then either fills them (if IFLL is non-zero) or just draws them
C (if IFLL is zero).
C
C Declare required common blocks.  See MAPBD for descriptions of these
C common blocks and the variables in them.
C
        COMMON /MAPRGD/ ICOL(5),ICSF(5),NILN,NILT
        SAVE   /MAPRGD/
C
C Declare required double-precision quantities.  (The resolution of the
C data is such as to require double precision latitudes and longitudes.)
C
        DOUBLE PRECISION DLON,DLAT
        DOUBLE PRECISION PLON,PLAT
        DOUBLE PRECISION QLON,QLAT
        DOUBLE PRECISION RLON,RLAT
C
C The arrays XCRD and YCRD are used to hold the coordinates of points
C defining polygons retrieved from the data arrays.  Each is dimensioned
C MCRD, where MCRD is as defined in the parameter statement.
C
        PARAMETER (MCRD=16384)
C
        DIMENSION XCRD(MCRD),YCRD(MCRD)
C
C CTM4 and CTM1 are character temporaries into which we can read a group
C of four bytes or a single byte, respectively.  (Because the data are
C written in a byte-swapped fashion, we cannot read a four-byte quantity
C as if it were an integer; instead, we must read the four bytes and put
C the integer together.)
C
        CHARACTER*4 CTM4
        CHARACTER*1 CTM1
C
C Compute the values of the parameters DLON and DLAT from the values of
C NILN and NILT in COMMON.
C
        DLON=1.D0/DBLE(NILN)
        DLAT=1.D0/DBLE(NILT)
C
C Zero the polygon-level counter and the count of polygon points saved.
C
        ILEV=0
        NCRD=0
C
C Look in the catalog for a pointer to the definition of the desired
C 1-degree square in the cell file.
C
        CALL NGSEEK (ICAT,4*((89-ILAT)*360+ILON),0,ISTA)
C
        IF (ISTA.LT.0) THEN
          CALL SETER ('MPRGSQ - SEEK FAILURE IN CAT FILE ',1,1)
          RETURN
        END IF
C
        CALL NGRDCH (ICAT,CTM4,4,ISTA)
C
        IF (ISTA.NE.4) THEN
          CALL SETER ('MPRGSQ - READ FAILURE IN CAT FILE ',2,1)
          RETURN
        END IF
C
        IPOS=IOR(ISHIFT(IOR(ISHIFT(IOR(ISHIFT(ICHAR(CTM4(4:4)),8),
     +                                        ICHAR(CTM4(3:3))),8),
     +                                        ICHAR(CTM4(2:2))),8),
     +                                        ICHAR(CTM4(1:1)))-1
C
C Position the cell file to the start of the definition.
C
        CALL NGSEEK (ICEL,IPOS,0,ISTA)
C
        IF (ISTA.LT.0) THEN
          CALL SETER ('MPRGSQ - SEEK FAILURE IN CEL FILE ',3,1)
          RETURN
        END IF
C
C Read a new polygon byte.
C
  101   CALL NGRDCH (ICEL,CTM1,1,ISTA)
C
        IF (ISTA.NE.1) THEN
          CALL SETER ('MPRGSQ - READ FAILURE IN CEL FILE ',4,1)
          RETURN
        END IF
C
        IPGB = ICHAR(CTM1)
C
C If the polygon byte is non-zero, we are at the start of a new polygon.
C
        IF (IPGB.NE.0) THEN
C
C Bump the value of ILEV by one.  This is done because the definition
C of a polygon is recursive; it can itself include one or more interior
C polygons that form holes in it.  Each polygon begins with a non-zero
C polygon byte and ends with a zero polygon byte; if, when we read for
C a polygon byte, we get a non-zero value, we know that a new level of
C recursion is beginning.
C
          ILEV=ILEV+1
C
C Read the polygon ID.
C
          CALL NGRDCH (ICEL,CTM4,4,ISTA)
C
          IF (ISTA.NE.4) THEN
            CALL SETER ('MPRGSQ - READ FAILURE IN CEL FILE ',5,1)
            RETURN
          END IF
C
          IPID=IOR(ISHIFT(IOR(ISHIFT(IOR(ISHIFT(ICHAR(CTM4(4:4)),8),
     +                                          ICHAR(CTM4(3:3))),8),
     +                                          ICHAR(CTM4(2:2))),8),
     +                                          ICHAR(CTM4(1:1)))
C
C Zero IFLG.  It gets set non-zero when we have found the first point
C of the polygon, positive if that point is on the edge of the 1-degree
C cell, negative if otherwise.
C
          IFLG=0
C
C Zero ITMP.  This is done because we save the previous value of ITMP
C in ITML; it prevents ITML from getting a garbage value.
C
          ITMP=0
C
C Read a new segment byte.
C
  102     CALL NGRDCH (ICEL,CTM1,1,ISTA)
C
          IF (ISTA.NE.1) THEN
            CALL SETER ('MPRGSQ - READ FAILURE IN CEL FILE ',6,1)
            RETURN
          END IF
C
          ISGB = ICHAR(CTM1)
C
C The low-order three bits of the segment byte tell us what follows.
C Pull them off into ITMP, saving the previous value as ITML.
C
          ITML=ITMP
          ITMP=IAND(ISGB,7)
C
C If ITMP is non-zero, extract a three-bit integer that tells us the
C type of the polygon we're working on (0 => ocean, 1 => land, 2 =>
C lake, 3 => island in lake, 4 => pond on island).
C
          IF (ITMP.NE.0) ITYP=IAND(ISHIFT(ISGB,-4),7)
C
C If ITMP is between 1 and 6, inclusive, it specifies a number of
C points defined by values read from the cell file; each point is
C defined by two 4-byte integers, the first a longitude and the
C second a latitude, in units of millionths of a degree.  All of these
C points are on the edge of the 1-degree cell.
C
          IF (ITMP.GE.1.AND.ITMP.LE.6) THEN
C
            NPTS = ITMP
C
C Loop to read the points.
C
            DO 105 I=1,NPTS
C
C Read a longitude.
C
              CALL NGRDCH (ICEL,CTM4,4,ISTA)
C
              IF (ISTA.NE.4) THEN
                CALL SETER ('MPRGSQ - READ FAILURE IN CEL FILE ',7,1)
                RETURN
              END IF
C
              QLON=RLON
C
              RLON=.000001D0*DBLE(IOR(ISHIFT(
     +             IOR(ISHIFT(IOR(ISHIFT(ICHAR(CTM4(4:4)),8),
     +                                   ICHAR(CTM4(3:3))),8),
     +                                   ICHAR(CTM4(2:2))),8),
     +                                   ICHAR(CTM4(1:1))))
C
C Read a latitude.
C
              CALL NGRDCH (ICEL,CTM4,4,ISTA)
C
              IF (ISTA.NE.4) THEN
                CALL SETER ('MPRGSQ - READ FAILURE IN CEL FILE ',8,1)
                RETURN
              END IF
C
              QLAT=RLAT
C
              RLAT=.000001D0*DBLE(IOR(ISHIFT(
     +             IOR(ISHIFT(IOR(ISHIFT(ICHAR(CTM4(4:4)),8),
     +                                   ICHAR(CTM4(3:3))),8),
     +                                   ICHAR(CTM4(2:2))),8),
     +                                   ICHAR(CTM4(1:1))))
C
C If we had not yet seen the first point of the polygon (that is to
C say, if IFLG is zero), this is it; save its longitude and latitude
C and set IFLG to say that the first point was on the cell boundary.
C
              IF (IFLG.EQ.0) THEN
                PLON=RLON
                PLAT=RLAT
                IFLG=+1
              END IF
C
C The following code is meant to interpolate points on the cell edges
C and is executed only if we are filling the polygon, in which case it
C helps to prevent the appearance of seams where adjacent polygons meet.
C
              IF (I.NE.1) THEN
C
                IF (IFLL.NE.0) THEN
C
                  IF (RLAT.EQ.QLAT) THEN
C
                    IDIR=INT(SIGN(1.D0,RLON-QLON))
                    IBEG=INT((QLON-DBLE(ILON))/DLON)
                    IEND=INT((RLON-DBLE(ILON))/DLON)
                    IF (IDIR.GT.0) IBEG=IBEG+1
                    IF (IDIR.LT.0) IEND=IEND+1
                    XLAT=REAL(RLAT)
C
                    DO 103 IINT=IBEG,IEND,IDIR
                      XLON=OLON+REAL(DBLE(ILON)+DBLE(IINT)*DLON)
                      IF (NCRD+1.LT.MCRD) THEN
                        NCRD=NCRD+1
                        CALL MAPTRN (XLAT,XLON,XCRD(NCRD),YCRD(NCRD))
                        IF (ICFELL('MPRGSQ',9).NE.0) RETURN
                        IF (XCRD(NCRD).EQ.1.E12) NCRD=NCRD-1
                      ELSE
                        CALL SETER
     +                     ('MPRGSQ - COORDINATE BUFFER OVERFLOW ',10,1)
                        RETURN
                      END IF
  103               CONTINUE
C
                  ELSE IF (RLON.EQ.QLON) THEN
C
                    IDIR=INT(SIGN(1.D0,RLAT-QLAT))
                    IBEG=INT((QLAT-DBLE(ILAT))/DLAT)
                    IEND=INT((RLAT-DBLE(ILAT))/DLAT)
                    IF (IDIR.GT.0) IBEG=IBEG+1
                    IF (IDIR.LT.0) IEND=IEND+1
                    XLON=OLON+REAL(RLON)
C
                    DO 104 IINT=IBEG,IEND,IDIR
                      XLAT=REAL(DBLE(ILAT)+DBLE(IINT)*DLAT)
                      IF (NCRD+1.LT.MCRD) THEN
                        NCRD=NCRD+1
                        CALL MAPTRN (XLAT,XLON,XCRD(NCRD),YCRD(NCRD))
                        IF (ICFELL('MPRGSQ',11).NE.0) RETURN
                        IF (XCRD(NCRD).EQ.1.E12) NCRD=NCRD-1
                      ELSE
                        CALL SETER
     +                     ('MPRGSQ - COORDINATE BUFFER OVERFLOW ',12,1)
                        RETURN
                      END IF
  104               CONTINUE
C
                  END IF
C
                END IF
C
              END IF
C
C If we are filling the polygon or if we are not filling the polygon,
C but the point is the first or last one in a sequence on the cell edge
C (meaning that it is joined to a point in the interior of the cell),
C map it from lat/lon to u/v and insert its coordinates in the list.
C
              IF (IFLL.NE.0.OR.I.EQ.1.OR.I.EQ.NPTS) THEN
                IF (NCRD+1.LT.MCRD) THEN
                  NCRD=NCRD+1
                  CALL MAPTRN (REAL(RLAT),OLON+REAL(RLON),
     +                              XCRD(NCRD),YCRD(NCRD))
                  IF (ICFELL('MPRGSQ',13).NE.0) RETURN
                  IF (XCRD(NCRD).EQ.1.E12) NCRD=NCRD-1
                ELSE
                  CALL SETER
     +                     ('MPRGSQ - COORDINATE BUFFER OVERFLOW ',14,1)
                  RETURN
                END IF
              END IF
C
C If we are not filling the polygon, but are just drawing its boundary,
C and this point is the first point of a series of points along the cell
C edge, dump out a polyline and clear the point-coordinate buffer.  Note
C that NPTS *can* be equal to 1 in the case of a polygon which touches
C the cell edge at one point and then heads back into the interior;
C that's the reason for the ".AND.NPTS.NE.1" in the IF.
C
              IF (IFLL.EQ.0.AND.I.EQ.1.AND.NPTS.NE.1) THEN
                IF (NCRD.GT.1) THEN
                  CALL GSPLCI (ICOL(ITYP+1))
                  CALL GPL (NCRD,XCRD,YCRD)
                END IF
                NCRD=0
              END IF
C
  105       CONTINUE
C
C Go back to read another segment byte.
C
            GO TO 102
C
C If ITMP is a 7, then the next two values in the cell file are 4-byte
C integers, the first of which is a pointer into the rim file and the
C second of which is the number of points to be read from the rim file.
C Each point in the rim file is defined like a point in the cell file,
C by a pair of 4-byte integers, specifying longitude and latitude, in
C millionths of a degree.  All of the points in the rim file are in
C the interior of the 1-degree cell.
C
          ELSE IF (ITMP.EQ.7) THEN
C
C Get the pointer into the rim file.
C
            CALL NGRDCH (ICEL,CTM4,4,ISTA)
C
            IF (ISTA.NE.4) THEN
              CALL SETER ('MPRGSQ - READ FAILURE IN CEL FILE ',15,1)
              RETURN
            END IF
C
            IPOS=IOR(ISHIFT(IOR(ISHIFT(IOR(ISHIFT(ICHAR(CTM4(4:4)),8),
     +                                            ICHAR(CTM4(3:3))),8),
     +                                            ICHAR(CTM4(2:2))),8),
     +                                            ICHAR(CTM4(1:1)))-1
C
C Get the number of points to be read from the rim file.
C
            CALL NGRDCH (ICEL,CTM4,4,ISTA)
C
            IF (ISTA.NE.4) THEN
              CALL SETER ('MPRGSQ - READ FAILURE IN CEL FILE ',16,1)
              RETURN
            END IF
C
            NPTS=IOR(ISHIFT(IOR(ISHIFT(IOR(ISHIFT(ICHAR(CTM4(4:4)),8),
     +                                            ICHAR(CTM4(3:3))),8),
     +                                            ICHAR(CTM4(2:2))),8),
     +                                            ICHAR(CTM4(1:1)))
C
C If the number of points to be read is non-zero (for some reason, it
C *can* happen that the number is zero), read the points.
C
            IF (NPTS.NE.0) THEN
C
C Position to the start of the list of points in the rim file.
C
              CALL NGSEEK (IRIM,IPOS,0,ISTA)
C
              IF (ISTA.LT.0) THEN
                CALL SETER ('MPRGSQ - SEEK FAILURE IN RIM FILE ',17,1)
                RETURN
              END IF
C
C Loop to read the points.
C
              DO 106 I=1,NPTS
C
C Read a longitude.
C
                CALL NGRDCH (IRIM,CTM4,4,ISTA)
C
                IF (ISTA.NE.4) THEN
                  CALL SETER ('MPRGSQ - READ FAILURE IN RIM FILE ',18,1)
                  RETURN
                END IF
C
                QLON=RLON
C
                RLON=.000001D0*DBLE(IOR(ISHIFT(
     +               IOR(ISHIFT(IOR(ISHIFT(ICHAR(CTM4(4:4)),8),
     +                                     ICHAR(CTM4(3:3))),8),
     +                                     ICHAR(CTM4(2:2))),8),
     +                                     ICHAR(CTM4(1:1))))
C
C Read a latitude.
C
                CALL NGRDCH (IRIM,CTM4,4,ISTA)
C
                IF (ISTA.NE.4) THEN
                  CALL SETER ('MPRGSQ - READ FAILURE IN RIM FILE ',19,1)
                  RETURN
                END IF
C
                QLAT=RLAT
C
                RLAT=.000001D0*DBLE(IOR(ISHIFT(
     +               IOR(ISHIFT(IOR(ISHIFT(ICHAR(CTM4(4:4)),8),
     +                                     ICHAR(CTM4(3:3))),8),
     +                                     ICHAR(CTM4(2:2))),8),
     +                                     ICHAR(CTM4(1:1))))
C
C If we had not yet seen the first point of the polygon (that is to
C say, if IFLG is zero), this is it; save its longitude and latitude
C and set IFLG to say that the first point was not on the cell boundary.
C
                IF (IFLG.EQ.0) THEN
                  PLON=RLON
                  PLAT=RLAT
                  IFLG=-1
                END IF
C
C Since all of these points are interior points, we just map them and
C add the u/v coordinates to the point-coordinate buffers.
C
                IF (NCRD+1.LT.MCRD) THEN
                  NCRD=NCRD+1
                  CALL MAPTRN (REAL(RLAT),OLON+REAL(RLON),
     +                              XCRD(NCRD),YCRD(NCRD))
                  IF (ICFELL('MPRGSQ',20).NE.0) RETURN
                  IF (XCRD(NCRD).EQ.1.E12) NCRD=NCRD-1
                ELSE
                  CALL SETER
     +                     ('MPRGSQ - COORDINATE BUFFER OVERFLOW ',21,1)
                  RETURN
                END IF
C
  106         CONTINUE
C
            END IF
C
C We get here if we read a segment byte in which ITMP was zero.  Go back
C to read another segment byte.
C
            GO TO 102
C
          END IF
C
C If ITMP is zero, we've reached the end of the polygon.  We must supply
C a closure point (the first point of the polygon) and then either fill
C the polygon or draw the remainder of its boundary.
C
          IF (IFLL.NE.0) THEN
C
C Output the fill area.  First, see if at least one point is defined in
C the buffers.
C
            IF (NCRD.GT.1) THEN
C
C Yes.  The complication here is that, if the last point we saw was on
C the cell edge and the first point of the polygon was also on the cell
C edge, then we have to interpolate points along the cell edge in the
C same way that was done above.
C
              IF (ITML.GE.1.AND.ITML.LE.6.AND.IFLG.GT.0) THEN
C
                QLON=RLON
                QLAT=RLAT
                RLON=PLON
                RLAT=PLAT
C
                IF (RLAT.EQ.QLAT) THEN
C
                  IDIR=INT(SIGN(1.D0,RLON-QLON))
                  IBEG=INT((QLON-DBLE(ILON))/DLON)
                  IEND=INT((RLON-DBLE(ILON))/DLON)
                  IF (IDIR.GT.0) IBEG=IBEG+1
                  IF (IDIR.LT.0) IEND=IEND+1
                  XLAT=REAL(RLAT)
C
                  DO 107 IINT=IBEG,IEND,IDIR
                    XLON=OLON+REAL(DBLE(ILON)+DBLE(IINT)*DLON)
                    IF (NCRD+1.LT.MCRD) THEN
                      NCRD=NCRD+1
                      CALL MAPTRN (XLAT,XLON,XCRD(NCRD),YCRD(NCRD))
                      IF (ICFELL('MPRGSQ',22).NE.0) RETURN
                      IF (XCRD(NCRD).EQ.1.E12) NCRD=NCRD-1
                    ELSE
                      CALL SETER
     +                     ('MPRGSQ - COORDINATE BUFFER OVERFLOW ',23,1)
                      RETURN
                    END IF
  107             CONTINUE
C
                ELSE IF (RLON.EQ.QLON) THEN
C
                  IDIR=INT(SIGN(1.D0,RLAT-QLAT))
                  IBEG=INT((QLAT-DBLE(ILAT))/DLAT)
                  IEND=INT((RLAT-DBLE(ILAT))/DLAT)
                  IF (IDIR.GT.0) IBEG=IBEG+1
                  IF (IDIR.LT.0) IEND=IEND+1
                  XLON=OLON+REAL(RLON)
C
                  DO 108 IINT=IBEG,IEND,IDIR
                    XLAT=REAL(DBLE(ILAT)+DBLE(IINT)*DLAT)
                    IF (NCRD+1.LT.MCRD) THEN
                      NCRD=NCRD+1
                      CALL MAPTRN (XLAT,XLON,XCRD(NCRD),YCRD(NCRD))
                      IF (ICFELL('MPRGSQ',24).NE.0) RETURN
                      IF (XCRD(NCRD).EQ.1.E12) NCRD=NCRD-1
                    ELSE
                      CALL SETER
     +                     ('MPRGSQ - COORDINATE BUFFER OVERFLOW ',25,1)
                      RETURN
                    END IF
  108             CONTINUE
C
                END IF
C
              END IF
C
C Add the mapped coordinates of the closure point to the buffers and
C fill the polygon.
C
              NCRD=NCRD+1
              CALL MAPTRN (REAL(PLAT),OLON+REAL(PLON),
     +                          XCRD(NCRD),YCRD(NCRD))
              IF (ICFELL('MPRGSQ',26).NE.0) RETURN
              IF (XCRD(NCRD).EQ.1.E12) NCRD=NCRD-1
              CALL GSFACI (ICSF(ITYP+1))
              CALL GFA (NCRD,XCRD,YCRD)
C
            END IF
C
          ELSE
C
C Output the remainder of a polyline.  This time, we make sure that we
C have at least one point so far.
C
            IF (NCRD.GT.0) THEN
C
C Yes.  If the last point was an interior point or if the first point
C of the polygon was an interior point, add the closure point to it.
C
              IF (ITML.EQ.7.OR.IFLG.LT.0) THEN
                NCRD=NCRD+1
                CALL MAPTRN (REAL(PLAT),OLON+REAL(PLON),
     +                            XCRD(NCRD),YCRD(NCRD))
                IF (ICFELL('MPRGSQ',27).NE.0) RETURN
                IF (XCRD(NCRD).EQ.1.E12) NCRD=NCRD-1
              END IF
C
C Now, output the polyline.
C
              IF (NCRD.GT.1) THEN
                CALL GSPLCI (ICOL(ITYP+1))
                CALL GPL (NCRD,XCRD,YCRD)
              END IF
C
            END IF
C
          END IF
C
C Zero the count of coordinates in the point-coordinate buffer.
C
          NCRD=0
C
C Go back to read another polygon byte.
C
          GO TO 101
C
C If the polygon byte is zero, it says that we've hit the end of a
C polygon.
C
        ELSE
C
C Reduce the recursion counter by one and, if it's still non-zero, go
C back to read another polygon byte.
C
          ILEV=ILEV-1
          IF (ILEV.NE.0) GO TO 101
C
        END IF
C
C Normal return.
C
        RETURN
C
      END
