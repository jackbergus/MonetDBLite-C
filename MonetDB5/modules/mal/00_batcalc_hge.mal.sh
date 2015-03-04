# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0.  If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright 2008-2015 MonetDB B.V.

sed '/^$/q' $0			# copy copyright from this file

cat <<EOF
# This file was generated by using the script ${0##*/}.

module batcalc;

EOF

integer="bte sht int wrd lng hge"	# all integer types
numeric="$integer flt dbl"	# all numeric types
alltypes="bit $numeric oid str"

for tp in hge; do
    cat <<EOF
pattern iszero(b:bat[:oid,:$tp]) :bat[:oid,:bit]
address CMDbatISZERO
comment "Unary check for zero over the tail of the bat";
pattern iszero(b:bat[:oid,:$tp],s:bat[:oid,:oid]) :bat[:oid,:bit]
address CMDbatISZERO
comment "Unary check for zero over the tail of the bat with candidates list";

EOF
done
echo

com="Unary bitwise not over the tail of the bat"
for tp in hge; do
    cat <<EOF
pattern not(b:bat[:oid,:$tp]) :bat[:oid,:$tp]
address CMDbatNOT
comment "$com";
pattern not(b:bat[:oid,:$tp],s:bat[:oid,:oid]) :bat[:oid,:$tp]
address CMDbatNOT
comment "$com with candidates list";

EOF
done
echo

for tp in hge; do
    cat <<EOF
pattern sign(b:bat[:oid,:$tp]) :bat[:oid,:bte]
address CMDbatSIGN
comment "Unary sign (-1,0,1) over the tail of the bat";
pattern sign(b:bat[:oid,:$tp],s:bat[:oid,:oid]) :bat[:oid,:bte]
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
    for tp in hge; do
	cat <<EOF
pattern $op(b:bat[:oid,:$tp]) :bat[:oid,:$tp]
address CMDbat${func}
comment "$com";
pattern $op(b:bat[:oid,:$tp],s:bat[:oid,:oid]) :bat[:oid,:$tp]
address CMDbat${func}
comment "$com with candidates list";

EOF
    done
    echo
done

for func in +:ADD -:SUB \*:MUL; do
    name=${func#*:}
    op=${func%:*}
    for tp1 in bte sht int lng hge flt; do
	for tp2 in bte sht int lng hge flt; do
	    case $tp1$tp2 in
	    hgeflt|flthge)
		tp3=dbl;;
	    *flt*|*hge*)
		continue;;
	    *lng*)
		tp3=hge;;
	    *)
		continue;;
	    esac
	    cat <<EOF
pattern $op(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2]) :bat[:oid,:$tp3]
address CMDbat${name}enlarge
comment "Return B1 $op B2, guarantee no overflow by returning larger type";
pattern $op(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:$tp3]
address CMDbat${name}enlarge
comment "Return B1 $op B2 with candidates list, guarantee no overflow by returning larger type";
pattern $op(b:bat[:oid,:$tp1],v:$tp2) :bat[:oid,:$tp3]
address CMDbat${name}enlarge
comment "Return B $op V, guarantee no overflow by returning larger type";
pattern $op(b:bat[:oid,:$tp1],v:$tp2,s:bat[:oid,:oid]) :bat[:oid,:$tp3]
address CMDbat${name}enlarge
comment "Return B $op V with candidates list, guarantee no overflow by returning larger type";
pattern $op(v:$tp1,b:bat[:oid,:$tp2]) :bat[:oid,:$tp3]
address CMDbat${name}enlarge
comment "Return V $op B, guarantee no overflow by returning larger type";
pattern $op(v:$tp1,b:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:$tp3]
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
	    hgedbl|dblhge)
		tp3=dbl;;
	    hgeflt|flthge)
		tp3=flt;;
	    *hge*)
		tp3=hge;;
	    *)
		continue;;
	    esac
	    cat <<EOF
