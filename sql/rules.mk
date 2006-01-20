# The contents of this file are subject to the MonetDB Public License
# Version 1.1 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://monetdb.cwi.nl/Legal/MonetDBLicense-1.1.html
#
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
# License for the specific language governing rights and limitations
# under the License.
#
# The Original Code is the MonetDB Database System.
#
# The Initial Developer of the Original Code is CWI.
# Portions created by CWI are Copyright (C) 1997-2006 CWI.
# All Rights Reserved.

#
# ! this file should be kept identical in                                            !
# ! MonetDB, monet5, sql, xml, acoi, gis, template, playpen, misq, times100, pruning !
#

CP=cp
MV=mv
HIDE=1

%.h: %.mx
	$(MX) $(MXFLAGS) -l -x h $<

%.c: %.mx
	$(MX) $(MXFLAGS) -x c $<

%.y: %.mx
	$(MX) $(MXFLAGS) -x y $< 

%.l: %.mx
	$(MX) $(MXFLAGS) -x l $< 

%.yy.c: %.l
	$(LEX) $(LFLAGS) $<
	if [ -f lex.yy.c ]; then $(MV) lex.yy.c $*.yy.c ; fi
	if [ -f lex.$(PARSERNAME).c ]; then $(MV) lex.$(PARSERNAME).c $*.yy.c ; fi
	# make sure that "$(CONFIG_H)" is included first, also with [f]lex-generated files.
	# This is crucial to prevent inconsistent (re-)definitions of macros.
	$(MV) $*.yy.c $*.yy.c.tmp
	echo '#include <'"$(CONFIG_H)"'>' > $*.yy.c
	grep -v '^#include.*[<"]'"$(CONFIG_H)"'[">]' $*.yy.c.tmp >> $*.yy.c
	$(RM) $*.yy.c.tmp

%.cc: %.mx
	$(MX) $(MXFLAGS) -x C $<

%.yy: %.mx
	$(MX) $(MXFLAGS) -x Y $< 

%.tab.cc: %.yy
	$(LOCKFILE) waiting
	$(YACC) $(YFLAGS) $< || { $(RM) waiting ; exit 1 ; }
	if [ -f y.tab.c ]; then $(MV) y.tab.c $*.tab.cc ; fi
	$(RM) waiting

%.tab.h: %.yy
	$(LOCKFILE) waiting
	$(YACC) $(YFLAGS) $< || { $(RM) waiting ; exit 1 ; } 
	if [ -f y.tab.h ]; then $(MV) y.tab.h $*.tab.h ; fi
	$(RM) waiting

%.tab.c: %.y
	$(LOCKFILE) waiting
	$(YACC) $(YFLAGS) $< || { $(RM) waiting ; exit 1 ; }
	if [ -f y.tab.c ]; then $(MV) y.tab.c $*.tab.c ; fi
	$(RM) waiting

%.tab.h: %.y
	$(LOCKFILE) waiting
	$(YACC) $(YFLAGS) $< || { $(RM) waiting ; exit 1 ; }
	if [ -f y.tab.h ]; then $(MV) y.tab.h $*.tab.h ; fi
	$(RM) waiting

%.ll: %.mx
	$(MX) $(MXFLAGS) -x L $<

%.yy.cc: %.ll
	$(LEX) $(LFLAGS) $<
	if [ -f lex.yy.c ]; then $(MV) lex.yy.c $*.yy.cc ; fi
	# make sure that "$(CONFIG_H)" is included first, also with [f]lex-generated files.
	# This is crucial to prevent inconsistent (re-)definitions of macros.
	$(MV) $*.yy.cc $*.yy.cc.tmp
	echo '#include <'"$(CONFIG_H)"'>' > $*.yy.cc
	grep -v '^#include.*[<"]'"$(CONFIG_H)"'[">]' $*.yy.cc.tmp >> $*.yy.cc
	$(RM) $*.yy.cc.tmp

ifdef NEED_MX

%.m: %.mx
	$(MX) $(MXFLAGS) -x m $<

# Dependency "lib_%.la" prevents the %.mil script of a module from being
# linked to the .libs/ directory in case the C-code of the module failed to
# compile; thus, "make check" can recognize that the module is not
# available, and will properly skip the tests that require it.
%.mil: %.m %.tmpmil $(MEL) lib_%.la
	$(MEL) $(INCLUDES) -mil $*.m > $@
	cat $*.tmpmil >> $@
	test -e .libs || mkdir -p .libs
	test -e .libs/$@ || $(LN_S) ../$@ .libs/$@

%.tmpmil: %.mx
	$(MX) $(MXFLAGS) -l -x mil $<
	$(MV) $*.mil $*.tmpmil

# Dependency "lib_%.la" prevents the %.mil script of a module from being
# linked to the .libs/ directory in case the C-code of the module failed to
# compile; thus, "make check" can recognize that the module is not
# available, and will properly skip the tests that require it.
%.mil: %.m $(MEL) lib_%.la
	$(MEL) $(INCLUDES) -mil $*.m > $@
	test -e .libs || mkdir -p .libs
	test -e .libs/$@ || $(LN_S) ../$@ .libs/$@

