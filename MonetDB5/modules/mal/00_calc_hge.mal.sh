# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0.  If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright 1997 - July 2008 CWI, August 2008 - 2016 MonetDB B.V.

sed '/^$/q' $0			# copy copyright from this file

cat <<EOF
# This file was generated by using the script ${0##*/}.

module calc;

EOF

integer="bte sht int wrd lng hge"	# all integer types
numeric="$integer flt dbl"	# all numeric types
fixtypes="bit $numeric oid"
alltypes="$fixtypes str"

for tp in hge; do
    cat <<EOF
pattern iszero(v:$tp) :bit
address CMDvarISZERO
comment "Unary check for zero of V";

EOF
done
echo

com="Unary bitwise not of V"
for tp in hge; do
    cat <<EOF
pattern not(v:$tp) :$tp
address CMDvarNOT
comment "$com";

EOF
done
echo

for tp in hge; do
    cat <<EOF
pattern sign(v:$tp) :bte
address CMDvarSIGN
comment "Unary sign (-1,0,1) of V";

EOF
done
echo

for func in 'abs:ABS:Unary absolute value of V' \
    '-:NEG:Unary negation of V' \
    '++:INCRsignal:Unary V + 1' \
    '--:DECRsignal:Unary V - 1'; do
    op=${func%%:*}
    com=${func##*:}
    func=${func%:*}
    func=${func#*:}
    for tp in hge; do
	cat <<EOF
pattern $op(v:$tp) :$tp
address CMDvar${func}
comment "$com";

EOF
    done
    echo
done

for func in +:ADD -:SUB \*:MUL; do
    name=${func#*:}
    op=${func%:*}
    for tp1 in bte sht int wrd lng hge flt; do
	for tp2 in bte sht int wrd lng hge flt; do
	    case $tp1$tp2 in
	    hgeflt|flthge)
		tp3=dbl;;
	    *flt*|*hge*)
		continue;;	# hge only allowed in combination with flt
	    *lng*|*wrd*)
		tp3=hge;;
	    *)
		continue;;
	    esac
	    cat <<EOF
pattern $op(v1:$tp1,v2:$tp2) :$tp3
address CMDvar${name}signal
comment "Return V1 $op V2, guarantee no overflow by returning larger type";

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
pattern $op(v1:$tp1,v2:$tp2) :$tp3
address CMDvar${name}signal
comment "Return V1 $op V2, signal error on overflow";
pattern ${name,,}_noerror(v1:$tp1,v2:$tp2) :$tp3
address CMDvar${name}
comment "Return V1 $op V2, overflow causes NIL value";

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
	if [ $tp3 != dbl ]; then
	    if [ $tp3 != flt ]; then
		cat <<EOF
pattern /(v1:$tp1,v2:$tp2) :flt
address CMDvarDIVsignal
comment "Return V1 / V2, signal error on overflow";
EOF
	    fi
	    cat <<EOF
pattern /(v1:$tp1,v2:$tp2) :dbl
address CMDvarDIVsignal
comment "Return V1 / V2, signal error on overflow";
EOF
	fi
	cat <<EOF
pattern /(v1:$tp1,v2:$tp2) :$tp3
address CMDvarDIVsignal
comment "Return V1 / V2, signal error on overflow";
pattern div_noerror(v1:$tp1,v2:$tp2) :$tp3
address CMDvarDIV
comment "Return V1 / V2, overflow causes NIL value";

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
pattern %(v1:$tp1,v2:$tp2) :$tp3
address CMDvarMODsignal
comment "Return V1 % V2, signal error on divide by zero";
pattern mod_noerror(v1:$tp1,v2:$tp2) :$tp3
address CMDvarMOD
comment "Return V1 % V2, divide by zero causes NIL value";

EOF
    done
done
echo

for op in and or xor; do
    for tp in hge; do
	cat <<EOF
pattern ${op}(v1:$tp,v2:$tp) :$tp
address CMDvar${op^^}
comment "Return V1 ${op^^} V2";

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
pattern $op(v1:$tp1,v2:$tp2) :$tp1
address CMDvar${func^^}signal
comment "Return V1 $op V2, raise error on out of range second operand";
pattern ${func}_noerror(v1:$tp1,v2:$tp2) :$tp1
address CMDvar${func^^}
comment "Return V1 $op V2, out of range second operand causes NIL value";

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
pattern $op(v1:$tp1,v2:$tp2) :bit
address CMDvar${func^^}
comment "Return V1 $op V2";

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
pattern cmp(v1:$tp1,v2:$tp2) :bte
address CMDvarCMP
comment "Return -1/0/1 if V1 </==/> V2";

EOF
    done
done
echo

# for tp in $fixtypes; do
#     cat <<EOF
# pattern between(b:$tp,lo:$tp,hi:$tp) :bit
# address CMDvarBETWEEN
# comment "B between LO and HI inclusive, nil border is (minus) infinity";

# EOF
# done

for tp1 in void $alltypes; do
    for tp2 in void $alltypes; do
	case $tp1$tp2 in
	*hge*) ;;
	*) continue;;
	esac
	cat <<EOF
pattern $tp1(v:$tp2) :$tp1
address CMDvarCONVERT
comment "Cast VALUE to $tp1";

EOF
    done
    echo
done

cat <<EOF
module aggr;

EOF

for func in sum:sum prod:product; do
    for tp1 in 1:bte 2:sht 4:int 8:wrd 8:lng 9:hge; do
	for tp2 in 1:bte 2:sht 4:int 4:wrd 8:lng 9:hge 9:dbl; do
	    case $tp1$tp2 in
	    *hge*) ;;
	    *) continue;;
	    esac
	    if [ ${tp1%:*} -le ${tp2%:*} -o ${tp1#*:} = ${tp2#*:} ]; then
		cat <<EOF
pattern ${func%:*}(b:bat[:${tp1#*:}]) :${tp2#*:}
address CMDBAT${func%:*}
comment "Calculate aggregate ${func#*:} of B.";
pattern ${func%:*}(b:bat[:${tp1#*:}],nil_if_empty:bit) :${tp2#*:}
address CMDBAT${func%:*}
comment "Calculate aggregate ${func#*:} of B.";
pattern ${func%:*}(b:bat[:${tp1#*:}],s:bat[:oid]) :${tp2#*:}
address CMDBAT${func%:*}
comment "Calculate aggregate ${func#*:} of B with candidate list.";
pattern ${func%:*}(b:bat[:${tp1#*:}],s:bat[:oid],nil_if_empty:bit) :${tp2#*:}
address CMDBAT${func%:*}
comment "Calculate aggregate ${func#*:} of B with candidate list.";

EOF
	    fi
	done
    done
done