pattern $op(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2]) :bat[:oid,:$tp3]
address CMDbat${name}signal
comment "Return B1 $op B2, signal error on overflow";
pattern $op(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:$tp3]
address CMDbat${name}signal
comment "Return B1 $op B2 with candidates list, signal error on overflow";
pattern ${name,,}_noerror(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2]) :bat[:oid,:$tp3]
address CMDbat${name}
comment "Return B1 $op B2, overflow causes NIL value";
pattern ${name,,}_noerror(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:$tp3]
address CMDbat${name}
comment "Return B1 $op B2 with candidates list, overflow causes NIL value";
pattern $op(b:bat[:oid,:$tp1],v:$tp2) :bat[:oid,:$tp3]
address CMDbat${name}signal
comment "Return B $op V, signal error on overflow";
pattern $op(b:bat[:oid,:$tp1],v:$tp2,s:bat[:oid,:oid]) :bat[:oid,:$tp3]
address CMDbat${name}signal
comment "Return B $op V with candidates list, signal error on overflow";
pattern ${name,,}_noerror(b:bat[:oid,:$tp1],v:$tp2) :bat[:oid,:$tp3]
address CMDbat${name}
comment "Return B $op V, overflow causes NIL value";
pattern ${name,,}_noerror(b:bat[:oid,:$tp1],v:$tp2,s:bat[:oid,:oid]) :bat[:oid,:$tp3]
address CMDbat${name}
comment "Return B $op V with candidates list, overflow causes NIL value";
pattern $op(v:$tp1,b:bat[:oid,:$tp2]) :bat[:oid,:$tp3]
address CMDbat${name}signal
comment "Return V $op B, signal error on overflow";
pattern $op(v:$tp1,b:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:$tp3]
address CMDbat${name}signal
comment "Return V $op B with candidates list, signal error on overflow";
pattern ${name,,}_noerror(v:$tp1,b:bat[:oid,:$tp2]) :bat[:oid,:$tp3]
address CMDbat${name}
comment "Return V $op B, overflow causes NIL value";
pattern ${name,,}_noerror(v:$tp1,b:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:$tp3]
address CMDbat${name}
comment "Return V $op B with candidates list, overflow causes NIL value";

EOF
	done
    done
    echo
done

for tp1 in $numeric; do
    for tp2 in $numeric; do
	case $tp1$tp2 in
	hgedbl|dblhge)
	    tp3=dbl;;
	hgeflt|flthge)
	    tp3=flt;;
	*hge*)
	    tp3=$tp1;;
	*)
	    continue;;
	esac
	cat <<EOF
pattern /(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2]) :bat[:oid,:$tp3]
address CMDbatDIVsignal
comment "Return B1 / B2, signal error on overflow";
pattern /(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:$tp3]
address CMDbatDIVsignal
comment "Return B1 / B2 with candidates list, signal error on overflow";
pattern div_noerror(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2]) :bat[:oid,:$tp3]
address CMDbatDIV
comment "Return B1 / B2, overflow causes NIL value";
pattern div_noerror(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:$tp3]
address CMDbatDIV
comment "Return B1 / B2 with candidates list, overflow causes NIL value";
pattern /(b:bat[:oid,:$tp1],v:$tp2) :bat[:oid,:$tp3]
address CMDbatDIVsignal
comment "Return B / V, signal error on overflow";
pattern /(b:bat[:oid,:$tp1],v:$tp2,s:bat[:oid,:oid]) :bat[:oid,:$tp3]
address CMDbatDIVsignal
comment "Return B / V with candidates list, signal error on overflow";
pattern div_noerror(b:bat[:oid,:$tp1],v:$tp2) :bat[:oid,:$tp3]
address CMDbatDIV
comment "Return B / V, overflow causes NIL value";
pattern div_noerror(b:bat[:oid,:$tp1],v:$tp2,s:bat[:oid,:oid]) :bat[:oid,:$tp3]
address CMDbatDIV
comment "Return B / V with candidates list, overflow causes NIL value";
pattern /(v:$tp1,b:bat[:oid,:$tp2]) :bat[:oid,:$tp3]
address CMDbatDIVsignal
comment "Return V / B, signal error on overflow";
pattern /(v:$tp1,b:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:$tp3]
address CMDbatDIVsignal
comment "Return V / B with candidates list, signal error on overflow";
pattern div_noerror(v:$tp1,b:bat[:oid,:$tp2]) :bat[:oid,:$tp3]
address CMDbatDIV
comment "Return V / B, overflow causes NIL value";
pattern div_noerror(v:$tp1,b:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:$tp3]
address CMDbatDIV
comment "Return V / B with candidates list, overflow causes NIL value";

