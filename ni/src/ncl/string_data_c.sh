#!/bin/sh

sh op_funcs.sh string NhlTString NhlTStringGenArray -1 > .tmp.$$

if [ ! $? ]
then
	exit $?
fi

cat NclTypestring.c.specific >> .tmp.$$

if [ ! $? ]
then
	exit $?
fi

sed \
-e "/INSERTTMPSTRING/r .tmp.$$" \
-e '/INSERTTMPSTRING/d' \
-e 's/HLUTYPEREP/NhlTQuark/g' \
-e 's/HLUGENTYPEREP/NhlTQuarkGenArray/g' \
-e 's/Ncl_Type_string_is_mono/NULL/g' \
-e 's/Ncl_Type_string_cmpf/NULL/g' \
NclTypestring.c.sed > NclTypestring.c

if [ ! $? ]
then
	exit $?
fi

rm .tmp.$$

echo "created NclTypestringData.c"

exit 0
