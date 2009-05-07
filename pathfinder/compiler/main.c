/* -*- c-basic-offset:4; c-indentation-style:"k&r"; indent-tabs-mode:nil -*- */

/**
 * @file
 * Entry point to Pathfinder compiler.
 *
 * Copyright Notice:
 * -----------------
 *
 * The contents of this file are subject to the Pathfinder Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 * http://monetdb.cwi.nl/Legal/PathfinderLicense-1.1.html
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied.  See
 * the License for the specific language governing rights and limitations
 * under the License.
 *
 * The Original Code is the Pathfinder system.
 *
 * The Original Code has initially been developed by the Database &
 * Information Systems Group at the University of Konstanz, Germany and
 * the Database Group at the Technische Universitaet Muenchen, Germany.
 * It is now maintained by the Database Systems Group at the Eberhard
 * Karls Universitaet Tuebingen, Germany.  Portions created by the
 * University of Konstanz, the Technische Universitaet Muenchen, and the
 * Universitaet Tuebingen are Copyright (C) 2000-2005 University of
 * Konstanz, (C) 2005-2008 Technische Universitaet Muenchen, and (C)
 * 2008-2009 Eberhard Karls Universitaet Tuebingen, respectively.  All
 * Rights Reserved.
 *
 * $Id$
 */

