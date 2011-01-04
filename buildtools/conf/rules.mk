# -*- makefile -*-

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
# Portions created by CWI are Copyright (C) 1997-July 2008 CWI.
# Copyright August 2008-2011 MonetDB B.V.
# All Rights Reserved.

CP=cp
MV=mv
HIDE=1

# in the next few rules, make sure that "$(CONFIG_H)" is included
# first, also with [f]lex- and bison-generated files.  This is crucial
# to prevent inconsistent (re-)definitions of macros.
%.yy.c: %.l
	$(LEX) $(LFLAGS) $<
	if [ -f lex.$*.c ]; then $(MV) lex.$*.c $*.yy.c ; fi
	if [ -f lex.yy.c ]; then $(MV) lex.yy.c $*.yy.c ; fi
	if [ -f lex.$(PARSERNAME).c ]; then $(MV) lex.$(PARSERNAME).c $*.yy.c ; fi
	$(MV) $*.yy.c $*.yy.c.tmp
	echo '#include <'"$(CONFIG_H)"'>' > $*.yy.c
	grep -v '^#include.*[<"]'"$(CONFIG_H)"'[">]' $*.yy.c.tmp >> $*.yy.c
	$(RM) $*.yy.c.tmp

%.yy.cc: %.ll
	$(LEX) $(LFLAGS) $<
	if [ -f lex.$*.cc ]; then $(MV) lex.$*.cc $*.yy.c ; fi
	if [ -f lex.yy.c ]; then $(MV) lex.yy.c $*.yy.cc ; fi
	$(MV) $*.yy.cc $*.yy.cc.tmp
	echo '#include <'"$(CONFIG_H)"'>' > $*.yy.cc
	grep -v '^#include.*[<"]'"$(CONFIG_H)"'[">]' $*.yy.cc.tmp >> $*.yy.cc
	$(RM) $*.yy.cc.tmp

%.tab.c: %.y
	$(LOCKFILE) waiting
	$(YACC) $(YFLAGS) $< || { $(RM) waiting ; exit 1 ; }
	if [ -f y.tab.c ]; then $(MV) y.tab.c $*.tab.c ; fi
	$(MV) $*.tab.c $*.tab.c.tmp
	echo '#include <'"$(CONFIG_H)"'>' > $*.tab.c
	grep -v '^#include.*[<"]'"$(CONFIG_H)"'[">]' $*.tab.c.tmp >> $*.tab.c
	$(RM) $*.tab.c.tmp
	[ ! -f y.tab.h ] || $(RM) y.tab.h
	$(RM) waiting

%.tab.cc: %.yy
	$(LOCKFILE) waiting
	$(YACC) $(YFLAGS) $< || { $(RM) waiting ; exit 1 ; }
	if [ -f y.tab.c ]; then $(MV) y.tab.c $*.tab.cc ; fi
	$(MV) $*.tab.cc $*.tab.cc.tmp
	echo '#include <'"$(CONFIG_H)"'>' > $*.tab.cc
	grep -v '^#include.*[<"]'"$(CONFIG_H)"'[">]' $*.tab.cc.tmp >> $*.tab.cc
	$(RM) $*.tab.cc.tmp
	[ ! -f y.tab.h ] || $(RM) y.tab.h
	$(RM) waiting

%.tab.h: %.yy
	$(LOCKFILE) waiting
	$(YACC) $(YFLAGS) $< || { $(RM) waiting ; exit 1 ; } 
	if [ -f y.tab.h ]; then $(MV) y.tab.h $*.tab.h ; fi
	[ ! -f y.tab.c ] || $(RM) y.tab.c
	[ ! -f y.tab.cc ] || $(RM) y.tab.cc
	$(RM) waiting

%.tab.h: %.y
	$(LOCKFILE) waiting
	$(YACC) $(YFLAGS) $< || { $(RM) waiting ; exit 1 ; }
	if [ -f y.tab.h ]; then $(MV) y.tab.h $*.tab.h ; fi
	[ ! -f y.tab.c ] || $(RM) y.tab.c
	$(RM) waiting

%.def: %.syms
	case `(uname -s) 2> /dev/null || echo unknown` in CYGWIN*) cat $<;; *) grep -v DllMain $<;; esac > $@

ifdef NEED_MX
# NEED_MX stands for having some not-so-generally-available tools at
# your disposal: Mx, mel, swig; the first two are built when compiling
# buildtools

%.h: %.mx
	$(MX) $(MXFLAGS) -l -x h $<

%.c: %.mx
	$(MX) $(MXFLAGS) -x c $<

%.y: %.mx
	$(MX) $(MXFLAGS) -x y $< 

%.l: %.mx
	$(MX) $(MXFLAGS) -x l $< 

%.cc: %.mx
	$(MX) $(MXFLAGS) -x C $<

%.yy: %.mx
	$(MX) $(MXFLAGS) -x Y $< 

%.ll: %.mx
	$(MX) $(MXFLAGS) -x L $<

%.m: %.mx
	$(MX) $(MXFLAGS) -x m $<

%.mil: %.m %.tmpmil $(MEL)
	$(MEL) -c $(CONFIG_H) $(INCLUDES) -mil $*.m > $@
	cat $*.tmpmil >> $@

%.tmpmil: %.mx
	$(MX) $(MXFLAGS) -l -x mil $<
	$(MV) $*.mil $*.tmpmil

