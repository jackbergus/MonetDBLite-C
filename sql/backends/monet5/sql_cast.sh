cat <<EOF
/*
 * The contents of this file are subject to the MonetDB Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.monetdb.org/Legal/MonetDBLicense
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * The Original Code is the MonetDB Database System.
 *
 * The Initial Developer of the Original Code is CWI.
 * Portions created by CWI are Copyright (C) 1997-July 2008 CWI.
 * Copyright August 2008-2013 MonetDB B.V.
 * All Rights Reserved.
 
 * This file was generated by using the script ${0##*/}.
*/
 
EOF
 
integer="bte sht int wrd lng"   # all integer types
numeric="$integer flt dbl"  # all numeric types
 
for tp1 in 1:bte 2:sht 4:int 8:wrd 8:lng; do
	for tp2 in 1:bte 2:sht 4:int 8:wrd 8:lng; do
    if [ ${tp1%:*} -le ${tp2%:*} -o ${tp1#*:} = ${tp2#*:} ]; then
	cat <<EOF
sql5_export str ${tp2#*:}_2_${tp1#*:}( ${tp1#*:} *res, ${tp2#*:} *v );
sql5_export str bat${tp2#*:}_2_${tp1#*:}( int *res, int *v );

sql5_export str ${tp2#*:}_dec2_${tp1#*:}( ${tp1#*:} *res, int *s1, ${tp2#*:} *v );
sql5_export str ${tp2#*:}_dec2dec_${tp1#*:}( ${tp1#*:} *res, int *S1, ${tp2#*:} *v, int *d2, int *S2 );
sql5_export str ${tp2#*:}_num2dec_${tp1#*:}( ${tp1#*:} *res, ${tp2#*:} *v, int *d2, int *s2 );
sql5_export str bat${tp2#*:}_dec2_${tp1#*:}( int *res, int *s1, int *v );
sql5_export str bat${tp2#*:}_dec2dec_${tp1#*:}( int *res, int *S1, int *v, int *d2, int *S2 );
sql5_export str bat${tp2#*:}_num2dec_${tp1#*:}( int *res, int *v, int *d2, int *s2 );

EOF
fi
done
done

for tp1 in bte sht int wrd lng; do
	for tp2 in flt dbl ; do
	cat <<EOF
sql5_export str ${tp2}_2_${tp1}( ${tp1} *res, ${tp2} *v );
sql5_export str bat${tp2}_2_${tp1}( int *res, int *v );
sql5_export str ${tp2}_num2dec_${tp1}( ${tp1} *res, ${tp2} *v, int *d2, int *s2 );
sql5_export str bat${tp2}_num2dec_${tp1}( int *res, int *v, int *d2, int *s2 );

EOF
done
done

for tp1 in bte sht int wrd lng; do
	for tp2 in flt dbl ; do
	cat <<EOF
sql5_export str ${tp1}_2_${tp2}( ${tp2} *res, ${tp1} *v );
sql5_export str bat${tp1}_2_${tp2}( int *res, int *v );
sql5_export str ${tp1}_num2dec_${tp2}( ${tp2} *res, ${tp1} *v, int *d2, int *s2 );
sql5_export str bat${tp1}_num2dec_${tp2}( int *res, int *v, int *d2, int *s2 );

EOF
done
done

for tp1 in flt dbl ; do
	for tp2 in bte sht int wrd lng; do
	cat <<EOF
sql5_export str ${tp2}_dec2_${tp1}( ${tp1} *res, int *s1, ${tp2} *v );
sql5_export str ${tp2}_dec2dec_${tp1}( ${tp1} *res, int *S1, ${tp2} *v, int *d2, int *S2 );
sql5_export str ${tp2}_num2dec_${tp1}( ${tp1} *res, ${tp2} *v, int *d2, int *s2 );
sql5_export str bat${tp2}_dec2_${tp1}( int *res, int *s1, int *v );
sql5_export str bat${tp2}_dec2dec_${tp1}( int *res, int *S1, int *v, int *d2, int *S2 );
sql5_export str bat${tp2}_num2dec_${tp1}( int *res, int *v, int *d2, int *s2 );

EOF
done
done

for tp1 in 1:bte 2:sht 4:int ; do
	for tp2 in 1:bte 2:sht 4:int 8:wrd 8:lng; do
    if [ ${tp1%:*} -le ${tp2%:*} -o ${tp1#*:} = ${tp2#*:} ]; then
	cat <<EOF
sql5_export str ${tp1#*:}_2_${tp2#*:}( ${tp2#*:} *res, ${tp1#*:} *v );
sql5_export str bat${tp1#*:}_2_${tp2#*:}( int *res, int *v );
sql5_export str ${tp1#*:}_dec2_${tp2#*:}( ${tp2#*:} *res, int *s1, ${tp1#*:} *v );
sql5_export str ${tp1#*:}_dec2dec_${tp2#*:}( ${tp2#*:} *res, int *S1, ${tp1#*:} *v, int *d2, int *S2 );
sql5_export str ${tp1#*:}_num2dec_${tp2#*:}( ${tp2#*:} *res, ${tp1#*:} *v, int *d2, int *s2 );
sql5_export str bat${tp1#*:}_dec2_${tp2#*:}( int *res, int *s1, int *v );
sql5_export str bat${tp1#*:}_dec2dec_${tp2#*:}( int *res, int *S1, int *v, int *d2, int *S2 );
sql5_export str bat${tp1#*:}_num2dec_${tp2#*:}( int *res, int *v, int *d2, int *s2 );

EOF
fi
done
done
