C
C $Id: mapio.f,v 1.16 2001-07-24 20:42:55 kennison Exp $
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
      SUBROUTINE MAPIO (IACT)
C
C This routine performs all positioning and input of the outline dataset
C for MAPLOT.  The argument IACT specifies what is to be done:  1 asks
C that the dataset be positioned at the beginning of the desired "file",
C 2 that the next record be read.
C
C Declare required common blocks.  See MAPBD for descriptions of these
C common blocks and the variables in them.
C
      COMMON /MAPCM3/ ITPN,NOUT,NPTS,IGID,IDLS,IDRS,BLAG,SLAG,BLOG,SLOG,
     +                PNTS(200),IDOS(4)
      SAVE   /MAPCM3/
C
      COMMON /MAPCM5/ DDCT(5),DDCL(5),LDCT(6),LDCL(6),PDCT(12),PDCL(12)
      CHARACTER*2     DDCT,DDCL,LDCT,LDCL,PDCT,PDCL
      SAVE   /MAPCM5/
C
C Declare a variable in which to form the name of an outline data file.
C
      CHARACTER*128 FLNM
C
C Save the file-descriptor parameter from one call to the next.
C
      SAVE IFDE
C
C Either open the requested dataset ...
C
      IF (IACT.EQ.1) THEN
C
        CALL MPDBDI (FLNM,ISTA)
        IF (ISTA.EQ.-1) GO TO 901
C
        DO 101 I=1,111
          IF (FLNM(I:I).EQ.CHAR(0)) THEN
            FLNM(I:I+17)='/EzmapOutlines.'//DDCT(NOUT+1)//CHAR(0)
            GO TO 102
          END IF
  101   CONTINUE
C
        GO TO 901
C
  102   CALL NGOFRO (FLNM,IFDE,ISTA)
        IF (ISTA.NE.0) GO TO 901
C
        RETURN
C
C ... or read the next record.
C
      ELSE
C
        CALL NGRDIN (IFDE,NPTS,4,ISTA)
C
        IF (ISTA.EQ.4) THEN
          IF (NPTS.LE.1) THEN
            CALL NGCLFI (IFDE)
            NPTS=0
            RETURN
          ELSE
            CALL NGRDFL (IFDE,BLAG,4+NPTS,ISTA)
            IF (ISTA.EQ.4+NPTS) THEN
              NPTS=NPTS/2
              RETURN
            END IF
          END IF
        END IF
C
        CALL NGCLFI (IFDE)
        IF (ISTA.LT.0) GO TO 902
        GO TO 903
C
      END IF
C
C Error exits.
C
  901 CALL SETER ('MAPIO - OUTLINE DATASET IS UNREADABLE',1,1)
      NOUT=0
      RETURN
C
  902 CALL SETER ('MAPIO - ERROR ON READ OF OUTLINE DATASET',2,1)
      NOUT=0
      RETURN
C
  903 CALL SETER ('MAPIO - EOF ENCOUNTERED IN OUTLINE DATASET',3,1)
      NOUT=0
      RETURN
C
      END
