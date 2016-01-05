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
command sum(b:bat[:oid,:${tp1#*:}],g:bat[:oid,:oid],e:bat[:oid,:any_1])
		:bat[:oid,:${tp2#*:}]
address AGGRsum3_${tp2#*:}
comment "Grouped tail sum on ${tp1#*:}";

EOF
	    if [ ${tp2#*:} = dbl ]; then
		continue
	    fi
	    cat <<EOF
command subsum(b:bat[:oid,:${tp1#*:}],g:bat[:oid,:oid],e:bat[:oid,:any_1],skip_nils:bit,abort_on_error:bit) :bat[:oid,:${tp2#*:}]
address AGGRsubsum_${tp2#*:}
comment "Grouped sum aggregate";

command subsum(b:bat[:oid,:${tp1#*:}],g:bat[:oid,:oid],e:bat[:oid,:any_1],s:bat[:oid,:oid],skip_nils:bit,abort_on_error:bit) :bat[:oid,:${tp2#*:}]
address AGGRsubsumcand_${tp2#*:}
comment "Grouped sum aggregate with candidates list";

command prod(b:bat[:oid,:${tp1#*:}],g:bat[:oid,:oid],e:bat[:oid,:any_1])
		:bat[:oid,:${tp2#*:}]
address AGGRprod3_${tp2#*:}
comment "Grouped tail product on ${tp1#*:}";

command subprod(b:bat[:oid,:${tp1#*:}],g:bat[:oid,:oid],e:bat[:oid,:any_1],skip_nils:bit,abort_on_error:bit) :bat[:oid,:${tp2#*:}]
address AGGRsubprod_${tp2#*:}
comment "Grouped product aggregate";

command subprod(b:bat[:oid,:${tp1#*:}],g:bat[:oid,:oid],e:bat[:oid,:any_1],s:bat[:oid,:oid],skip_nils:bit,abort_on_error:bit) :bat[:oid,:${tp2#*:}]
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
command sum(b:bat[:oid,:${tp1#*:}],g:bat[:oid,:oid],e:bat[:oid,:any_1])
		:bat[:oid,:${tp2#*:}]
address AGGRsum3_${tp2#*:}
comment "Grouped tail sum on ${tp1#*:}";

command subsum(b:bat[:oid,:${tp1#*:}],g:bat[:oid,:oid],e:bat[:oid,:any_1],skip_nils:bit,abort_on_error:bit) :bat[:oid,:${tp2#*:}]
address AGGRsubsum_${tp2#*:}
comment "Grouped sum aggregate";

command subsum(b:bat[:oid,:${tp1#*:}],g:bat[:oid,:oid],e:bat[:oid,:any_1],s:bat[:oid,:oid],skip_nils:bit,abort_on_error:bit) :bat[:oid,:${tp2#*:}]
address AGGRsubsumcand_${tp2#*:}
comment "Grouped sum aggregate with candidates list";

command prod(b:bat[:oid,:${tp1#*:}],g:bat[:oid,:oid],e:bat[:oid,:any_1])
		:bat[:oid,:${tp2#*:}]
address AGGRprod3_${tp2#*:}
comment "Grouped tail product on ${tp1#*:}";

command subprod(b:bat[:oid,:${tp1#*:}],g:bat[:oid,:oid],e:bat[:oid,:any_1],skip_nils:bit,abort_on_error:bit) :bat[:oid,:${tp2#*:}]
address AGGRsubprod_${tp2#*:}
comment "Grouped product aggregate";

command subprod(b:bat[:oid,:${tp1#*:}],g:bat[:oid,:oid],e:bat[:oid,:any_1],s:bat[:oid,:oid],skip_nils:bit,abort_on_error:bit) :bat[:oid,:${tp2#*:}]
address AGGRsubprodcand_${tp2#*:}
comment "Grouped product aggregate with candidates list";

EOF
	fi
    done
done

# We may have to extend the signatures to all possible {void,oid} combos
for tp in bte sht int wrd lng flt dbl; do
    cat <<EOF
command avg(b:bat[:oid,:${tp}], g:bat[:oid,:oid], e:bat[:oid,:any_1]):bat[:oid,:dbl]
address AGGRavg13_dbl
comment "Grouped tail average on ${tp}";

command avg(b:bat[:oid,:${tp}], g:bat[:oid,:oid], e:bat[:oid,:any_1]) (:bat[:oid,:dbl],:bat[:oid,:wrd])
address AGGRavg23_dbl
comment "Grouped tail average on ${tp}, also returns count";

command subavg(b:bat[:oid,:${tp}],g:bat[:oid,:oid],e:bat[:oid,:any_1],skip_nils:bit,abort_on_error:bit) :bat[:oid,:dbl]
address AGGRsubavg1_dbl
comment "Grouped average aggregate";

command subavg(b:bat[:oid,:${tp}],g:bat[:oid,:oid],e:bat[:oid,:any_1],s:bat[:oid,:oid],skip_nils:bit,abort_on_error:bit) :bat[:oid,:dbl]
address AGGRsubavg1cand_dbl
comment "Grouped average aggregate with candidates list";

command subavg(b:bat[:oid,:${tp}],g:bat[:oid,:oid],e:bat[:oid,:any_1],skip_nils:bit,abort_on_error:bit) (:bat[:oid,:dbl],:bat[:oid,:wrd])
address AGGRsubavg2_dbl
comment "Grouped average aggregate, also returns count";

command subavg(b:bat[:oid,:${tp}],g:bat[:oid,:oid],e:bat[:oid,:any_1],s:bat[:oid,:oid],skip_nils:bit,abort_on_error:bit) (:bat[:oid,:dbl],:bat[:oid,:wrd])
address AGGRsubavg2cand_dbl
comment "Grouped average aggregate with candidates list, also returns count";

EOF
    for func in stdev:'standard deviation' variance:variance; do
	comm=${func#*:}
	func=${func%:*}
	cat <<EOF
command ${func}(b:bat[:oid,:${tp}], g:bat[:oid,:oid], e:bat[:oid,:any_1]):bat[:oid,:dbl]
address AGGR${func}3_dbl
comment "Grouped tail ${comm} (sample/non-biased) on ${tp}";

command sub${func}(b:bat[:oid,:${tp}],g:bat[:oid,:oid],e:bat[:oid,:any_1],skip_nils:bit,abort_on_error:bit) :bat[:oid,:dbl]
address AGGRsub${func}_dbl
comment "Grouped ${comm} (sample/non-biased) aggregate";

command sub${func}(b:bat[:oid,:${tp}],g:bat[:oid,:oid],e:bat[:oid,:any_1],s:bat[:oid,:oid],skip_nils:bit,abort_on_error:bit) :bat[:oid,:dbl]
address AGGRsub${func}cand_dbl
comment "Grouped ${comm} (sample/non-biased) aggregate with candidates list";

command ${func}p(b:bat[:oid,:${tp}], g:bat[:oid,:oid], e:bat[:oid,:any_1]):bat[:oid,:dbl]
address AGGR${func}p3_dbl
comment "Grouped tail ${comm} (population/biased) on ${tp}";

command sub${func}p(b:bat[:oid,:${tp}],g:bat[:oid,:oid],e:bat[:oid,:any_1],skip_nils:bit,abort_on_error:bit) :bat[:oid,:dbl]
address AGGRsub${func}p_dbl
comment "Grouped ${comm} (population/biased) aggregate";

command sub${func}p(b:bat[:oid,:${tp}],g:bat[:oid,:oid],e:bat[:oid,:any_1],s:bat[:oid,:oid],skip_nils:bit,abort_on_error:bit) :bat[:oid,:dbl]
address AGGRsub${func}pcand_dbl
comment "Grouped ${comm} (population/biased) aggregate with candidates list";

EOF
    done
done

cat <<EOF
command min(b:bat[:oid,:any_1],g:bat[:oid,:oid],e:bat[:oid,:any_2]):bat[:oid,:any_1]
address AGGRmin3;

command max(b:bat[:oid,:any_1], g:bat[:oid,:oid], e:bat[:oid,:any_2])
		:bat[:oid,:any_1]
address AGGRmax3;

command submin(b:bat[:oid,:any_1],g:bat[:oid,:oid],e:bat[:oid,:any_2],skip_nils:bit) :bat[:oid,:oid]
address AGGRsubmin
comment "Grouped minimum aggregate";

command submin(b:bat[:oid,:any_1],g:bat[:oid,:oid],e:bat[:oid,:any_2],s:bat[:oid,:oid],skip_nils:bit) :bat[:oid,:oid]
address AGGRsubmincand
comment "Grouped minimum aggregate with candidates list";

command submax(b:bat[:oid,:any_1],g:bat[:oid,:oid],e:bat[:oid,:any_2],skip_nils:bit) :bat[:oid,:oid]
address AGGRsubmax
comment "Grouped maximum aggregate";

command submax(b:bat[:oid,:any_1],g:bat[:oid,:oid],e:bat[:oid,:any_2],s:bat[:oid,:oid],skip_nils:bit) :bat[:oid,:oid]
address AGGRsubmaxcand
comment "Grouped maximum aggregate with candidates list";

command submin(b:bat[:oid,:any_1],g:bat[:oid,:oid],e:bat[:oid,:any_2],skip_nils:bit) :bat[:oid,:any_1]
address AGGRsubmin_val
comment "Grouped minimum aggregate";

command submin(b:bat[:oid,:any_1],g:bat[:oid,:oid],e:bat[:oid,:any_2],s:bat[:oid,:oid],skip_nils:bit) :bat[:oid,:any_1]
address AGGRsubmincand_val
comment "Grouped minimum aggregate with candidates list";

command submax(b:bat[:oid,:any_1],g:bat[:oid,:oid],e:bat[:oid,:any_2],skip_nils:bit) :bat[:oid,:any_1]
address AGGRsubmax_val
comment "Grouped maximum aggregate";

command submax(b:bat[:oid,:any_1],g:bat[:oid,:oid],e:bat[:oid,:any_2],s:bat[:oid,:oid],skip_nils:bit) :bat[:oid,:any_1]
address AGGRsubmaxcand_val
comment "Grouped maximum aggregate with candidates list";

command count(b:bat[:oid,:any_1], g:bat[:oid,:oid], e:bat[:oid,:any_2],
		ignorenils:bit) :bat[:oid,:wrd]
address AGGRcount3;

command count(b:bat[:oid,:any_1], g:bat[:oid,:oid], e:bat[:oid,:any_2])
	:bat[:oid,:wrd]
address AGGRcount3nils
comment "Grouped count";

command count_no_nil(b:bat[:oid,:any_1],g:bat[:oid,:oid],e:bat[:oid,:any_2])
	:bat[:oid,:wrd]
address AGGRcount3nonils;

command subcount(b:bat[:oid,:any_1],g:bat[:oid,:oid],e:bat[:oid,:any_2],skip_nils:bit) :bat[:oid,:wrd]
address AGGRsubcount
comment "Grouped count aggregate";

command subcount(b:bat[:oid,:any_1],g:bat[:oid,:oid],e:bat[:oid,:any_2],s:bat[:oid,:oid],skip_nils:bit) :bat[:oid,:wrd]
address AGGRsubcountcand
comment "Grouped count aggregate with candidates list";


command median(b:bat[:oid,:any_1],g:bat[:oid,:oid],e:bat[:oid,:any_2]) :bat[:oid,:any_1]
address AGGRmedian3
comment "Grouped median aggregate";

function median(b:bat[:oid,:any_1]) :any_1;
	bn := submedian(b, true);
	return algebra.fetch(bn, 0@0);
end aggr.median;

command submedian(b:bat[:oid,:any_1],skip_nils:bit) :bat[:oid,:any_1]
address AGGRmedian
comment "Median aggregate";

command submedian(b:bat[:oid,:any_1],g:bat[:oid,:oid],e:bat[:oid,:any_2],skip_nils:bit) :bat[:oid,:any_1]
address AGGRsubmedian
comment "Grouped median aggregate";

command submedian(b:bat[:oid,:any_1],g:bat[:oid,:oid],e:bat[:oid,:any_2],s:bat[:oid,:oid],skip_nils:bit) :bat[:oid,:any_1]
address AGGRsubmediancand
comment "Grouped median aggregate with candidate list";


command quantile(b:bat[:oid,:any_1],g:bat[:oid,:oid],e:bat[:oid,:any_2],q:bat[:oid,:dbl]) :bat[:oid,:any_1]
address AGGRquantile3
comment "Grouped quantile aggregate";

function quantile(b:bat[:oid,:any_1],q:bat[:oid,:dbl]) :any_1;
	bn := subquantile(b, q, false);
	return algebra.fetch(bn, 0@0);
end aggr.quantile;

command subquantile(b:bat[:oid,:any_1],q:bat[:oid,:dbl],skip_nils:bit) :bat[:oid,:any_1]
address AGGRquantile
comment "Quantile aggregate";

command subquantile(b:bat[:oid,:any_1],q:bat[:oid,:dbl],g:bat[:oid,:oid],e:bat[:oid,:any_2],skip_nils:bit) :bat[:oid,:any_1]
address AGGRsubquantile
comment "Grouped quantile aggregate";

command subquantile(b:bat[:oid,:any_1],q:bat[:oid,:dbl],g:bat[:oid,:oid],e:bat[:oid,:any_2],s:bat[:oid,:oid],skip_nils:bit) :bat[:oid,:any_1]
address AGGRsubquantilecand
comment "Grouped median quantile with candidate list";

EOF
