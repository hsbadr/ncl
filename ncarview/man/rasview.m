.\"
.\"	$Id: rasview.m,v 1.7 1993-02-03 04:26:42 clyne Exp $
.\"
.TH RASVIEW 1NCARG "January 1993" NCARG "NCAR GRAPHICS"
.SH NAME
rasview \- Raster file previewer for the X Window System.
.SH SYNOPSIS
.B rasview
[
.BI \-toolkitoption " ..."
] [
.BI \-ifmt " format"
] [
.B \-movie
] [
.BI \-pal " palette_file"
] [
.B \-quiet
] [
.B \-Version
]
.I file.ext

.SH DESCRIPTION
.LP
.B rasview
displays raster imagery from a file into an X window.
By default rasview determines the format of an image file by looking at
its file name extension. 
See the 
.B IMAGE FORMATS
section below for a list of supported file formats.
For example, an xwd (X11 Window Dump) file might
be named
.BR foo.xwd .
.LP
Raster image file formats come in a variety of flavors. 
.B rasview
attempts to support 8-bit-indexed, and 24-bit-direct encodings of the image
formats listed below. Similarly, only output devices with 8-bit or 24-bit
depth are supported.
.B rasview 
attempts to select an X11 Visual which best matches the encoding
of the image file. A PseudoColor visual class is preferred for 8-bit-indexed
imagery, while a DirectColor visual class is preferred for 24-bit-direct
encoded imagery. In the case of 24-bit-direct encodings, if the output
device only has 8-bit color the imagery is color-quantized down to 8 bits.
.LP
In general raster files contain only a single image. 
.B rasview 
is able to display multiple-image raster files if they 
were created by the concatenation of single-image files with the 
.B rascat(1NCARG)
utility or if they were generated by 
.BR ctrans(1NCARG) . 
Multi-frame image files
generated by other means are not guaranteed to be displayable by 
.BR rasview .
.SH OPTIONS
.B rasview
accepts all of the standard X Toolkit command line options (see X11(7)). 
.B rasview
also accepts the following options:
.TP
.BI \-ifmt " format"
Specify the input file format. 
.I format
is one of the aforementioned file name extensions (without the ".", e.g. 
.BR xwd). 
When this option is 
specified file name extensions are not necessary and are ignored if present.
All input files must have the same format.
.TP
.B \-movie
Normally when processing multi-image raster files,
.B rasview 
waits for a mouse click before proceeding to the next frame. When this
option is used 
.B rasview
immediately advances the frame after 
.B rasview
has completed drawing it.
.TP
.BI \-pal " palette_file"
Use the color palette contained in the file
.IR palette_file .
for displaying images. This palette will override the color palette stored
with the image.
.IP
.I palette_file
contains a line-separated list of color table entries. Each color table 
entry is made up of a color table index in the range 0 to 255, and a tuple 
of R, G, and B color intensities, also in the range 0 to 255. For example,
.sp
1 0 0 255
.sp
specifies that color index 1 is to be mapped to full intensity blue. 
.IP
Color values are linearly interpolated for missing color table entries. 
For example, if 
.I palette_file 
contained the following entries:
.sp
1 255 255 0
.br
3 0 255 255
.sp
then color index 2 would be interpolated to be 128 255 128. 
.IP
This option is only useful for 8-bit-indexed imagery.
.TP
.B \-quiet
Operate in quiet mode.
.TP
.B \-Version
Print the version number and then exit.
.SH "IMAGE FORMATS"
.B rasview
understands the following image format name extensions:
.nf
	avs		Application Visualization System
	hdf		Hierarchical Data Format
	nrif		NCAR Raster Interchange Format
	sun		Sun Microsystems 
	sgi		Silicon Graphics Incorporated
	xwd		X11 Window Dump
.fi
.SH "SEE ALSO"
.BR ctrans (1NCARG),
.BR rascat (1NCARG),
.BR ras_palette (5NCARG),
.BR xwd (1),
.BR xwud (1)
.BR X11 (7)
.br
.ne 5
.SH BUGS/CAVEATS
.B rasview 
does not respond to redraw events.