EOF
    done
done
    echo

for tp1 in $numeric; do
    for tp2 in $numeric; do
	case $tp1$tp2 in
	*hge*)
	    case $tp1$tp2 in
	    *dbl*) tp3=dbl;;
	    *flt*) tp3=flt;;
	    *bte*) tp3=bte;;
	    *sht*) tp3=sht;;
	    *int*) tp3=int;;
	    *wrd*) tp3=wrd;;
	    *lng*) tp3=lng;;
	    *hge*) tp3=hge;;
	    esac
	    ;;
	*)
	    continue
	    ;;
	esac
	cat <<EOF
pattern %(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2]) :bat[:oid,:$tp3]
address CMDbatMODsignal
comment "Return B1 % B2, signal error on divide by zero";
pattern %(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:$tp3]
address CMDbatMODsignal
comment "Return B1 % B2 with candidates list, signal error on divide by zero";
pattern mod_noerror(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2]) :bat[:oid,:$tp3]
address CMDbatMOD
comment "Return B1 % B2, divide by zero causes NIL value";
pattern mod_noerror(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:$tp3]
address CMDbatMOD
comment "Return B1 % B2 with candidates list, divide by zero causes NIL value";
pattern %(b:bat[:oid,:$tp1],v:$tp2) :bat[:oid,:$tp3]
address CMDbatMODsignal
comment "Return B % V, signal error on divide by zero";
pattern %(b:bat[:oid,:$tp1],v:$tp2,s:bat[:oid,:oid]) :bat[:oid,:$tp3]
address CMDbatMODsignal
comment "Return B % V with candidates list, signal error on divide by zero";
pattern mod_noerror(b:bat[:oid,:$tp1],v:$tp2) :bat[:oid,:$tp3]
address CMDbatMOD
comment "Return B % V, divide by zero causes NIL value";
pattern mod_noerror(b:bat[:oid,:$tp1],v:$tp2,s:bat[:oid,:oid]) :bat[:oid,:$tp3]
address CMDbatMOD
comment "Return B % V with candidates list, divide by zero causes NIL value";
pattern %(v:$tp1,b:bat[:oid,:$tp2]) :bat[:oid,:$tp3]
address CMDbatMODsignal
comment "Return V % B, signal error on divide by zero";
pattern %(v:$tp1,b:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:$tp3]
address CMDbatMODsignal
comment "Return V % B with candidates list, signal error on divide by zero";
pattern mod_noerror(v:$tp1,b:bat[:oid,:$tp2]) :bat[:oid,:$tp3]
address CMDbatMOD
comment "Return V % B, divide by zero causes NIL value";
pattern mod_noerror(v:$tp1,b:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:$tp3]
address CMDbatMOD
comment "Return V % B with candidates list, divide by zero causes NIL value";

EOF
    done
done
echo

for op in and or xor; do
    for tp in hge; do
	cat <<EOF
pattern ${op}(b1:bat[:oid,:$tp],b2:bat[:oid,:$tp]) :bat[:oid,:$tp]
address CMDbat${op^^}
comment "Return B1 ${op^^} B2";
pattern ${op}(b1:bat[:oid,:$tp],b2:bat[:oid,:$tp],s:bat[:oid,:oid]) :bat[:oid,:$tp]
address CMDbat${op^^}
comment "Return B1 ${op^^} B2 with candidates list";
pattern $op(b:bat[:oid,:$tp],v:$tp) :bat[:oid,:$tp]
address CMDbat${op^^}
comment "Return B ${op^^} V";
pattern $op(b:bat[:oid,:$tp],v:$tp,s:bat[:oid,:oid]) :bat[:oid,:$tp]
address CMDbat${op^^}
comment "Return B ${op^^} V with candidates list";
pattern $op(v:$tp,b:bat[:oid,:$tp]) :bat[:oid,:$tp]
address CMDbat${op^^}
comment "Return V ${op^^} B";
pattern $op(v:$tp,b:bat[:oid,:$tp],s:bat[:oid,:oid]) :bat[:oid,:$tp]
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
	    case $tp1$tp2 in
	    *hge*) ;;
	    *) continue;;
	    esac
	    cat <<EOF
