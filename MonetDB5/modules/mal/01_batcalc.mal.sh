# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0.  If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright 1997 - July 2008 CWI, August 2008 - 2017 MonetDB B.V.

sed '/^$/q' $0			# copy copyright from this file

cat <<EOF
# This file was generated by using the script ${0##*/}.

module batcalc;

EOF

integer="bte sht int lng"	# all integer types
numeric="$integer flt dbl"	# all numeric types
alltypes="bit $numeric oid str"

for tp in $numeric; do
    cat <<EOF
pattern iszero(b:bat[:$tp]) :bat[:bit]
address CMDbatISZERO
comment "Unary check for zero over the tail of the bat";
pattern iszero(b:bat[:$tp],s:bat[:oid]) :bat[:bit]
address CMDbatISZERO
comment "Unary check for zero over the tail of the bat with candidates list";

EOF
done
echo

for func in nil notnil; do
    cat <<EOF
pattern is$func(b:bat[:any]) :bat[:bit]
address CMDbatIS${func^^}
comment "Unary check for $func over the tail of the bat";
pattern is$func(b:bat[:any],s:bat[:oid]) :bat[:bit]
address CMDbatIS${func^^}
comment "Unary check for $func over the tail of the bat with candidates list";

EOF
done
echo

com="Return the Boolean inverse"
for tp in bit $integer; do
    cat <<EOF
pattern not(b:bat[:$tp]) :bat[:$tp]
address CMDbatNOT
comment "$com";
pattern not(b:bat[:$tp],s:bat[:oid]) :bat[:$tp]
address CMDbatNOT
comment "$com with candidates list";

EOF
    com="Unary bitwise not over the tail of the bat"
done
echo

for tp in $numeric; do
    cat <<EOF
pattern sign(b:bat[:$tp]) :bat[:bte]
address CMDbatSIGN
comment "Unary sign (-1,0,1) over the tail of the bat";
pattern sign(b:bat[:$tp],s:bat[:oid]) :bat[:bte]
address CMDbatSIGN
comment "Unary sign (-1,0,1) over the tail of the bat with candidates list";

EOF
done
echo

for func in 'abs:ABS:Unary abs over the tail of the bat' \
    '-:NEG:Unary neg over the tail of the bat' \
    '++:INCR:Unary increment over the tail of the bat' \
    '--:DECR:Unary decrement over the tail of the bat'; do
    op=${func%%:*}
    com=${func##*:}
    func=${func%:*}
    func=${func#*:}
    for tp in $numeric; do
	cat <<EOF
pattern $op(b:bat[:$tp]) :bat[:$tp]
address CMDbat${func}
comment "$com";
pattern $op(b:bat[:$tp],s:bat[:oid]) :bat[:$tp]
address CMDbat${func}
comment "$com with candidates list";

EOF
    done
    echo
done

for func in min max; do
    for funcx in '' _no_nil; do
	cat <<EOF
pattern $func$funcx(b1:bat[:any_1],b2:bat[:any_1]) :bat[:any_1]
address CMDbat${func^^}$funcx
comment "Return bat with ${func}imum value of each pair of inputs${funcx:+, ignoring nil values}";
pattern $func$funcx(b1:bat[:any_1],b2:bat[:any_1],s:bat[:oid]) :bat[:any_1]
address CMDbat${func^^}$funcx
comment "Return bat with ${func}imum value of each pair of inputs${funcx:+, ignoring nil values}";
pattern $func$funcx(b:bat[:any_1],v:any_1) :bat[:any_1]
address CMDbat${func^^}$funcx
comment "Return bat with ${func}imum value of each pair of inputs${funcx:+, ignoring nil values}";
pattern $func$funcx(b:bat[:any_1],v:any_1,s:bat[:oid]) :bat[:any_1]
address CMDbat${func^^}$funcx
comment "Return bat with ${func}imum value of each pair of inputs${funcx:+, ignoring nil values}";
pattern $func$funcx(v:any_1,b:bat[:any_1]) :bat[:any_1]
address CMDbat${func^^}$funcx
comment "Return bat with ${func}imum value of each pair of inputs${funcx:+, ignoring nil values}";
pattern $func$funcx(v:any_1,b:bat[:any_1],s:bat[:oid]) :bat[:any_1]
address CMDbat${func^^}$funcx
comment "Return bat with ${func}imum value of each pair of inputs${funcx:+, ignoring nil values}";

EOF
    done
done
echo

for func in +:ADD -:SUB \*:MUL; do
    name=${func#*:}
    op=${func%:*}
    for tp1 in bte sht int lng flt; do
	for tp2 in bte sht int lng flt; do
	    case $tp1$tp2 in
	    *flt*) tp3=dbl;;
	    *lng*) continue;;	# lng only allowed in combination with flt
	    *int*) tp3=lng;;
	    *sht*) tp3=int;;
	    *bte*) tp3=sht;;
	    esac
	    cat <<EOF