/**
 * @mainpage Pathfinder XQuery Compiler Project
 *
 * @section procedure Compilation Procedure
 *
 * @subsection scanning Lexical Scanning
 *
 * Lexical scanning of the input query is done with a
 * <a href="http://www.gnu.org/software/flex/">flex</a> generated
 * scanner. The implementation in parser/XQuery.l follows the appendix of
 * the <a href="http://www.w3.org/TR/2004/WD-xquery-20041029/">October 2004</a>
 * working draft of the <a href="http://www.w3.org">W3 Consortium</a>.
 * The scanner dissects the input query into lexical tokens that serve
 * as an input for the @ref parsing "Parser".
 *
 * @subsection parsing Parsing
 *
 * In the parsing phase, the input query is analyzed according to the
 * XQuery grammar rules. The parser is implemented with
 * <a href="http://www.gnu.org/software/bison/bison.html">bison</a> (see
 * file parser/XQuery.y). The implementation closely follows the grammar
 * described in the
 * <a href="http://www.w3.org/TR/2004/WD-xquery-20041029/">October 2004</a>
 * working draft of the <a href="http://www.w3.org">W3 Consortium</a>.
 *
 * The output of the parser is an abstract syntax tree (aka ``parse tree'')
 * that represents the input query in memory in a form that is very close
 * to the input syntax. Declarations of the abstract syntax tree and
 * helper functions to access and modify the tree are to be found in
 * parser/abssyn.h.
 *
 * @subsection modules XQuery Module Support
 *
 * During parsing, we keep a work list of modules that have been
 * referenced via "import module" (array @c modules in parser.y).
 * In PFparse_modules() (ran after query parsing) we process this work
 * list and load any modules referenced in the query. We might encounter
 * new "import module" statements as we do that, and we simply add them
 * to the work list. Keeping the work list unique avoids endless loops
 * in case of cyclic imports.
 *
 * @subsection abssyn_norm Normalization of the Abstract Syntax Tree
 *
 * Semantically equivalent queries can result in different abstract
 * syntax trees, e.g., when parentheses are introduced, etc. In a
 * normalization phase that follows query parsing, we get rid of these
 * ambiguities and make sure that semantically equivalent queries result
 * in the same parse tree.
 *
 * <b>An example for a normalization rule:</b>
 *
 * Using parentheses, nested @c exprseq nodes can be created in the
 * abstract syntax tree. They are semantically equivalent to right deep
 * chains of @c exprseq nodes. Thus,
 @verbatim
 exprseq (exprseq (a, b), exprseq (c, nil))
 @endverbatim
 * is rewritten to
 @verbatim
 exprseq (a, exprseq (b, exprseq (c, nil)))
 @endverbatim
 *
 * Abstract syntax normalization is done with a BURG based pattern matcher.
 *
 * The BURG input file for the abstract syntax tree normalization is
 * normalize.brg, located in the semantics subdirectory. After processing
 * it with @c BURG, the pattern matcher is generated as C code.
 *
 * @subsection ns Namespace Resolution
 *
 * The compiler then checks that the given query uses XML
 * Namespaces (NS) correctly.  In a qualified name (QName) @c ns:loc,
 * it is mandatory that the NS prefix @c ns is in scope, according to
 * the W3C XQuery and W3C XML Namespace rules.
 *
 * For each such successful NS test, if the NS prefix @c ns has been
 * mapped to the URI @c uri, this phase attaches @c uri to the QName
 * in question.  After this phase has completed, a QName either uses
 * no NS at all or carries the complete @c ns @c |-> @c uri mapping
 * with it.
 *
 * All XQuery NS-relevant prolog declarations, NS scoping rules, and
 * NS declaration attributes of the form @c xmlns="uri" and @c
 * xmlns:ns="uri" (such NS decl attributes are removed after they have
 * been processed) are understood.
 *
 * NS resolution is implemented in semantics/ns.c.  Include
 * semantics/ns.h if you need access to NS specific data structures
 * and operations only, include semantics/nsres.c if you need to
 * access the actual NS resolution function (this should be needed in
 * main.c, only).
 *
 * @subsection varscoping Variable Scope Checking
 *
 * Namespace resolution is followed by a scope-checking phase that
 * checks variable declaration and usages. Scoping rules are verified and
 * to each variable a unique memory block is assigned that contains all
 * required information about this variable. Multiple references to the
 * same variable result in references to the same memory block, following
 * the XQuery scoping rules.
 *
 * Variable scoping is implemented in semantics/varscope.c. In
 * pathfinder/variable.c access and helper functions around variables are
 * implemented.
 *
 * @subsection fun_check Checking for Correct Function Usage
 *
 * Similar to checking the variable scoping rules, correct usage of
 * functions is checked in a next phase. Valid functions are either
 * built-in functions or user-defined functions (defined in the query
 * prolog with ``<code>declare function</code>''). Function usage is
 * checked in PFfun_check() (file semantics/functions.c). We maintain
 * an environment of visible functions (#PFfun_env).  This environment
 * holds function descriptors (#PFfun_t). Before traversing the whole
 * abstract syntax tree, this array is filled with (a) built-in
 * functions and (b) user-defined functions.
 *
 * The built-in XQuery Functions & Operators (XQuery F&O) are registered
 * with the function environment in semantics/xquery_fo.c.
 *
 * User-defined functions are discovered by a tree-walk through the
 * subtree below the <code>query prolog</code> node. The function
 * descriptor contains information like the name of the function, as
 * well as its parameter and return types. When all functions are
 * registered in the array, the whole abstract syntax tree is
 * traversed, searching for #p_fun_ref nodes. For each of these, the
 * function is looked up in the array. If it is found, the semantic
 * information in the current node is replaced by a pointer to the
 * #PFfun_t struct containing the information for the function to call
 * here. Otherwise, an error is reported.
 *
 * @subsection fs XQuery Formal Semantics (Compilation to Core Language)
 *
 * The abstract syntax tree used in the previous processing steps very
 * closely represents the surface syntax of XQuery. For internal
 * query optimization and evaluation steps, however, we use another,
 * more suitable query representation, called <em>Core</em>. Although
 * very similar to the XML Query surface language, Core is missing some
 * ``syntactic sugar'' and makes many implicit semantics (i.e., implicit
 * casting rules) more explicit.
 *
 * Our Core language is very close to the proposal by the W3C, described
 * in the XQuery Formal Semantics document. Core is the data structure
 * on which the subsequent type inference and type checking phases will
 * operate on. Internally, Core is described by a tree structure
 * consisting of #PFcnode_t nodes. Core compilation is implemented
 * with help of a BURG pattern matcher in fs.brg.
 *
 * @subsection core_simplification Core Simplification and Normalization
 *
 * The Formal Semantics compilation sometimes produces unnecessarily
 * complex Core code. The simplification phase in @c simplify.brg
 * simplifies some of these cases and normalizes the Core language tree.
 *
 * @subsection type_inference Type Inference and Check
 *
 * Type inference walks the core expression, inferring a type for each
 * node.  Types are attached to the core tree nodes to facilitate type
 * checking.
 *
 * PFty_check() decorates the core tree with type annotations but
 * lets the tree alone otherwise (almost).
 *
 * @subsection coreopt Core Language Optimization
 *
 * The Core language tree is now labeled with static type information,
 * allowing for various optimizations and rewrites of the tree. This
 * is done in @c coreopt.brg.
 *
 * <b>Example:</b>
 *
 * @verbatim
     typeswitch $v
       case node return e1
       default   return e2
@endverbatim
 *
 * If we can statically decide that the type of <code>$v</code> is
 * @em always a subtype of @c node (e.g. if it is the result of an
 * XPath expression), we may replace the whole expression by expression
 * @c e1. Conversely, we can replace the expression by @c e2, if we
 * know that the type of <code>$v</code> can @em never be a subtype
 * of @c node (the static type of <code>$v</code> and the type @c node
 * are @em disjoint).
 *
 * @subsection core2alg Compiling Core to a Logical Relational Algebra
 *
 * Pathfinder compiles XQuery expressions for execution on a relational
 * backend (MonetDB). The heart of the compiler is thus the compilation
 * from XQuery Core to a language over relational data, i.e., a purely
 * relational algebra. This compilation is done in @c core2alg.brg.
 *
 * The compilation follows the ideas described in the paper presented
 * at the TDM'04 workshop (``Relational Algebra: Mother Tongue---XQuery:
 * Fluent'', <a href='http://www-db.in.tum.de/cms/publications/algebra-mapping.pdf'>http://www-db.in.tum.de/cms/publications/algebra-mapping.pdf</a>).
 * The result of this compilation phase is an algebra expression (in
 * an internal tree representation, as described by @c algebra.c). The
 * algebra is an almost standard relational algebra, with some operations
 * made very explicit (e.g., no higher order functions). Few extensions,
 * such as the staircase join operation, are added for tree-specific
 * operations.
 *
 * @subsection algebra_cse Algebra Common Subexpression Elimination (CSE)
 *
 * The algebra code generated in the previous step contains @em many
 * redundancies. To avoid re-computation of the same expression, the
 * code in algebra_cse.c rewrites the algebra expression @em tree into
 * an equivalent @em graph (DAG), with identical subexpressions only
 * appearing once.
 *
 * @subsection algopt Logical Algebra Optimization
 *
 * The generated algebra code is another, maybe the most important,
 * hook for optimizations. The (twig based) code in @c algopt.mt does
 * some of them (e.g., removal of statically empty expressions).
 *
 * @subsection physalg Compilation into Physical Algebra
 *
 * Order is one of the fundamental concepts in XQuery. It thus turns
 * out that the consideration of order can significantly help to
 * optimize query plans.
 *
 * We thus translate the logical algebra tree into a physical algebra.
 * This physical algebra makes several logical operators more explicit
 * (e.g., different implementations for a single logical operator, or
 * the separation of sorting and numbering for the rownum operator).
 *
 * Compilation into the physical algebra happens in algebra/planner.c.
 * The planner derives costs for physical algebra subexpression trees
 * and keeps track of properties like orderedness. The best plan is
 * derived using a dynamic programming approach: For each subexpression,
 * we keep a set of ``best'' plans, where a plan is a ``best'' plan if
 * there's no other plan that provides the same ordering at a lower cost.
 *
 * The ordering framework is implemented in algebra/ordering.c. Note
 * that we do not (yet) implement the notion of ordering that is
 * mentioned in our technical review, but only a ``simple'' lexical
 * ordering. The planner also considers properties on the logical
 * algebra tree, like the information on constant columns. These
 * properties are maintained via algebra/properties.c.
 *
 * We do not yet have a real cost model for our physical algebra.
 * Instead, each physical algebra operator in algebra/physical.c
 * derives some cost value in a rather naive way. This is okay for
 * the current state of our algebraic optimizer, but we should really
 * implement a real cost model.
 *
 * For details on the algebra stuff, please refer to the
 * @ref compilation page (algebra/algebra.c).
 *
 * @subsection milgenBrief Compilation into a MIL tree
 *
 * MIL is Pathfinder's target language. The code in mil/milgen.brg
 * translates a physical algebra tree into MIL. We do not, however,
 * directly generate a serialized MIl program, but assemble an
 * internal MIL syntax tree first. This MIL tree is serialized to
 * ``real'' MIL afterwards in mil/milprint.c. This serializer
 * follows some grammar that we define on our MIL trees, which at
 * the same time validates the structure of the MIL tree during
 * serialization.
 *
 * @subsection sqlgen Compilation into SQL:99
 *
 * SQL is the standard <b>D</b>ata <b>M</b>anipulation <b>L</b>anguage
 * (DML) and <b>D</b>ata <b>D</b>efinition <b>L</b>anguage (DDL) for nearly
 * all relational Databases. This module extends the abilities of
 * Pathfinder to communicate with all Databases supporting SQL.
 * The SQL generation module is still in progress and should be finished
 * at the end of march 2007.
 *
 * @section commandline Command Line Switches
 *
 * @subsection treeprinting Tree Printing
 *
 * Tree data structures are used in several situations within this project.
 * To make these in-memory structures visible for debugging purposes, we
 * use the help of the tree drawing tool ``dot'' from
 * <a href="http://www.att.com">AT&T's</a>
 * <a href="http://www.research.att.com/sw/tools/graphviz/">graphviz</a>
 * package. The tree structure is printed in a syntax understandable by
 * dot. By piping Pathfinder's output to dot, the tree can be represented
 * as PostScript or whatever. ``dot'' output is selected by the command
 * line option <code>-D</code>. (In the example, `<code>-p</code>'
 * requests to print the <code>a</code>bstract syntax tree in dot notation.)
 @verbatim
 $ echo 'doc("foo.xml")/foo/bar' | ./pf -Das6 | dot -Tps -o foo.ps
 @endverbatim
 * See the dot manpage for more information about dot.
 *
 * @subsection prettyprinting Prettyprinting
 *
 * Output in human readable form is done with the help of a prettyprinting
 * algorithm. The output should be suitable to be viewed on a 80 character
 * wide ASCII terminal. Prettyprinted output can be selected with the
 * command line option <code>-P</code>:
 @verbatim
 $ echo 'doc("foo.xml")/foo/bar' | ./pf -Pcs13
 @endverbatim
 *
 * @subsection what_to_print Data Structures that may be Printed
 *
 * The command line switches <code>-a</code>, <code>-c</code>,
 * <code>-l</code>, and <code>-p</code> request printing of abstract
 * syntax tree (aka. parse tree), Core language tree, logical and
 * physical algebra expression tree, respectively.
 *
 * @subsubsection print_formatting Configuring the dot output
 *
 * Logical and physical algebra trees are annotated with various
 * additional properties.  As displaying all of them would blow
 * the graphical tree output, printing of these annotations can
 * be enabled separately.  For this, add a command line option
 * <tt>-f</tt> (<tt>--format</tt>), followed by a format string.
 * Each character in this format string will trigger the respective
 * annotation to be printed in the dot output (if applicable):
 *
 *  - @c C (capital @c C): Print cost values in physical trees.
 *
 *  - @c c (lower-case @c c): List constant attributes in logical
 *    and physical trees.
 *
 *  - @c o (lower-case @c o): List orderings guaranteed for each
 *    physical tree node.
 *
 * Example:
 *
 * @verbatim
      echo 'for $i in (1,2) return $i + 1' | ./pf -ADps17 -f Co | dot -Tps
@endverbatim
 * will print the physical algebra tree in dot format, annotated with
 * information on cost values and on orderings provided by each
 * sub-expression.
 *
 * @subsection stopping Stopping Processing at a Certain Point
 *
 * For debugging it may be interesting to stop the compiler at a
 * certain point of processing. The compiler will stop at that point
 * and will print out tree structures as requested by other switches.
 *
 * You find all the stop points listed by issuing the command line
 * help (option <code>-H</code>). The following example stops processing
 * after mapping the abstract syntax tree to Core and prints the
 * resulting Core tree:
 * @verbatim
 $ echo 'doc("foo.xml")/foo/bar' | ./pf -Pcs10
@endverbatim
 *
 * @subsection types Static typing for the core language
 *
 * Pathfinder performs static type checking for the generated XQuery
 * core programs.  Passing <code>-t</code> to Pathfinder lets the
 * compiler print type annotations (in braces <code>{ }</code>) along
 * with core program output.
 *
 * @verbatim
 $ echo 'doc("foo.xml")/foo/bar' | ./pf -Pcts13
@endverbatim
 *
 *
 * @section credits Credits
 *
 * This project has been initiated by the
 * <a href="http://www.inf.uni-konstanz.de/dbis/">Database and Information
 * Systems Group</a> at <a href="http://www.uni-konstanz.de/">University
 * of Konstanz, Germany</a>.  It is lead by Torsten Grust
 * (torsten.grust@in.tum.de) and Jens Teubner
 * (jens.teubner@in.tum.de), who have moved to the
 * <a href='http://www-db.in.tum.de/'>Database Systems Group</a> at the
 * <a href='http://www.tum.de'>Technische Universit&auml;t M&uuml;nchen</a>.
 * Several students from U Konstanz have been involved in this
 * project, namely
 *
 *  - Gerlinde Adam
 *  - Natalia Fibich
 *  - Guenther Hagleitner
 *  - Stefan Hohenadel
 *  - Boris Koepf
 *  - Sabine Mayer
 *  - Steffen Mecke
 *  - Martin Oberhofer
 *  - Henning Rode
 *  - Rainer Scharpf
 *  - Peter Uhl
 *  - Lucian Vacariuc
 *  - Michael Wachter
 *
 * The MIL generation back-end has been implemented by Jan Rittinger,
 * with great support from the people at CWI.
 *
 * For our work on XML and XQuery we had support from Maurice van
 * Keulen (keulen@cs.utwente.nl) from the
 * <a href="http://www.cs.utwente.nl/eng/">University of Twente, The
 * Netherlands</a>. Since 2003, Pathfinder is a joint effort also with
 * the <a href='monetdb.cwi.nl'>MonetDB</a> project, the main-memory
 * database system developed by the database group at
 * <a href='http://www.cwi.nl'>CWI Amsterdam</a>.
 *
 * The main distribution and discussion platform for research issues
 * in the Pathfinder project is
 * <a href='http://www.pathfinder-xquery.org/'>http://www.pathfinder-xquery.org/</a>.
 * Software is distributed as the "MonetDB/XQuery" system at
 * <a href='http://www.monetdb-xquery.org/'>http://www.monetdb-xquery.org/</a>.
 */

