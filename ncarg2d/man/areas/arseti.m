.TH ARSETI 3NCARG "March 1993" UNIX "NCAR GRAPHICS"
.na
.nh
.SH NAME
ARSETI - Sets an integer parameter in Areas.
.SH SYNOPSIS
CALL ARSETI (PNAM, IVAL)
.SH C-BINDING SYNOPSIS
#include <ncarg/ncargC.h>
.sp
void c_arseti (char *pnam, int ival)
.SH DESCRIPTION 
.IP "PNAM" 12
(an input expression of type CHARACTER) - 
The name of the parameter that you want to set. The string 
can be of any length, however, only the first two characters 
within the quotation marks will be examined.
.IP "IVAL" 12
(an input expression of type INTEGER) - 
The integer value you select for the parameter.
.SH C-BINDING DESCRIPTION 
The C-binding argument descriptions are the same as the FORTRAN 
argument descriptions.
.SH USAGE
This routine allows you to set the current value of Areas 
parameters. For a complete list of parameters available in this 
utility, see the areas_params man page.
.SH EXAMPLES
Use the ncargex command to see the following relevant
examples: 
cardb1,
arex01.
.SH ACCESS
To use ARSETI, load the NCAR Graphics libraries ncarg, ncarg_gks,
ncarg_c, and ncarg_loc, preferably in that order. To use c_arseti, 
load the NCAR Graphics libraries ncargC, ncarg_gksC, ncarg, 
ncarg_gks, ncarg_c, and ncarg_loc, preferably in that order.
.SH MESSAGES
See the areas man page for a description of all Areas error
messages and/or informational messages.
.SH SEE ALSO
Online:
areas, areas_params, ardbpa, ardrln, aredam, argeti, argtai, 
arinam, arpram, arscam, ncarg_cbind
.sp
Hardcopy:
NCAR Graphics Contouring and Mapping Tutorial
.SH COPYRIGHT
Copyright 1987, 1988, 1989, 1991, 1993 University Corporation
for Atmospheric Research
.br
All Rights Reserved