pattern $op(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2]) :bat[:oid,:$tp1]
address CMDbat${func^^}signal
comment "Return B1 $op B2, raise error on out of range second operand";
pattern $op(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:$tp1]
address CMDbat${func^^}signal
comment "Return B1 $op B2 with candidates list, raise error on out of range second operand";
pattern ${func}_noerror(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2]) :bat[:oid,:$tp1]
address CMDbat${func^^}
comment "Return B1 $op B2, out of range second operand causes NIL value";
pattern ${func}_noerror(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:$tp1]
address CMDbat${func^^}
comment "Return B1 $op B2 with candidates list, out of range second operand causes NIL value";
pattern $op(b:bat[:oid,:$tp1],v:$tp2) :bat[:oid,:$tp1]
address CMDbat${func^^}signal
comment "Return B $op V, raise error on out of range second operand";
pattern $op(b:bat[:oid,:$tp1],v:$tp2,s:bat[:oid,:oid]) :bat[:oid,:$tp1]
address CMDbat${func^^}signal
comment "Return B $op V with candidates list, raise error on out of range second operand";
pattern ${func}_noerror(b:bat[:oid,:$tp1],v:$tp2) :bat[:oid,:$tp1]
address CMDbat${func^^}
comment "Return B $op V, out of range second operand causes NIL value";
pattern ${func}_noerror(b:bat[:oid,:$tp1],v:$tp2,s:bat[:oid,:oid]) :bat[:oid,:$tp1]
address CMDbat${func^^}
comment "Return B $op V with candidates list, out of range second operand causes NIL value";
pattern $op(v:$tp1,b:bat[:oid,:$tp2]) :bat[:oid,:$tp1]
address CMDbat${func^^}signal
comment "Return V $op B, raise error on out of range second operand";
pattern $op(v:$tp1,b:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:$tp1]
address CMDbat${func^^}signal
comment "Return V $op B with candidates list, raise error on out of range second operand";
pattern ${func}_noerror(v:$tp1,b:bat[:oid,:$tp2]) :bat[:oid,:$tp1]
address CMDbat${func^^}
comment "Return V $op B, out of range second operand causes NIL value";
pattern ${func}_noerror(v:$tp1,b:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:$tp1]
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
    for tp1 in $numeric; do
	for tp2 in $numeric; do
	    case $tp1$tp2 in
	    *hge*) ;;
	    *) continue;;
	    esac
	    cat <<EOF
pattern $op(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2]) :bat[:oid,:bit]
address CMDbat${func^^}
comment "Return B1 $op B2";
pattern $op(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:bit]
address CMDbat${func^^}
comment "Return B1 $op B2 with candidates list";
pattern $op(b:bat[:oid,:$tp1],v:$tp2) :bat[:oid,:bit]
address CMDbat${func^^}
comment "Return B $op V";
pattern $op(b:bat[:oid,:$tp1],v:$tp2,s:bat[:oid,:oid]) :bat[:oid,:bit]
address CMDbat${func^^}
comment "Return B $op V with candidates list";
pattern $op(v:$tp1,b:bat[:oid,:$tp2]) :bat[:oid,:bit]
address CMDbat${func^^}
comment "Return V $op B";
pattern $op(v:$tp1,b:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:bit]
address CMDbat${func^^}
comment "Return V $op B with candidates list";

EOF
	done
    done
    echo
done

op=${func%:*}
func=${func#*:}
for tp1 in $numeric; do
    for tp2 in $numeric; do
	case $tp1$tp2 in
	*hge*) ;;
	*) continue;;
	esac
	cat <<EOF
pattern cmp(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2]) :bat[:oid,:bte]
address CMDbatCMP
comment "Return -1/0/1 if B1 </==/> B2";
pattern cmp(b1:bat[:oid,:$tp1],b2:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:bte]
address CMDbatCMP
comment "Return -1/0/1 if B1 </==/> B2 with candidates list";
pattern cmp(b:bat[:oid,:$tp1],v:$tp2) :bat[:oid,:bte]
address CMDbatCMP
comment "Return -1/0/1 if B </==/> V";
pattern cmp(v:$tp1,b:bat[:oid,:$tp2]) :bat[:oid,:bte]
address CMDbatCMP
comment "Return -1/0/1 if V </==/> B";
pattern cmp(b:bat[:oid,:$tp1],v:$tp2,s:bat[:oid,:oid]) :bat[:oid,:bte]
address CMDbatCMP
comment "Return -1/0/1 if B </==/> V with candidates list";
pattern cmp(v:$tp1,b:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:bte]
address CMDbatCMP
comment "Return -1/0/1 if V </==/> B with candidates list";