%.mil: %.m $(MEL) 
	$(MEL) -c $(CONFIG_H) $(INCLUDES) -mil $*.m > $@

%.mil: %.mx
	$(MX) $(MXFLAGS) -x mil $<

%.mal: %.mx
	$(MX) $(MXFLAGS) -x mal $<

%.sql: %.mx
	$(MX) $(MXFLAGS) -x sql $<

%: %.mx 
	$(MX) $(MXFLAGS) -x sh $<
	chmod a+x $@

%.proto.h: %.m $(MEL)
	$(MEL) -c $(CONFIG_H) $(INCLUDES) -proto $< > $@

%.glue.c: %.m $(MEL)
	$(MEL) -c $(CONFIG_H) $(INCLUDES) -glue $< > $@

# The following rules generate two files using swig, the .xx.c and the
# .xx file.  There may be a race condition here when using a parallel
# make.  We try to alleviate the problem by sending the .xx.c output
# to a dummy file in the second rule.
# We also make sure that "$(CONFIG_H)" is included first, also with
# swig-generated files.  This is crucial to prevent inconsistent
# (re-)definitions of macros.
%.tcl.c: %.tcl.i
	$(SWIG) -tcl $(SWIGFLAGS) -outdir . -o $@ $<
	$(MV) $@ $@.tmp
	echo '#include <'"$(CONFIG_H)"'>' > $@
	grep -v '^#include.*[<"]'"$(CONFIG_H)"'[">]' $@.tmp >> $@
	$(RM) $@.tmp

%.tcl: %.tcl.i
	$(SWIG) -tcl $(SWIGFLAGS) -outdir . -o dummy.c $<
	$(RM) dummy.c

%.php.c: %.php.i
	$(SWIG) -php $(SWIGFLAGS) -outdir . -o $@ $<
	$(MV) $@ $@.tmp
	echo '#include <'"$(CONFIG_H)"'>' > $@
	grep -v '^#include.*[<"]'"$(CONFIG_H)"'[">]' $@.tmp >> $@
	$(RM) $@.tmp

%.php: %.php.i
	$(SWIG) -php $(SWIGFLAGS) -outdir . -o dummy.c $<
	$(RM) dummy.c

%.py.c: %.py.i
	$(SWIG) -python $(SWIGFLAGS) -outdir . -o $@ $<
	$(MV) $@ $@.tmp
	echo '#include <'"$(CONFIG_H)"'>' > $@
	grep -v '^#include.*[<"]'"$(CONFIG_H)"'[">]' $@.tmp >> $@
	$(RM) $@.tmp

%.py: %.py.i
	$(SWIG) -python $(SWIGFLAGS) -outdir . -o dummy.c $<
	$(RM) dummy.c

%.pm.c: %.pm.i
	$(SWIG) -perl5 $(SWIGFLAGS) -outdir . -o $@ $<
	$(MV) $@ $@.tmp
	echo '#include <'"$(CONFIG_H)"'>' > $@
	grep -v '^#include.*[<"]'"$(CONFIG_H)"'[">]' $@.tmp >> $@
	$(RM) $@.tmp

%.pm: %.pm.i
	$(SWIG) -perl5 $(SWIGFLAGS) -outdir . -o dummy.c $<
	$(RM) dummy.c

%.ruby.c: %.ruby.i
	$(SWIG) -ruby $(SWIGFLAGS) -outdir . -o $@ $<
	$(MV) $@ $@.tmp
	echo '#include <'"$(CONFIG_H)"'>' > $@
	grep -v '^#include.*[<"]'"$(CONFIG_H)"'[">]' $@.tmp >> $@
	$(RM) $@.tmp

%.ruby: %.ruby.i
	$(SWIG) -ruby $(SWIGFLAGS) -outdir . -o dummy.c $<
	$(RM) dummy.c

%.tex: %.mx
	$(MX) -1 -H$(HIDE) -t $< 

%.bdy.tex: %.mx
	$(MX) -1 -H$(HIDE) -t -B $<

%.html: %.mx
	$(MX) -1 -H$(HIDE) -w $<

%.bdy.html: %.mx
	$(MX) -1 -H$(HIDE) -w -B $<

endif # NEED_MX

# if the .tex source file is found in srcdir (via VPATH), there might
# be a '.'  in the path, which latex2html doesn't like; hence, we
# temporarly link the .tex file to the local build dir.
%.html: %.tex
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

$(patsubst %.mx,%.lo,$(filter %.mx,$(NO_OPTIMIZE_FILES))): %.lo: %.c
	$(LTCOMPILE) -c -o $@ $(CFLAGS_NO_OPT) $<

$(patsubst %.c,%.o,$(filter %.c,$(NO_OPTIMIZE_FILES))): %.o: %.c
	$(COMPILE) $(CFLAGS_NO_OPT) -c $<

$(patsubst %.c,%.lo,$(filter %.c,$(NO_OPTIMIZE_FILES))): %.lo: %.c
	$(LTCOMPILE) -c -o $@ $(CFLAGS_NO_OPT) $<

SUFFIXES-local: $(BUILT_SOURCES)

distdir: check_dist
check_dist:
	@if [ "$(SWIG)" = "no" ]; then $(ECHO) "Cannot create distribution because one of the necessary programs or libraries is missing"; echo "swig	= $(SWIG)"; exit 1; fi