#include "pf_config.h"
#include "pathfinder.h"

#include <stdlib.h>
#ifdef HAVE_LIBGEN_H
#include <libgen.h>
#endif
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <assert.h>

#ifndef NDEBUG

#ifdef HAVE_STRINGS_H
#include <strings.h>
#endif

#ifndef HAVE_STRCASECMP
#define strcasecmp(a,b) strcmp ((a), (b))
#endif

#endif

#include "compile.h"
#include "array.h"

#if HAVE_GETOPT_H && HAVE_GETOPT_LONG
#include <getopt.h>

/**
 * long (GNU-style) command line options and their abbreviated
 * one-character variants.  Keep this list SORTED in ascending
 * order of one-character option names.
 */
static struct option long_options[] = {
    { "mil",                       no_argument,       NULL, 'A' },
    { "dot",                       no_argument,       NULL, 'D' },
    { "fullhelp",                  no_argument,       NULL, 'H' },
    { "xml-import",                no_argument,       NULL, 'I' },
    { "mil_2004",                  no_argument,       NULL, 'M' },
    { "optimize",                  optional_argument, NULL, 'O' },
    { "text",                      no_argument,       NULL, 'P' },
    { "sql",                       no_argument,       NULL, 'S' },
    { "timing",                    no_argument,       NULL, 'T' },
    { "xml",                       no_argument,       NULL, 'X' },
    { "abstract-syntax-tree",      no_argument,       NULL, 'a' },
/* Wouter: enable-standoff  (with the short-option b (Burkowski ;)
   sorry for the confusion, but I'm afraid all other letters
   have been picked by now... */
    { "enable-standoff",           no_argument,       NULL, 'b' },
    { "core-tree",                 no_argument,       NULL, 'c' },
#ifndef NDEBUG
    { "debug",                     required_argument, NULL, 'd' },
#endif
    { "mil-dead-code-elimination", required_argument, NULL, 'e' },
    { "format",                    required_argument, NULL, 'f' },
    { "help",                      no_argument,       NULL, 'h' },
    { "logical-algebra-plan",      no_argument,       NULL, 'l' },
    { "optimize-algebra",          required_argument, NULL, 'o' },
    { "physical-algebra-plan",     no_argument,       NULL, 'p' },
    { "quiet",                     no_argument,       NULL, 'q' },
    { "stop-after",                required_argument, NULL, 's' },
    { "typing",                    no_argument,       NULL, 't' },
    { NULL,                        no_argument,       NULL, 0 }
};