pattern $op(b1:bat[:$tp1],b2:bat[:$tp2]) :bat[:$tp3]
address CMDbat${name}enlarge
comment "Return B1 $op B2, guarantee no overflow by returning larger type";
pattern $op(b1:bat[:$tp1],b2:bat[:$tp2],s:bat[:oid]) :bat[:$tp3]
address CMDbat${name}enlarge
comment "Return B1 $op B2 with candidates list, guarantee no overflow by returning larger type";
pattern $op(b:bat[:$tp1],v:$tp2) :bat[:$tp3]
address CMDbat${name}enlarge
comment "Return B $op V, guarantee no overflow by returning larger type";
pattern $op(b:bat[:$tp1],v:$tp2,s:bat[:oid]) :bat[:$tp3]
address CMDbat${name}enlarge
comment "Return B $op V with candidates list, guarantee no overflow by returning larger type";
pattern $op(v:$tp1,b:bat[:$tp2]) :bat[:$tp3]
address CMDbat${name}enlarge
comment "Return V $op B, guarantee no overflow by returning larger type";
pattern $op(v:$tp1,b:bat[:$tp2],s:bat[:oid]) :bat[:$tp3]
address CMDbat${name}enlarge
comment "Return V $op B with candidates list, guarantee no overflow by returning larger type";

EOF
	done
    done
    echo
done

for func in +:ADD -:SUB \*:MUL; do
    name=${func#*:}
    op=${func%:*}
    for tp1 in $numeric; do
	for tp2 in $numeric; do
	    case $tp1$tp2 in
	    *dbl*) tp3=dbl;;
	    *flt*) tp3=flt;;
	    *lng*) tp3=lng;;
	    *int*) tp3=int;;
	    *sht*) tp3=sht;;
	    *bte*) tp3=bte;;
	    esac
	    cat <<EOF
