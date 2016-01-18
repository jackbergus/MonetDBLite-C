# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0.  If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright 1997 - July 2008 CWI, August 2008 - 2016 MonetDB B.V.

sed '/^$/q' $0			# copy copyright from this file

cat <<EOF
# This file was generated by using the script ${0##*/}.

EOF

integer="bte sht int wrd lng"	# all integer types
numeric="$integer flt dbl"	# all numeric types

for tp1 in $integer ; do
	for tp2 in flt dbl ; do
	    cat <<EOF
command calc.${tp1}( v:${tp2}, digits:int, scale:int ) :${tp1}
address ${tp2}_num2dec_${tp1}
comment "cast number to decimal(${tp1}) and check for overflow";

command batcalc.${tp1}( v:bat[:${tp2}], digits:int, scale:int ) :bat[:${tp1}]
address bat${tp2}_num2dec_${tp1}
comment "cast number to decimal(${tp1}) and check for overflow";

EOF
done
done

for tp1 in $numeric ; do
	for tp2 in $integer ; do
	    cat <<EOF
command calc.${tp1}( v:${tp2}, digits:int, scale:int ) :${tp1}
address ${tp2}_num2dec_${tp1}
comment "cast number to decimal(${tp1}) and check for overflow";

command batcalc.${tp1}( v:bat[:${tp2}], digits:int, scale:int ) :bat[:${tp1}]
address bat${tp2}_num2dec_${tp1}
comment "cast number to decimal(${tp1}) and check for overflow";

command calc.${tp1}( s1:int, v:${tp2}) :${tp1} 
address ${tp2}_dec2_${tp1}
comment "cast decimal(${tp2}) to ${tp1} and check for overflow";
command calc.${tp1}( s1:int, v:${tp2}, d2:int, s2:int ) :${tp1} 
address ${tp2}_dec2dec_${tp1}
comment "cast decimal(${tp2}) to decimal(${tp1}) and check for overflow";

command batcalc.${tp1}( s1:int, v:bat[:${tp2}]) :bat[:${tp1}]
address bat${tp2}_dec2_${tp1}
comment "cast decimal(${tp2}) to ${tp1} and check for overflow";
command batcalc.${tp1}( s1:int, v:bat[:${tp2}], d2:int, s2:int ) :bat[:${tp1}] 
address bat${tp2}_dec2dec_${tp1}
comment "cast decimal(${tp2}) to decimal(${tp1}) and check for overflow";

EOF
done
done