/**
 * character buffer large enough to hold longest
 * command line option plus some extra formatting space
 */
static char opt_buf[sizeof ("mil-dead-code-elimination") + 10];

static int
cmp_opt (const void *o1, const void *o2)
{
    return ((struct option *)o1)->val - ((struct option *)o2)->val;
}

/**
 * map a one-character command line option to its equivalent
 * long form
 */
static const char
*long_option (char *buf, char *t, char o)
{
    struct option key = { 0, 0, 0, o };
    struct option *l;

    if ((l = (struct option *) bsearch (&key, long_options,
                                        sizeof (long_options) /
                                            sizeof (struct option) - 1,
                                        sizeof (struct option),
                                        cmp_opt))) {
        snprintf (buf, sizeof (opt_buf), t, l->name);
        buf[sizeof (opt_buf) - 1] = 0;
        return buf;
    }
    else
        return "";
}

#else

#ifndef HAVE_GETOPT_H

#include "win32_getopt.c" /* fall back on a standalone impl */

#define getopt win32_getopt
#define getopt_long win32_getopt_long
#define getopt_long_only win32_getopt_long_only
#define _getopt_internal _win32_getopt_internal
#define opterr win32_opterr
#define optind win32_optind
#define optopt win32_optopt
#define optarg win32_optarg
#endif