EOF
    done
done
echo

for tp in hge; do
    cat <<EOF
pattern between(b:bat[:oid,:$tp],lo:bat[:oid,:$tp],hi:bat[:oid,:$tp]) :bat[:oid,:bit]
address CMDbatBETWEEN
comment "B between LO and HI inclusive, nil border is (minus) infinity";
pattern between(b:bat[:oid,:$tp],lo:bat[:oid,:$tp],hi:bat[:oid,:$tp],s:bat[:oid,:oid]) :bat[:oid,:bit]
address CMDbatBETWEEN
comment "B between LO and HI inclusive with candidates list, nil border is (minus) infinity";
pattern between(b:bat[:oid,:$tp],lo:bat[:oid,:$tp],hi:$tp) :bat[:oid,:bit]
address CMDbatBETWEEN
comment "B between LO and HI inclusive, nil border is (minus) infinity";
pattern between(b:bat[:oid,:$tp],lo:bat[:oid,:$tp],hi:$tp,s:bat[:oid,:oid]) :bat[:oid,:bit]
address CMDbatBETWEEN
comment "B between LO and HI inclusive with candidates list, nil border is (minus) infinity";
pattern between(b:bat[:oid,:$tp],lo:$tp,hi:bat[:oid,:$tp]) :bat[:oid,:bit]
address CMDbatBETWEEN
comment "B between LO and HI inclusive, nil border is (minus) infinity";
pattern between(b:bat[:oid,:$tp],lo:$tp,hi:bat[:oid,:$tp],s:bat[:oid,:oid]) :bat[:oid,:bit]
address CMDbatBETWEEN
comment "B between LO and HI inclusive with candidates list, nil border is (minus) infinity";
pattern between(b:bat[:oid,:$tp],lo:$tp,hi:$tp) :bat[:oid,:bit]
address CMDbatBETWEEN
comment "B between LO and HI inclusive, nil border is (minus) infinity";
pattern between(b:bat[:oid,:$tp],lo:$tp,hi:$tp,s:bat[:oid,:oid]) :bat[:oid,:bit]
address CMDbatBETWEEN
comment "B between LO and HI inclusive with candidates list, nil border is (minus) infinity";

EOF
done
echo

for tp in hge; do
    cat <<EOF
pattern avg(b:bat[:oid,:$tp]) :dbl
address CMDcalcavg
comment "average of non-nil values of B with candidates list";
pattern avg(b:bat[:oid,:$tp],s:bat[:oid,:oid]) :dbl
address CMDcalcavg
comment "average of non-nil values of B";
pattern avg(b:bat[:oid,:$tp]) (:dbl, :lng)
address CMDcalcavg
comment "average and number of non-nil values of B";
pattern avg(b:bat[:oid,:$tp],s:bat[:oid,:oid]) (:dbl, :lng)
address CMDcalcavg
comment "average and number of non-nil values of B with candidates list";

EOF
done

for tp1 in $alltypes; do
    for tp2 in $alltypes; do
	case $tp1$tp2 in
	*hge*) ;;
	*) continue;;
	esac
	cat <<EOF
pattern $tp1(b:bat[:oid,:$tp2]) :bat[:oid,:$tp1]
address CMDconvertsignal_$tp1
comment "cast from $tp2 to $tp1, signal error on overflow";
pattern $tp1(b:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:$tp1]
address CMDconvertsignal_$tp1
comment "cast from $tp2 to $tp1 with candidates list, signal error on overflow";
pattern ${tp1}_noerror(b:bat[:oid,:$tp2]) :bat[:oid,:$tp1]
address CMDconvert_$tp1
comment "cast from $tp2 to $tp1";
pattern ${tp1}_noerror(b:bat[:oid,:$tp2],s:bat[:oid,:oid]) :bat[:oid,:$tp1]
address CMDconvert_$tp1
comment "cast from $tp2 to $tp1 with candidates list";

EOF
    done
done
