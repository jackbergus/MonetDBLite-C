# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0.  If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright 1997 - July 2008 CWI, August 2008 - 2016 MonetDB B.V.

sed '/^$/q' $0			# copy copyright from this file

cat <<EOF
# This file was generated by using the script ${0##*/}.

module aggr;

EOF

integer="bte sht int wrd lng"	# all integer types
numeric="$integer flt dbl"	# all numeric types
fixtypes="bit $numeric oid"
alltypes="$fixtypes str"

for tp1 in 1:bte 2:sht 4:int 8:wrd 8:lng; do
    for tp2 in 8:dbl 1:bte 2:sht 4:int 4:wrd 8:lng; do
	if [ ${tp1%:*} -le ${tp2%:*} -o ${tp1#*:} = ${tp2#*:} ]; then
	    cat <<EOF
command sum(b:bat[:${tp1#*:}],g:bat[:oid],e:bat[:any_1])
		:bat[:${tp2#*:}]
address AGGRsum3_${tp2#*:}
comment "Grouped tail sum on ${tp1#*:}";

EOF
	    if [ ${tp2#*:} = dbl ]; then
		continue
	    fi
	    cat <<EOF
command subsum(b:bat[:${tp1#*:}],g:bat[:oid],e:bat[:any_1],skip_nils:bit,abort_on_error:bit) :bat[:${tp2#*:}]
address AGGRsubsum_${tp2#*:}
comment "Grouped sum aggregate";

command subsum(b:bat[:${tp1#*:}],g:bat[:oid],e:bat[:any_1],s:bat[:oid],skip_nils:bit,abort_on_error:bit) :bat[:${tp2#*:}]
address AGGRsubsumcand_${tp2#*:}
comment "Grouped sum aggregate with candidates list";

command prod(b:bat[:${tp1#*:}],g:bat[:oid],e:bat[:any_1])
		:bat[:${tp2#*:}]
address AGGRprod3_${tp2#*:}
comment "Grouped tail product on ${tp1#*:}";

command subprod(b:bat[:${tp1#*:}],g:bat[:oid],e:bat[:any_1],skip_nils:bit,abort_on_error:bit) :bat[:${tp2#*:}]
address AGGRsubprod_${tp2#*:}
comment "Grouped product aggregate";

command subprod(b:bat[:${tp1#*:}],g:bat[:oid],e:bat[:any_1],s:bat[:oid],skip_nils:bit,abort_on_error:bit) :bat[:${tp2#*:}]
address AGGRsubprodcand_${tp2#*:}
comment "Grouped product aggregate with candidates list";

EOF
	fi
    done
done

for tp1 in 4:flt 8:dbl; do
    for tp2 in 4:flt 8:dbl; do
	if [ ${tp1%:*} -le ${tp2%:*} ]; then
	    cat <<EOF
command sum(b:bat[:${tp1#*:}],g:bat[:oid],e:bat[:any_1])
		:bat[:${tp2#*:}]
address AGGRsum3_${tp2#*:}
comment "Grouped tail sum on ${tp1#*:}";

command subsum(b:bat[:${tp1#*:}],g:bat[:oid],e:bat[:any_1],skip_nils:bit,abort_on_error:bit) :bat[:${tp2#*:}]
address AGGRsubsum_${tp2#*:}
comment "Grouped sum aggregate";

command subsum(b:bat[:${tp1#*:}],g:bat[:oid],e:bat[:any_1],s:bat[:oid],skip_nils:bit,abort_on_error:bit) :bat[:${tp2#*:}]
address AGGRsubsumcand_${tp2#*:}
comment "Grouped sum aggregate with candidates list";

command prod(b:bat[:${tp1#*:}],g:bat[:oid],e:bat[:any_1])
		:bat[:${tp2#*:}]
address AGGRprod3_${tp2#*:}
comment "Grouped tail product on ${tp1#*:}";

command subprod(b:bat[:${tp1#*:}],g:bat[:oid],e:bat[:any_1],skip_nils:bit,abort_on_error:bit) :bat[:${tp2#*:}]
address AGGRsubprod_${tp2#*:}
comment "Grouped product aggregate";

command subprod(b:bat[:${tp1#*:}],g:bat[:oid],e:bat[:any_1],s:bat[:oid],skip_nils:bit,abort_on_error:bit) :bat[:${tp2#*:}]
address AGGRsubprodcand_${tp2#*:}
comment "Grouped product aggregate with candidates list";

EOF
	fi
    done
done

# We may have to extend the signatures to all possible {void,oid} combos
for tp in bte sht int wrd lng flt dbl; do
    cat <<EOF
command avg(b:bat[:${tp}], g:bat[:oid], e:bat[:any_1]):bat[:dbl]
address AGGRavg13_dbl
comment "Grouped tail average on ${tp}";

command avg(b:bat[:${tp}], g:bat[:oid], e:bat[:any_1]) (:bat[:dbl],:bat[:wrd])
address AGGRavg23_dbl
comment "Grouped tail average on ${tp}, also returns count";

command subavg(b:bat[:${tp}],g:bat[:oid],e:bat[:any_1],skip_nils:bit,abort_on_error:bit) :bat[:dbl]
address AGGRsubavg1_dbl
comment "Grouped average aggregate";

command subavg(b:bat[:${tp}],g:bat[:oid],e:bat[:any_1],s:bat[:oid],skip_nils:bit,abort_on_error:bit) :bat[:dbl]
address AGGRsubavg1cand_dbl
comment "Grouped average aggregate with candidates list";

command subavg(b:bat[:${tp}],g:bat[:oid],e:bat[:any_1],skip_nils:bit,abort_on_error:bit) (:bat[:dbl],:bat[:wrd])
address AGGRsubavg2_dbl
comment "Grouped average aggregate, also returns count";

command subavg(b:bat[:${tp}],g:bat[:oid],e:bat[:any_1],s:bat[:oid],skip_nils:bit,abort_on_error:bit) (:bat[:dbl],:bat[:wrd])
address AGGRsubavg2cand_dbl
comment "Grouped average aggregate with candidates list, also returns count";

EOF
    for func in stdev:'standard deviation' variance:variance; do
	comm=${func#*:}
	func=${func%:*}
	cat <<EOF
command ${func}(b:bat[:${tp}], g:bat[:oid], e:bat[:any_1]):bat[:dbl]
address AGGR${func}3_dbl
comment "Grouped tail ${comm} (sample/non-biased) on ${tp}";

command sub${func}(b:bat[:${tp}],g:bat[:oid],e:bat[:any_1],skip_nils:bit,abort_on_error:bit) :bat[:dbl]
address AGGRsub${func}_dbl
comment "Grouped ${comm} (sample/non-biased) aggregate";

command sub${func}(b:bat[:${tp}],g:bat[:oid],e:bat[:any_1],s:bat[:oid],skip_nils:bit,abort_on_error:bit) :bat[:dbl]
address AGGRsub${func}cand_dbl
comment "Grouped ${comm} (sample/non-biased) aggregate with candidates list";

command ${func}p(b:bat[:${tp}], g:bat[:oid], e:bat[:any_1]):bat[:dbl]
address AGGR${func}p3_dbl
comment "Grouped tail ${comm} (population/biased) on ${tp}";

command sub${func}p(b:bat[:${tp}],g:bat[:oid],e:bat[:any_1],skip_nils:bit,abort_on_error:bit) :bat[:dbl]
address AGGRsub${func}p_dbl
comment "Grouped ${comm} (population/biased) aggregate";

command sub${func}p(b:bat[:${tp}],g:bat[:oid],e:bat[:any_1],s:bat[:oid],skip_nils:bit,abort_on_error:bit) :bat[:dbl]
address AGGRsub${func}pcand_dbl
comment "Grouped ${comm} (population/biased) aggregate with candidates list";

EOF
    done
done

cat <<EOF
command min(b:bat[:any_1],g:bat[:oid],e:bat[:any_2]):bat[:any_1]
address AGGRmin3;

command max(b:bat[:any_1], g:bat[:oid], e:bat[:any_2])
		:bat[:any_1]
address AGGRmax3;

command submin(b:bat[:any_1],g:bat[:oid],e:bat[:any_2],skip_nils:bit) :bat[:oid]
address AGGRsubmin
comment "Grouped minimum aggregate";

command submin(b:bat[:any_1],g:bat[:oid],e:bat[:any_2],s:bat[:oid],skip_nils:bit) :bat[:oid]
address AGGRsubmincand
comment "Grouped minimum aggregate with candidates list";

command submax(b:bat[:any_1],g:bat[:oid],e:bat[:any_2],skip_nils:bit) :bat[:oid]
address AGGRsubmax
comment "Grouped maximum aggregate";

command submax(b:bat[:any_1],g:bat[:oid],e:bat[:any_2],s:bat[:oid],skip_nils:bit) :bat[:oid]
address AGGRsubmaxcand
comment "Grouped maximum aggregate with candidates list";

command submin(b:bat[:any_1],g:bat[:oid],e:bat[:any_2],skip_nils:bit) :bat[:any_1]
address AGGRsubmin_val
comment "Grouped minimum aggregate";

command submin(b:bat[:any_1],g:bat[:oid],e:bat[:any_2],s:bat[:oid],skip_nils:bit) :bat[:any_1]
address AGGRsubmincand_val
comment "Grouped minimum aggregate with candidates list";

command submax(b:bat[:any_1],g:bat[:oid],e:bat[:any_2],skip_nils:bit) :bat[:any_1]
address AGGRsubmax_val
comment "Grouped maximum aggregate";

command submax(b:bat[:any_1],g:bat[:oid],e:bat[:any_2],s:bat[:oid],skip_nils:bit) :bat[:any_1]
address AGGRsubmaxcand_val
comment "Grouped maximum aggregate with candidates list";

command count(b:bat[:any_1], g:bat[:oid], e:bat[:any_2],
		ignorenils:bit) :bat[:wrd]
address AGGRcount3;

command count(b:bat[:any_1], g:bat[:oid], e:bat[:any_2])
	:bat[:wrd]
address AGGRcount3nils
comment "Grouped count";

command count_no_nil(b:bat[:any_1],g:bat[:oid],e:bat[:any_2])
	:bat[:wrd]
address AGGRcount3nonils;

command subcount(b:bat[:any_1],g:bat[:oid],e:bat[:any_2],skip_nils:bit) :bat[:wrd]
address AGGRsubcount
comment "Grouped count aggregate";

command subcount(b:bat[:any_1],g:bat[:oid],e:bat[:any_2],s:bat[:oid],skip_nils:bit) :bat[:wrd]
address AGGRsubcountcand
comment "Grouped count aggregate with candidates list";


command median(b:bat[:any_1],g:bat[:oid],e:bat[:any_2]) :bat[:any_1]
address AGGRmedian3
comment "Grouped median aggregate";

function median(b:bat[:any_1]) :any_1;
	bn := submedian(b, true);
	return algebra.fetch(bn, 0@0);
end aggr.median;

command submedian(b:bat[:any_1],skip_nils:bit) :bat[:any_1]
address AGGRmedian
comment "Median aggregate";

command submedian(b:bat[:any_1],g:bat[:oid],e:bat[:any_2],skip_nils:bit) :bat[:any_1]
address AGGRsubmedian
comment "Grouped median aggregate";

command submedian(b:bat[:any_1],g:bat[:oid],e:bat[:any_2],s:bat[:oid],skip_nils:bit) :bat[:any_1]
address AGGRsubmediancand
comment "Grouped median aggregate with candidate list";


command quantile(b:bat[:any_1],g:bat[:oid],e:bat[:any_2],q:bat[:dbl]) :bat[:any_1]
address AGGRquantile3
comment "Grouped quantile aggregate";

function quantile(b:bat[:any_1],q:bat[:dbl]) :any_1;
	bn := subquantile(b, q, true);
	return algebra.fetch(bn, 0@0);
end aggr.quantile;

command subquantile(b:bat[:any_1],q:bat[:dbl],skip_nils:bit) :bat[:any_1]
address AGGRquantile
comment "Quantile aggregate";

command subquantile(b:bat[:any_1],q:bat[:dbl],g:bat[:oid],e:bat[:any_2],skip_nils:bit) :bat[:any_1]
address AGGRsubquantile
comment "Grouped quantile aggregate";

command subquantile(b:bat[:any_1],q:bat[:dbl],g:bat[:oid],e:bat[:any_2],s:bat[:oid],skip_nils:bit) :bat[:any_1]
address AGGRsubquantilecand
comment "Grouped median quantile with candidate list";

EOF