/* no long option names w/o GNU getopt */
#include <unistd.h>

#define long_option(buf,t,o) ""
#define opt_buf 0

#endif

#include "oops.h"
#include "mem.h"

static char *phases[] = {
    [ 1]  = "right after input parsing",
    [ 2]  = "after loading XQuery modules",
    [ 3]  = "after parse/abstract syntax tree has been normalized",
    [ 4]  = "after namespaces have been checked and resolved",
    [ 5]  = "after option declarations have been extracted from the parse tree",
    [ 6]  = "after guide tree has been build",
    [ 7]  = "after variable scoping has been checked",
    [ 8]  = "after XQuery built-in functions have been loaded",
    [ 9]  = "after XML Schema predefined types have been loaded",
    [10]  = "after valid function usage has been checked",
    [11]  = "after XML Schema document has been imported (if any)",
    [12]  = "after the abstract syntax tree has been mapped to Core",
    [13]  = "after the Core tree has been simplified/normalized",
    [14]  = "after type inference and checking",
    [15]  = "after XQuery Core optimization",
    [16]  = "after the Core tree has been translated to the logical algebra",
    [17]  = "after the logical algebra tree has been rewritten/optimized",
    [18]  = "after the CSE on the logical algebra tree",
    [19]  = "after compiling logical algebra into the physical algebra (or SQL)",
    [20]  = "after introducing recursion boundaries",
    [21]  = "after compiling the physical algebra into MIL code",
    [22]  = "after the MIL program has been serialized"
};

#ifdef WIN32
#include <signal.h>

static RETSIGTYPE
catchabort(int sig)
{
    (void) sig;
    PFoops (OOPS_FATAL, "abort signal caught");
}
#endif

#define MAIN_EXIT(rtrn) \
        fputs (PFerrbuf, stderr);\
        exit (rtrn);

/**
 * Entry point to the Pathfinder compiler,
 * parses the command line (switches), then invokes the compiler driver
 * function PFcompile();
 */