pattern $op(b1:bat[:$tp1],b2:bat[:$tp2]) :bat[:$tp3]
address CMDbat${name}signal
comment "Return B1 $op B2, signal error on overflow";
pattern $op(b1:bat[:$tp1],b2:bat[:$tp2],s:bat[:oid]) :bat[:$tp3]
address CMDbat${name}signal
comment "Return B1 $op B2 with candidates list, signal error on overflow";
pattern ${name,,}_noerror(b1:bat[:$tp1],b2:bat[:$tp2]) :bat[:$tp3]
address CMDbat${name}
comment "Return B1 $op B2, overflow causes NIL value";
pattern ${name,,}_noerror(b1:bat[:$tp1],b2:bat[:$tp2],s:bat[:oid]) :bat[:$tp3]
address CMDbat${name}
comment "Return B1 $op B2 with candidates list, overflow causes NIL value";
pattern $op(b:bat[:$tp1],v:$tp2) :bat[:$tp3]
address CMDbat${name}signal
comment "Return B $op V, signal error on overflow";
pattern $op(b:bat[:$tp1],v:$tp2,s:bat[:oid]) :bat[:$tp3]
address CMDbat${name}signal
comment "Return B $op V with candidates list, signal error on overflow";
pattern ${name,,}_noerror(b:bat[:$tp1],v:$tp2) :bat[:$tp3]
address CMDbat${name}
comment "Return B $op V, overflow causes NIL value";
pattern ${name,,}_noerror(b:bat[:$tp1],v:$tp2,s:bat[:oid]) :bat[:$tp3]
address CMDbat${name}
comment "Return B $op V with candidates list, overflow causes NIL value";
pattern $op(v:$tp1,b:bat[:$tp2]) :bat[:$tp3]
address CMDbat${name}signal
comment "Return V $op B, signal error on overflow";
pattern $op(v:$tp1,b:bat[:$tp2],s:bat[:oid]) :bat[:$tp3]
address CMDbat${name}signal
comment "Return V $op B with candidates list, signal error on overflow";
pattern ${name,,}_noerror(v:$tp1,b:bat[:$tp2]) :bat[:$tp3]
address CMDbat${name}
comment "Return V $op B, overflow causes NIL value";
pattern ${name,,}_noerror(v:$tp1,b:bat[:$tp2],s:bat[:oid]) :bat[:$tp3]
address CMDbat${name}
comment "Return V $op B with candidates list, overflow causes NIL value";

EOF
	done
    done
    echo
done

cat <<EOF
pattern +(b1:bat[:str],b2:bat[:str]) :bat[:str]
address CMDbatADD
comment "Return concatenation of B1 and B2";
pattern +(b1:bat[:str],b2:bat[:str],s:bat[:oid]) :bat[:str]
address CMDbatADD
comment "Return concatenation of B1 and B2 with candidates list";
pattern +(b:bat[:str],v:str) :bat[:str]
address CMDbatADD
comment "Return concatenation of B and V";
pattern +(b:bat[:str],v:str,s:bat[:oid]) :bat[:str]
address CMDbatADD
comment "Return concatenation of B and V with candidates list";
pattern +(v:str,b:bat[:str]) :bat[:str]
address CMDbatADD
comment "Return concatenation of V and B";
pattern +(v:str,b:bat[:str],s:bat[:oid]) :bat[:str]
address CMDbatADD
comment "Return concatenation of V and B with candidates list";

EOF

for tp1 in $numeric; do
    for tp2 in $numeric; do
	case $tp1$tp2 in
	*dbl*) tp3=dbl;;
	*flt*) tp3=flt;;
	lng*) tp3=lng;;
	int*) tp3=int;;
	sht*) tp3=sht;;
	bte*) tp3=bte;;
	esac
	cat <<EOF
pattern /(b1:bat[:$tp1],b2:bat[:$tp2]) :bat[:$tp3]
address CMDbatDIVsignal
comment "Return B1 / B2, signal error on overflow";
pattern /(b1:bat[:$tp1],b2:bat[:$tp2],s:bat[:oid]) :bat[:$tp3]
address CMDbatDIVsignal
comment "Return B1 / B2 with candidates list, signal error on overflow";
pattern div_noerror(b1:bat[:$tp1],b2:bat[:$tp2]) :bat[:$tp3]
address CMDbatDIV
comment "Return B1 / B2, overflow causes NIL value";
pattern div_noerror(b1:bat[:$tp1],b2:bat[:$tp2],s:bat[:oid]) :bat[:$tp3]
address CMDbatDIV
comment "Return B1 / B2 with candidates list, overflow causes NIL value";
pattern /(b:bat[:$tp1],v:$tp2) :bat[:$tp3]
address CMDbatDIVsignal
comment "Return B / V, signal error on overflow";
pattern /(b:bat[:$tp1],v:$tp2,s:bat[:oid]) :bat[:$tp3]
address CMDbatDIVsignal
comment "Return B / V with candidates list, signal error on overflow";
pattern div_noerror(b:bat[:$tp1],v:$tp2) :bat[:$tp3]
address CMDbatDIV
comment "Return B / V, overflow causes NIL value";
pattern div_noerror(b:bat[:$tp1],v:$tp2,s:bat[:oid]) :bat[:$tp3]
address CMDbatDIV
comment "Return B / V with candidates list, overflow causes NIL value";
pattern /(v:$tp1,b:bat[:$tp2]) :bat[:$tp3]
address CMDbatDIVsignal
comment "Return V / B, signal error on overflow";
pattern /(v:$tp1,b:bat[:$tp2],s:bat[:oid]) :bat[:$tp3]
address CMDbatDIVsignal
comment "Return V / B with candidates list, signal error on overflow";
pattern div_noerror(v:$tp1,b:bat[:$tp2]) :bat[:$tp3]
address CMDbatDIV
comment "Return V / B, overflow causes NIL value";
pattern div_noerror(v:$tp1,b:bat[:$tp2],s:bat[:oid]) :bat[:$tp3]
address CMDbatDIV
comment "Return V / B with candidates list, overflow causes NIL value";