%.mil: %.mx
	$(MX) $(MXFLAGS) -x mil $<

%.mal: %.mx
	$(MX) $(MXFLAGS) -x mal $<
	test -e .libs || mkdir -p .libs
	test -e .libs/$@ || $(LN_S) ../$@ .libs/$@

%: %.mx 
	$(MX) $(MXFLAGS) -x sh $<
	chmod a+x $@

%.proto.h: %.m $(MEL)
	$(MEL) $(INCLUDES) -proto $< > $@

%.glue.c: %.m $(MEL)
	$(MEL) $(INCLUDES) -glue $< > $@

else # NEED_MX

# Dependency "lib_%.la" prevents the %.mil script of a module from being
# linked to the .libs/ directory in case the C-code of the module failed to
# compile; thus, "make check" can recognize that the module is not
# available, and will properly skip the tests that require it.
%.mil: lib_%.la
	test -e .libs || mkdir -p .libs
	test -e .libs/$@ || $(LN_S) ../$@ .libs/$@

%.mal:
	test -e .libs || mkdir -p .libs
	test -e .libs/$@ || $(LN_S) ../$@ .libs/$@

endif # NEED_MX

ifdef NEED_MX

# The following rules generate two files using swig, the .xx.c and the
# .xx file.  There may be a race condition here when using a parallel
# make.  We try to alleviate the problem by sending the .xx.c output
# to a dummy file in the second rule.
%.ruby.c: %.ruby.i
	$(SWIG) -ruby $(SWIGFLAGS) -outdir . -o $@ $<

%.ruby: %.ruby.i
	$(SWIG) -ruby $(SWIGFLAGS) -outdir . -o dymmy.c $<

%.tcl.c: %.tcl.i
	$(SWIG) -tcl $(SWIGFLAGS) -outdir . -o $@ $<

%.tcl: %.tcl.i
	$(SWIG) -tcl $(SWIGFLAGS) -outdir . -o dymmy.c $<

%.php.c: %.php.i
	$(SWIG) -php $(SWIGFLAGS) -outdir . -o $@ $<

%.php: %.php.i
	$(SWIG) -php $(SWIGFLAGS) -outdir . -o dymmy.c $<

%.py.c: %.py.i
	$(SWIG) -python $(SWIGFLAGS) -outdir . -o $@ $<

%.py: %.py.i
	$(SWIG) -python $(SWIGFLAGS) -outdir . -o dymmy.c $<

%.pm.c: %.pm.i
	$(SWIG) -perl5 $(SWIGFLAGS) -outdir . -o $@ $<

%.pm: %.pm.i
	$(SWIG) -perl5 $(SWIGFLAGS) -outdir . -o dymmy.c $<

endif # NEED_MX

%.tex: %.mx
	$(MX) -1 -H$(HIDE) -t $< 

%.bdy.tex: %.mx
	$(MX) -1 -H$(HIDE) -t -B $<

%.html: %.mx
	$(MX) -1 -H$(HIDE) -w $<

%.bdy.html: %.mx
	$(MX) -1 -H$(HIDE) -w -B $<

%.html: %.tex
	# if the .tex source file is found in srcdir (via VPATH), there might be a '.'
	# in the path, which latex2html doesn't like; hence, we temporarly link the
	# .tex file to the local build dir.
	if [ "$<" != "$(<F)" ] ; then $(LN_S) $< $(<F) ; fi
	$(LATEX2HTML) -split 0 -no_images -info 0 -no_subdir  $(<F)
	if [ "$<" != "$(<F)" ] ; then $(RM) $(<F) ; fi

%.pdf: %.tex
	$(PDFLATEX) $< 

%.dvi: %.tex
	$(LATEX) $< 

%.ps: %.dvi
	$(DVIPS) $< -o $@

%.eps: %.fig
	$(FIG2DEV) -L$(FIG2DEV_EPS) -e $< > $@

%.eps: %.feps
	$(CP) $< $@

ifdef NEED_MX
$(NO_INLINE_FILES:.mx=.lo): %.lo: %.c
	$(LIBTOOL) --mode=compile $(COMPILE) $(NO_INLINE_CFLAGS) -c $<
endif

$(patsubst %.mx,%.lo,$(filter %.mx,$(NO_OPTIMIZE_FILES))): %.lo: %.c
	$(LTCOMPILE) -c -o $@ -O0 $<

$(patsubst %.c,%.o,$(filter %.c,$(NO_OPTIMIZE_FILES))): %.o: %.c
	$(COMPILE) -O0 -c $<

$(patsubst %.c,%.lo,$(filter %.c,$(NO_OPTIMIZE_FILES))): %.lo: %.c
	$(LTCOMPILE) -c -o $@ -O0 $<

SUFFIXES-local: $(BUILT_SOURCES)