int
main (int argc, char *argv[])
{


    /* Call setjmp() before variables are declared;
     * otherwise, some compilers complain about clobbered variables.
     */
    int rtrn = 0;
    if ((rtrn = setjmp(PFexitPoint)) != 0 ) {
        PFmem_destroy ();
        MAIN_EXIT ( rtrn<0 ? -rtrn : rtrn );
    }

#ifdef WIN32
    /* when an assertion fails, we do not want a pop-up window */
    (void) signal (SIGABRT, catchabort);
    _set_abort_behavior (0, _CALL_REPORTFAULT|_WRITE_ABORT_MSG);

#ifndef NO_STACK_CHECK          /* define to not check for recursion depth */
    /* the default Windows stack is 1 MiB, so give it 7/8 of that
     * above (below) the address of our argument */
    PFmaxstack = (char *)  &argc - (7 << 17);
#endif
#endif

 {
    /**
     * @c basename(argv[0]) is stored here later. The basename() call may
     * modify its argument (according to the man page). To avoid modifying
     * @c argv[0] we make a copy first and store it here.
     */
    char *progname = 0;

    PFstate_t  PFstate;
    PFstate_t* status = &PFstate;
    unsigned int i;
    bool explicit_opt = false;

    /** initialize global state of the compiler */
    PFstate_init (status);
    PFstate.invocation = invoke_cmdline;

    /* URL of query file (if present) */
    char *url = "-";

    PFerrbuf = malloc(OOPS_SIZE);
    PFerrbuf[0] = 0;

    PFmem_init ();
    /*
     * Determine basename(argv[0]) and dirname(argv[0]) on *copies*
     * of argv[0] as both functions may modify their arguments.
     */
#ifdef HAVE_BASENAME
    progname = basename (PFstrdup (argv[0]));
#else
    progname = PFstrdup (argv[0]);
#endif
    /*pathname = dirname (PFstrdup (argv[0]));*/ /* StM: unused! */

#ifndef HAVE_GETOPT_H
    win32_getopt_reset();
#endif
    
    /* getopt-based command line parsing */
    while (true) {
        int c;
#if HAVE_GETOPT_H && HAVE_GETOPT_LONG
        int option_index = 0;
        opterr = 1;
        c = getopt_long (argc, argv, "ADHIMO::PTXabc"
#ifndef NDEBUG
                                     "d:"
#endif
                                     "e:f:Shlo:pqrs:t",
                         long_options, &option_index);
#else
        c = getopt (argc, argv, "ADHIMO::PTXabc"
#ifndef NDEBUG
                                "d:"
#endif
                                "e:f:Shlo:pqrs:t");
#endif

        if (c == -1)
            break;            /* end of command line */
        switch (c) {
            case 'A':
                status->output_format = PFoutput_format_mil;
                break;

            case 'D':
                status->print_dot = true;
                break;

            case 'H':
                printf ("Pathfinder XQuery Compiler "
                        "($Revision$, $Date$)\n");
                printf ("(c) Database Systems Group, ");
                printf (    "Eberhard Karls Universitaet Tuebingen\n\n");
                printf ("Usage: %s [OPTION] [FILE]\n\n", argv[0]);
                printf ("  Reads from standard input if FILE is omitted.\n\n");
                printf ("  -A%s: generate MIL code"
#if ALGEBRA_IS_DEFAULT
                        " (default)"
#endif
                        "\n",
                        long_option (opt_buf, ", --%s", 'A'));
                printf ("  -M%s: generate MIL code (directly from XQuery Core)"
#if MILPRINT_SUMMER_IS_DEFAULT
                        " (default)"
#endif
                        "\n",
                        long_option (opt_buf, ", --%s", 'M'));
                printf ("  -S%s: generate SQL code"
#if SQL_IS_DEFAULT
                        " (default)"
#endif
                        "\n",
                        long_option (opt_buf, ", --%s", 'S'));
                printf ("\n");

                printf ("  -I%s: import logical-algebra-plan from xml file"
                        "\n",
                        long_option (opt_buf, ", --%s", 'I'));
                printf ("\n");


                printf ("  -D%s: print internal tree structure in AT&T dot notation\n",
                        long_option (opt_buf, ", --%s", 'D'));
                printf ("  -P%s: print internal tree structure in "
                        "human-readable notation\n"
                        "              (can be used in combination with"
                        " options -a or -c)\n",
                        long_option (opt_buf, ", --%s", 'P'));
                printf ("  -X%s: print internal algebraic plan "
                        "in XML notation\n             "
                        "(if options -A, -M, and -S are not used "
                        "this option\n              implicitly "
                        "extends options with -S, -l, and -s18)\n\n",
                        long_option (opt_buf, ", --%s", 'X'));
                printf ("  -a%s: enable generation of abstract syntax tree\n",
                        long_option (opt_buf, ", --%s", 'a'));
                printf ("  -c%s: enable generation of internal Core language\n",
                        long_option (opt_buf, ", --%s", 'c'));
                printf ("  -t%s: enable generation of static types in "
                        "internal Core language\n                using {...}"
                        " (can be used in combination with option -c)\n",
                        long_option (opt_buf, ", --%s", 't'));
                printf ("  -l%s: enable generation of logical algebra plan\n",
                        long_option (opt_buf, ", --%s", 'l'));
                printf ("  -p%s: enable generation of physical algebra plan\n",
                        long_option (opt_buf, ", --%s", 'p'));
                printf ("  -f<format>%s: enable generation of algebra "
                        "properties\n",
                        long_option (opt_buf, ", --%s=<format>", 'f'));
                printf ("         +  print all available properties (logical/"
                                     "physical algebra)\n");
                printf ("         <optoptions> selectively choose "
                                     "optimization options that are based\n"
                        "                      on a single property (e.g.,"
                                     " 'O') to print the respective\n"
                        "                      property\n");
                printf ("         c  print cost value (physical algebra)\n");
                printf ("         o  print orderings (physical algebra)\n\n");

                printf ("  -s<phase>%s: stop processing after certain phase:\n",
                        long_option (opt_buf, ", --%s=<phase>", 's'));

                for (i = 1; i < (sizeof (phases) / sizeof (char *)); i++)
                    printf ("        %2u  %s\n", i, phases[i]);
                printf ("\n");

                printf ("  -o<optoptions>%s: optimize algebra according to "
                                            "optimization options:\n",
                        long_option (opt_buf, ", --%s=<optoptions>", 'o'));

                printf ("         E  merge common subexpressions (CSE)\n");
                printf ("         G  apply general optimization (without "
                                            "properties)\n");
                printf ("         O  apply optimization based on constant "
                                            "property\n");
                printf ("         I  apply optimization based on icols "
                                            "property\n");
                printf ("         K  apply optimization based on key "
                                            "property\n");
                printf ("         N  apply optimization based on required "
                                            "node values property\n");
                printf ("         V  apply optimization based on required "
                                            "values property\n");
                printf ("         S  apply optimization based on set "
                                            "property\n");
                printf ("         U  apply optimization based on XML Guide "
                                            "information\n");
                printf ("            (only works for the SQL code "
                                            "generation)\n");
                printf ("         C  apply optimization using multiple "
                                            "properties (complex)\n");
                printf ("            (and icols based optimization will be "
                                            "applied afterwards)\n");
                printf ("         J  push down equi-joins\n");
                printf ("         M  push up cross products (based on multi-"
                                            "value dependencies\n");
                printf ("         T  push up theta-joins (based on multi-"
                                            "value dependencies\n");
                printf ("         R  push up rank operators\n");
                printf ("         }  introduce proxy operators that represent"
                                            "operator groups\n");
                printf ("         {  remove proxy operators\n");
                printf ("         D  apply optimizations tailored "
                                            "for MonetDB/XQuery\n");
                printf ("         Q  apply optimizations tailored "
                                            "for the SQL code generation\n");
                printf ("         [  assign a new set of unique column "
                                            "names\n");
                printf ("         ]  assign bit-encoded column names (dep"
                                            "recated optimization option)\n");
                printf ("         P  infer all properties\n");
                printf ("         _  does nothing (used for structuring "
                                            "the optimization options)\n");
                printf ("            (default for option -A is: '-o %s')\n",
                        status->opt_alg);
                printf ("            (default for option -S is: '-o %s')\n\n",
                        status->opt_sql);

                printf ("  -e[0|1]%s: dead code elimination"
                        " (on the MIL level):\n"
                        "         0  disable dead code elimination\n"
                        "         1  enable dead code elimination (default)\n",
                        long_option (opt_buf, ", --%s=[0|1]", 'e'));
                printf ("  -O[0-3]%s: select optimization level (default=1)\n"
                        "                       (only works in combination "
                        "with option -M)\n",
                        long_option (opt_buf, ", --%s", 'O'));
#ifndef NDEBUG
                printf ("  -d TEST%s: call internall debugging function TEST\n",
                        long_option (opt_buf, ", --%s=TEST", 'd'));
#endif
                printf ("  -b%s: enable StandOff axis steps\n",
                        long_option (opt_buf, ", --%s", 'b'));
                printf ("  -q%s: do not print informational messages "
                        "to log file\n",
                        long_option (opt_buf, ", --%s", 'q'));

                printf ("\n");
                printf ("  -T%s: print elapsed times for compiler phases\n",
                        long_option (opt_buf, ", --%s", 'T'));

                printf ("\n");
                printf ("  -h%s: print short help message\n",
                        long_option (opt_buf, ", --%s", 'h'));
                printf ("  -H%s: print this help message for advanced options\n",
                        long_option (opt_buf, ", --%s", 'H'));
                printf ("\n");
                printf ("Enjoy.\n");
                exit (0);

            case 'I':
                status->import_xml = true;
                status->import_xml_filename = NULL;
                break;

            case 'M':
                status->output_format = PFoutput_format_milprint_summer;
                break;

            case 'O':
                status->optimize = optarg ? atoi(optarg) : 1;
                break;

            case 'P':
                status->print_pretty = true;
                break;

            case 'S':
                status->output_format = PFoutput_format_sql;
                if (!explicit_opt)
                    status->opt_alg = status->opt_sql;
                break;

            case 'T':
                status->timing = true;
                break;

            case 'X':
                if (status->output_format == PFoutput_format_not_specified)
                    status->output_format = PFoutput_format_xml;

                status->print_xml = true;
                break;

            case 'a':
                status->print_parse_tree = true;
                break;

            case 'b':
                status->standoff_axis_steps = true;
                break;

            case 'c':
                status->print_core_tree = true;
                break;

#ifndef NDEBUG
            case 'd':
                if (! strcasecmp (optarg, "list")) {
                    printf ("Available debug functions:\n");
                    printf ("  list      - this list\n");
                    printf ("  subtyping - test subtype relationships for "
                            "a fixed set of types\n");
                    exit (0);
                }
                else if (! strcasecmp (optarg, "subtyping"))
                    status->debug.subtyping = true;
                else
                    PFoops (OOPS_CMDLINEARGS,
                            "unrecognized debug function `%s'", optarg);

                break;
#endif

            case 'e':
                status->dead_code_el = optarg ? atoi(optarg) == 1: true;
                break;

            case 'f':
                if (!status->format)
                    status->format = PFstrdup (optarg);
                else {
                    status->format = PFrealloc (status->format,
                                                strlen (status->format)+1,
                                                strlen (status->format)
                                                    + strlen (optarg) +1);
                    strcat (status->format, optarg);
                }
                break;

            case 'h':
                printf ("Pathfinder XQuery Compiler "
                        "($Revision$, $Date$)\n");
                printf ("(c) Database Systems Group, ");
                printf (    "Eberhard Karls Universitaet Tuebingen\n\n");
                printf ("Usage: %s [OPTION] [FILE]\n\n", argv[0]);
                printf ("  Reads from standard input if FILE is omitted.\n\n");
                printf ("  -A%s: generate MIL code"
#if ALGEBRA_IS_DEFAULT
                        " (default)"
#endif
                        "\n",
                        long_option (opt_buf, ", --%s", 'A'));
                printf ("  -M%s: generate MIL code (directly from XQuery Core)"
#if MILPRINT_SUMMER_IS_DEFAULT
                        " (default)"
#endif
                        "\n",
                        long_option (opt_buf, ", --%s", 'M'));
                printf ("  -S%s: generate SQL code"
#if SQL_IS_DEFAULT
                        " (default)"
#endif
                        "\n",
                        long_option (opt_buf, ", --%s", 'S'));
                printf ("  -X%s: generate XML representation "
                        "of algebraic plan\n",
                        long_option (opt_buf, ", --%s", 'X'));
                printf ("\n");
                printf ("  -T%s: print elapsed times for compiler phases\n",
                        long_option (opt_buf, ", --%s", 'T'));
                printf ("\n");
                printf ("  -h%s: print this help message\n",
                        long_option (opt_buf, ", --%s", 'h'));
                printf ("  -H%s: print help message for advanced options\n",
                        long_option (opt_buf, ", --%s", 'H'));
                printf ("\n");
                printf ("Enjoy.\n");
                exit (0);

            case 'p':
                status->print_pa_tree = true;
                break;

            case 'l':
                status->print_la_tree = true;
                break;

            case 'o':
                explicit_opt = true;
                status->opt_alg = PFstrdup (optarg);
                break;

            case 'q':
                status->quiet = true;
                break;

            case 's':
                status->stop_after = atoi (optarg);
                if (status->stop_after >= (sizeof (phases) / sizeof (*phases)))
                    PFoops (OOPS_CMDLINEARGS,
                            "unrecognized stop point. Try `%s -h'", progname);
                break;

            case 't':
                status->print_types = true;
                break;

            default:
                PFoops (OOPS_CMDLINEARGS, "try `%s -h'", progname);
                break;

        }           /* end of switch */
    }           /* end of while */

    if (status->output_format == PFoutput_format_not_specified)
#if MILPRINT_SUMMER_IS_DEFAULT
        status->output_format = PFoutput_format_milprint_summer;
#endif
#if ALGEBRA_IS_DEFAULT
        status->output_format = PFoutput_format_mil;
#endif
#if SQL_IS_DEFAULT
        status->output_format = PFoutput_format_sql;
#endif
    else if (status->output_format == PFoutput_format_xml) {
        if (!status->stop_after)
            status->stop_after = 18;

        if (!explicit_opt)
            status->opt_alg = status->opt_sql;

        if (!status->print_la_tree && !status->print_pa_tree)
            status->print_la_tree = true;

        status->output_format = PFoutput_format_sql;
    }

    /* should the input explicitely be read from a file (instead of stdin)? */
    if (optind < argc) {

        if(status->import_xml)
        {
            /**
             * If the input is explicitely specified with an filename,
             * we drive the xml-importer with this filename instead with the
             * url-cache-buffer.
             * Reason: If the validation of the input-file against a schema
             * fails, we explicitely get the locations in the file
             * (linenumbers) from the xml-parser. But only, if the parser is
             * driven with an explicit filename. If the parser is driven
             * with an buffer, then we don't get explicit error-positions
             * from the parser in case of validation errors (which makes
             * fixing/locating this validation-errors unneccessary hard)
             */
            status->import_xml_filename = argv[optind];
        }
        else
        {
            url = argv[optind];
        }
    }


    /* Now call the main compiler driver */
    if ( PFcompile(url, stdout, status) < 0 )
        goto failure;

    PFmem_destroy ();

    /* If we are supposed to be quiet
       and did not see any fatal error
       until now we can savely clear
       any warning from the error buffer. */
    if (PFstate.quiet)
        PFerrbuf[0] = 0;

    MAIN_EXIT (EXIT_SUCCESS);

 failure:
    MAIN_EXIT (EXIT_FAILURE);
 }
}

/* vim:set shiftwidth=4 expandtab: */