EOF
    done
done
    echo

for tp1 in $numeric; do
    for tp2 in $numeric; do
	case $tp1$tp2 in
	*dbl*) tp3=dbl;;
	*flt*) tp3=flt;;
	*bte*) tp3=bte;;
	*sht*) tp3=sht;;
	*int*) tp3=int;;
	*lng*) tp3=lng;;
	esac
	cat <<EOF
pattern %(b1:bat[:$tp1],b2:bat[:$tp2]) :bat[:$tp3]
address CMDbatMODsignal
comment "Return B1 % B2, signal error on divide by zero";
pattern %(b1:bat[:$tp1],b2:bat[:$tp2],s:bat[:oid]) :bat[:$tp3]
address CMDbatMODsignal
comment "Return B1 % B2 with candidates list, signal error on divide by zero";
pattern mod_noerror(b1:bat[:$tp1],b2:bat[:$tp2]) :bat[:$tp3]
address CMDbatMOD
comment "Return B1 % B2, divide by zero causes NIL value";
pattern mod_noerror(b1:bat[:$tp1],b2:bat[:$tp2],s:bat[:oid]) :bat[:$tp3]
address CMDbatMOD
comment "Return B1 % B2 with candidates list, divide by zero causes NIL value";
pattern %(b:bat[:$tp1],v:$tp2) :bat[:$tp3]
address CMDbatMODsignal
comment "Return B % V, signal error on divide by zero";
pattern %(b:bat[:$tp1],v:$tp2,s:bat[:oid]) :bat[:$tp3]
address CMDbatMODsignal
comment "Return B % V with candidates list, signal error on divide by zero";
pattern mod_noerror(b:bat[:$tp1],v:$tp2) :bat[:$tp3]
address CMDbatMOD
comment "Return B % V, divide by zero causes NIL value";
pattern mod_noerror(b:bat[:$tp1],v:$tp2,s:bat[:oid]) :bat[:$tp3]
address CMDbatMOD
comment "Return B % V with candidates list, divide by zero causes NIL value";
pattern %(v:$tp1,b:bat[:$tp2]) :bat[:$tp3]
address CMDbatMODsignal
comment "Return V % B, signal error on divide by zero";
pattern %(v:$tp1,b:bat[:$tp2],s:bat[:oid]) :bat[:$tp3]
address CMDbatMODsignal
comment "Return V % B with candidates list, signal error on divide by zero";
pattern mod_noerror(v:$tp1,b:bat[:$tp2]) :bat[:$tp3]
address CMDbatMOD
comment "Return V % B, divide by zero causes NIL value";
pattern mod_noerror(v:$tp1,b:bat[:$tp2],s:bat[:oid]) :bat[:$tp3]
address CMDbatMOD
comment "Return V % B with candidates list, divide by zero causes NIL value";

EOF
    done
done
echo

for op in and or xor; do
    for tp in bit $integer; do
	cat <<EOF
pattern ${op}(b1:bat[:$tp],b2:bat[:$tp]) :bat[:$tp]
address CMDbat${op^^}
comment "Return B1 ${op^^} B2";
pattern ${op}(b1:bat[:$tp],b2:bat[:$tp],s:bat[:oid]) :bat[:$tp]
address CMDbat${op^^}
comment "Return B1 ${op^^} B2 with candidates list";
pattern $op(b:bat[:$tp],v:$tp) :bat[:$tp]
address CMDbat${op^^}
comment "Return B ${op^^} V";
pattern $op(b:bat[:$tp],v:$tp,s:bat[:oid]) :bat[:$tp]
address CMDbat${op^^}
comment "Return B ${op^^} V with candidates list";
pattern $op(v:$tp,b:bat[:$tp]) :bat[:$tp]
address CMDbat${op^^}
comment "Return V ${op^^} B";
pattern $op(v:$tp,b:bat[:$tp],s:bat[:oid]) :bat[:$tp]
address CMDbat${op^^}
comment "Return V ${op^^} B with candidates list";

EOF
    done
    echo
done

for func in '<<:lsh' '>>:rsh'; do
    op=${func%:*}
    func=${func#*:}
    for tp1 in $integer; do
	for tp2 in $integer; do
	    cat <<EOF
pattern $op(b1:bat[:$tp1],b2:bat[:$tp2]) :bat[:$tp1]
address CMDbat${func^^}signal
comment "Return B1 $op B2, raise error on out of range second operand";
pattern $op(b1:bat[:$tp1],b2:bat[:$tp2],s:bat[:oid]) :bat[:$tp1]
address CMDbat${func^^}signal
comment "Return B1 $op B2 with candidates list, raise error on out of range second operand";
pattern ${func}_noerror(b1:bat[:$tp1],b2:bat[:$tp2]) :bat[:$tp1]
address CMDbat${func^^}
comment "Return B1 $op B2, out of range second operand causes NIL value";
pattern ${func}_noerror(b1:bat[:$tp1],b2:bat[:$tp2],s:bat[:oid]) :bat[:$tp1]
address CMDbat${func^^}
comment "Return B1 $op B2 with candidates list, out of range second operand causes NIL value";
pattern $op(b:bat[:$tp1],v:$tp2) :bat[:$tp1]
address CMDbat${func^^}signal
comment "Return B $op V, raise error on out of range second operand";
pattern $op(b:bat[:$tp1],v:$tp2,s:bat[:oid]) :bat[:$tp1]
address CMDbat${func^^}signal
comment "Return B $op V with candidates list, raise error on out of range second operand";
pattern ${func}_noerror(b:bat[:$tp1],v:$tp2) :bat[:$tp1]
address CMDbat${func^^}
comment "Return B $op V, out of range second operand causes NIL value";
pattern ${func}_noerror(b:bat[:$tp1],v:$tp2,s:bat[:oid]) :bat[:$tp1]
address CMDbat${func^^}
comment "Return B $op V with candidates list, out of range second operand causes NIL value";
pattern $op(v:$tp1,b:bat[:$tp2]) :bat[:$tp1]
address CMDbat${func^^}signal
comment "Return V $op B, raise error on out of range second operand";
pattern $op(v:$tp1,b:bat[:$tp2],s:bat[:oid]) :bat[:$tp1]
address CMDbat${func^^}signal
comment "Return V $op B with candidates list, raise error on out of range second operand";
pattern ${func}_noerror(v:$tp1,b:bat[:$tp2]) :bat[:$tp1]
address CMDbat${func^^}
comment "Return V $op B, out of range second operand causes NIL value";
pattern ${func}_noerror(v:$tp1,b:bat[:$tp2],s:bat[:oid]) :bat[:$tp1]
address CMDbat${func^^}
comment "Return V $op B with candidates list, out of range second operand causes NIL value";

EOF
	done
    done
    echo
done

for func in '<:lt' '<=:le' '>:gt' '>=:ge' '==:eq' '!=:ne'; do
    op=${func%:*}
    func=${func#*:}
    for tp in bit str oid; do
	cat <<EOF
pattern $op(b1:bat[:$tp],b2:bat[:$tp]) :bat[:bit]
address CMDbat${func^^}
comment "Return B1 $op B2";
pattern $op(b1:bat[:$tp],b2:bat[:$tp],s:bat[:oid]) :bat[:bit]
address CMDbat${func^^}
comment "Return B1 $op B2 with candidates list";
pattern $op(b:bat[:$tp],v:$tp) :bat[:bit]
address CMDbat${func^^}
comment "Return B $op V";
pattern $op(b:bat[:$tp],v:$tp,s:bat[:oid]) :bat[:bit]
address CMDbat${func^^}
comment "Return B $op V with candidates list";
pattern $op(v:$tp,b:bat[:$tp]) :bat[:bit]
address CMDbat${func^^}
comment "Return V $op B";
pattern $op(v:$tp,b:bat[:$tp],s:bat[:oid]) :bat[:bit]
address CMDbat${func^^}
comment "Return V $op B with candidates list";

EOF
    done
    for tp1 in $numeric; do
	for tp2 in $numeric; do
	    cat <<EOF
pattern $op(b1:bat[:$tp1],b2:bat[:$tp2]) :bat[:bit]
address CMDbat${func^^}
comment "Return B1 $op B2";
pattern $op(b1:bat[:$tp1],b2:bat[:$tp2],s:bat[:oid]) :bat[:bit]
address CMDbat${func^^}
comment "Return B1 $op B2 with candidates list";
pattern $op(b:bat[:$tp1],v:$tp2) :bat[:bit]
address CMDbat${func^^}
comment "Return B $op V";
pattern $op(b:bat[:$tp1],v:$tp2,s:bat[:oid]) :bat[:bit]
address CMDbat${func^^}
comment "Return B $op V with candidates list";
pattern $op(v:$tp1,b:bat[:$tp2]) :bat[:bit]
address CMDbat${func^^}
comment "Return V $op B";
pattern $op(v:$tp1,b:bat[:$tp2],s:bat[:oid]) :bat[:bit]
address CMDbat${func^^}
comment "Return V $op B with candidates list";

EOF
	done
    done
    echo
done

op=${func%:*}
func=${func#*:}
for tp in bit str oid; do
    cat <<EOF
pattern cmp(b1:bat[:$tp],b2:bat[:$tp]) :bat[:bte]
address CMDbatCMP
comment "Return -1/0/1 if B1 </==/> B2";
pattern cmp(b1:bat[:$tp],b2:bat[:$tp],s:bat[:oid]) :bat[:bte]
address CMDbatCMP
comment "Return -1/0/1 if B1 </==/> B2 with candidates list";
pattern cmp(b:bat[:$tp],v:$tp) :bat[:bte]
address CMDbatCMP
comment "Return -1/0/1 if B </==/> V";
pattern cmp(v:$tp,b:bat[:$tp]) :bat[:bte]
address CMDbatCMP
comment "Return -1/0/1 if V </==/> B";
pattern cmp(b:bat[:$tp],v:$tp,s:bat[:oid]) :bat[:bte]
address CMDbatCMP
comment "Return -1/0/1 if B </==/> V with candidates list";
pattern cmp(v:$tp,b:bat[:$tp],s:bat[:oid]) :bat[:bte]
address CMDbatCMP
comment "Return -1/0/1 if V </==/> B with candidates list";

EOF
done
for tp1 in $numeric; do
    for tp2 in $numeric; do
	cat <<EOF
pattern cmp(b1:bat[:$tp1],b2:bat[:$tp2]) :bat[:bte]
address CMDbatCMP
comment "Return -1/0/1 if B1 </==/> B2";
pattern cmp(b1:bat[:$tp1],b2:bat[:$tp2],s:bat[:oid]) :bat[:bte]
address CMDbatCMP
comment "Return -1/0/1 if B1 </==/> B2 with candidates list";
pattern cmp(b:bat[:$tp1],v:$tp2) :bat[:bte]
address CMDbatCMP
comment "Return -1/0/1 if B </==/> V";
pattern cmp(v:$tp1,b:bat[:$tp2]) :bat[:bte]
address CMDbatCMP
comment "Return -1/0/1 if V </==/> B";
pattern cmp(b:bat[:$tp1],v:$tp2,s:bat[:oid]) :bat[:bte]
address CMDbatCMP
comment "Return -1/0/1 if B </==/> V with candidates list";
pattern cmp(v:$tp1,b:bat[:$tp2],s:bat[:oid]) :bat[:bte]
address CMDbatCMP
comment "Return -1/0/1 if V </==/> B with candidates list";

EOF
    done
done
echo

cat <<EOF
pattern between(b:bat[:any_1],lo:bat[:any_1],hi:bat[:any_1]) :bat[:bit]
address CMDbatBETWEEN
comment "B between LO and HI inclusive";
pattern between(b:bat[:any_1],lo:bat[:any_1],hi:bat[:any_1],s:bat[:oid]) :bat[:bit]
address CMDbatBETWEEN
comment "B between LO and HI inclusive with candidates list";
pattern between(b:bat[:any_1],lo:bat[:any_1],hi:any_1) :bat[:bit]
address CMDbatBETWEEN
comment "B between LO and HI inclusive";
pattern between(b:bat[:any_1],lo:bat[:any_1],hi:any_1,s:bat[:oid]) :bat[:bit]
address CMDbatBETWEEN
comment "B between LO and HI inclusive with candidates list";
pattern between(b:bat[:any_1],lo:any_1,hi:bat[:any_1]) :bat[:bit]
address CMDbatBETWEEN
comment "B between LO and HI inclusive";
pattern between(b:bat[:any_1],lo:any_1,hi:bat[:any_1],s:bat[:oid]) :bat[:bit]
address CMDbatBETWEEN
comment "B between LO and HI inclusive with candidates list";
pattern between(b:bat[:any_1],lo:any_1,hi:any_1) :bat[:bit]
address CMDbatBETWEEN
comment "B between LO and HI inclusive";
pattern between(b:bat[:any_1],lo:any_1,hi:any_1,s:bat[:oid]) :bat[:bit]
address CMDbatBETWEEN
comment "B between LO and HI inclusive with candidates list";

pattern between_symmetric(b:bat[:any_1],v1:bat[:any_1],v2:bat[:any_1]) :bat[:bit]
address CMDbatBETWEENsymmetric
comment "B between V1 and V2 (or vice versa) inclusive";
pattern between_symmetric(b:bat[:any_1],v1:bat[:any_1],v2:bat[:any_1],s:bat[:oid]) :bat[:bit]
address CMDbatBETWEENsymmetric
comment "B between V1 and V2 (or vice versa) inclusive with candidates list";
pattern between_symmetric(b:bat[:any_1],v1:bat[:any_1],v2:any_1) :bat[:bit]
address CMDbatBETWEENsymmetric
comment "B between V1 and V2 (or vice versa) inclusive";
pattern between_symmetric(b:bat[:any_1],v1:bat[:any_1],v2:any_1,s:bat[:oid]) :bat[:bit]
address CMDbatBETWEENsymmetric
comment "B between V1 and V2 (or vice versa) inclusive with candidates list";
pattern between_symmetric(b:bat[:any_1],v1:any_1,v2:bat[:any_1]) :bat[:bit]
address CMDbatBETWEENsymmetric
comment "B between V1 and V2 (or vice versa) inclusive";
pattern between_symmetric(b:bat[:any_1],v1:any_1,v2:bat[:any_1],s:bat[:oid]) :bat[:bit]
address CMDbatBETWEENsymmetric
comment "B between V1 and V2 (or vice versa) inclusive with candidates list";
pattern between_symmetric(b:bat[:any_1],v1:any_1,v2:any_1) :bat[:bit]
address CMDbatBETWEENsymmetric
comment "B between V1 and V2 (or vice versa) inclusive";
pattern between_symmetric(b:bat[:any_1],v1:any_1,v2:any_1,s:bat[:oid]) :bat[:bit]
address CMDbatBETWEENsymmetric
comment "B between V1 and V2 (or vice versa) inclusive with candidates list";

EOF
echo

for tp in $numeric; do
    cat <<EOF
pattern avg(b:bat[:$tp]) :dbl
address CMDcalcavg
comment "average of non-nil values of B with candidates list";
pattern avg(b:bat[:$tp],s:bat[:oid]) :dbl
address CMDcalcavg
comment "average of non-nil values of B";
pattern avg(b:bat[:$tp]) (:dbl, :lng)
address CMDcalcavg
comment "average and number of non-nil values of B";
pattern avg(b:bat[:$tp],s:bat[:oid]) (:dbl, :lng)
address CMDcalcavg
comment "average and number of non-nil values of B with candidates list";

EOF
done

for tp1 in $alltypes; do
    if [[ $tp1 == str ]]; then
	cat <<EOF
pattern $tp1(b:bat[:any]) :bat[:$tp1]
address CMDconvertsignal_$tp1
comment "cast from any to $tp1, signal error on overflow";
pattern $tp1(b:bat[:any],s:bat[:oid]) :bat[:$tp1]
address CMDconvertsignal_$tp1
comment "cast from any to $tp1 with candidates list, signal error on overflow";
pattern ${tp1}_noerror(b:bat[:any]) :bat[:$tp1]
address CMDconvert_$tp1
comment "cast from any to $tp1";
pattern ${tp1}_noerror(b:bat[:any],s:bat[:oid]) :bat[:$tp1]
address CMDconvert_$tp1
comment "cast from any to $tp1 with candidates list";

EOF
    else
	for tp2 in $alltypes; do
	    cat <<EOF
pattern $tp1(b:bat[:$tp2]) :bat[:$tp1]
address CMDconvertsignal_$tp1
comment "cast from $tp2 to $tp1, signal error on overflow";
pattern $tp1(b:bat[:$tp2],s:bat[:oid]) :bat[:$tp1]
address CMDconvertsignal_$tp1
comment "cast from $tp2 to $tp1 with candidates list, signal error on overflow";
pattern ${tp1}_noerror(b:bat[:$tp2]) :bat[:$tp1]
address CMDconvert_$tp1
comment "cast from $tp2 to $tp1";
pattern ${tp1}_noerror(b:bat[:$tp2],s:bat[:oid]) :bat[:$tp1]
address CMDconvert_$tp1
comment "cast from $tp2 to $tp1 with candidates list";

EOF
	done
    fi
done

cat <<EOF
pattern ifthenelse(v:bit, b1:bat[:any_1], b2:bat[:any_1]) :bat[:any_1]
address CMDifthen
comment "If-then-else operation to assemble a conditional result";

pattern ifthenelse(v:bit, v1:any_1, b2:bat[:any_1]) :bat[:any_1]
address CMDifthen
comment "If-then-else operation to assemble a conditional result";

pattern ifthenelse(v:bit, b1:bat[:any_1], v2:any_1) :bat[:any_1]
address CMDifthen
comment "If-then-else operation to assemble a conditional result";

pattern ifthenelse(b:bat[:bit], v1:any_1, v2:any_1) :bat[:any_1]
address CMDifthen
comment "If-then-else operation to assemble a conditional result";

pattern ifthenelse(b:bat[:bit], b1:bat[:any_1], v2:any_1) :bat[:any_1]
address CMDifthen
comment "If-then-else operation to assemble a conditional result";

pattern ifthenelse(b:bat[:bit], v1:any_1, b2:bat[:any_1]) :bat[:any_1]
address CMDifthen
comment "If-then-else operation to assemble a conditional result";

pattern ifthenelse(b:bat[:bit], b1:bat[:any_1], b2:bat[:any_1]) :bat[:any_1]
address CMDifthen
comment "If-then-else operation to assemble a conditional result";

EOF
