/* -*- c-basic-offset:4; c-indentation-style:"k&r"; indent-tabs-mode:nil -*- */

/**
 * @file
 *
 * Pathfinder's representation of the built-in XQuery Functions & Operators
 * (XQuery F&O) [1].  We maintain a table of built-in F&O which may be
 * loaded into Pathfinder's function environment via #PFfun_xquery_fo ().
 *
 * References
 *
 * [1] XQuery 1.0 and XPath 2.0 Functions and Operators W3C Working
 *     Draft, 15 November 2002, see http://www.w3.org/TR/xquery-operators/.
 *
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
 * is now maintained by the Database Systems Group at the Technische
 * Universitaet Muenchen, Germany.  Portions created by the University of
 * Konstanz and the Technische Universitaet Muenchen are Copyright (C)
 * 2000-2005 University of Konstanz and (C) 2005-2006 Technische
 * Universitaet Muenchen, respectively.  All Rights Reserved.
 *
 * $Id$
 */

/* always include pathfinder.h first! */
#include "pathfinder.h"

#include <assert.h>

#include "xquery_fo.h"

#include "ns.h"
#include "env.h"
#include "types.h"
#include "functions.h"
#include "builtins.h"

/**
 * maxmimum number of signatures for one function
 */
#define XQUERY_FO_MAX_SIGS 10

/**
 * Load XQuery built-in function signatures into function environment.
 */
void
PFfun_xquery_fo ()
{
    struct {
        PFns_t ns;
        char *loc;
        unsigned int arity;
        unsigned int sig_count;
        PFfun_sig_t sigs[XQUERY_FO_MAX_SIGS];
        struct PFla_pair_t (*alg) (const struct PFla_op_t *,
                                   bool,
                                   struct PFla_pair_t *);
    } xquery_fo[] =
    /**
     * List all XQuery built-in functions here.
     *
     * Be aware that order is significant here:
     *
     *  - The first declaration that is found here that matches an
     *    application's argument types will be chosen
     *    (see semantics/typecheck.brg:overload; This allows us to
     *    give more specific and optimized implementations if we
     *    like.).
     *
     *  - Make sure that the *last* function listed is always the
     *    most generic variant (with a signature as stated in the
     *    W3C drafts). The parameter types of the last function (with
     *    correct number of arguments) will decide the function
     *    conversion (XQuery WD 3.1.5) rule to apply.
     */
    {
      /* fn:data ((atomic|attribute)*) as atomic* */
      /* (F&O 2.4) */
      { .ns = PFns_fn, .loc = "data",
        .arity = 1,
        .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (
                        PFty_choice (
                            PFty_atomic (), PFty_xs_anyAttribute ())) },
            .ret_ty = PFty_star (PFty_atomic ()) } },
        .alg = PFbui_fn_data_attr }
    , /* fn:data ((atomic|text)*) as atomic* */
      /* (F&O 2.4) */
      { .ns = PFns_fn, .loc = "data",
        .arity = 1,
        .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (
                        PFty_choice (
                            PFty_atomic (), PFty_text ())) },
            .ret_ty = PFty_star (PFty_atomic ()) } },
        .alg = PFbui_fn_data_text }
    , /* fn:data ((atomic|processing-instruction)*) as atomic* */
      /* (F&O 2.4) */
      { .ns = PFns_fn, .loc = "data",
        .arity = 1,
        .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (
                        PFty_choice (
                            PFty_atomic (), PFty_pi (NULL))) },
            .ret_ty = PFty_star (PFty_atomic ()) } },
        .alg = PFbui_fn_data_pi }
    , /* fn:data ((atomic|comment)*) as atomic* */
      /* (F&O 2.4) */
      { .ns = PFns_fn, .loc = "data",
        .arity = 1,
        .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (
                        PFty_choice (
                            PFty_atomic (), PFty_text ())) },
            .ret_ty = PFty_star (PFty_atomic ()) } },
        .alg = PFbui_fn_data_comm }
    , /* fn:data ((element)*) as atomic* */
      /* (F&O 2.4) */
      { .ns = PFns_fn, .loc = "data",
        .arity = 1,
        .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (
                        PFty_choice (
                            PFty_atomic (),
                            PFty_choice (
                                PFty_xs_anyElement (),
                                PFty_choice (
                                    PFty_text (),
                                    PFty_doc (PFty_xs_anyType ()))))) },
            .ret_ty = PFty_star (PFty_atomic ()) } },
        .alg = PFbui_fn_data_elem }
    , /* fn:data ((atomic|element|doc|text|attribute)*) as atomic* */
      /* (F&O 2.4) */
      { .ns = PFns_fn, .loc = "data",
        .arity = 1,
        .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (
                        PFty_choice (
                            PFty_atomic (),
                            PFty_choice (
                                PFty_xs_anyElement (),
                                PFty_choice (
                                    PFty_doc (PFty_xs_anyType ()),
                                    PFty_choice (
                                        PFty_text (),
                                        PFty_xs_anyAttribute ()))))) },
            .ret_ty = PFty_star (PFty_atomic ()) } },
        .alg = PFbui_fn_data_elem_attr }
    , /* fn:data (item*) as atomic*    (F&O 2.4) */
      { .ns = PFns_fn, .loc = "data",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_item ()) },
            .ret_ty = PFty_star (PFty_atomic ()) } },
        .alg = PFbui_fn_data }
    , /* fn:number () as double */
      { .ns = PFns_fn, .loc = "number",
        .arity = 0, .sig_count = 1, .sigs = { {
            .ret_ty = PFty_xs_double () } }}
    , /* fn:number (atomic?) as double */
      { .ns = PFns_fn, .loc = "number",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_atomic ()) },
            .ret_ty = PFty_xs_double () } } }
    , /* fn:doc (string?) as document? - FIXME: is type of PFty_doc right? */
      { .ns = PFns_fn, .loc = "doc",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()) },
            .ret_ty = PFty_opt (PFty_doc (PFty_xs_anyNode ())) } },
        .alg = PFbui_fn_doc }
    , /* fn:put (node, string) as none */
      { .ns = PFns_fn, .loc = "put",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_anyNode (), PFty_xs_string () },
            .ret_ty = PFty_stmt () } },
        .alg = PFbui_fn_doc }
    , /* pf:documents () as string* */
      { .ns = PFns_lib, .loc = "documents",
        .arity = 0, .sig_count = 1, .sigs = { {
            .ret_ty = PFty_star( PFty_xs_string ()) } } }
    , /* pf:documents (string*) as string* */
      { .ns = PFns_lib, .loc = "documents",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star( PFty_xs_string ()) },
            .ret_ty = PFty_star( PFty_xs_string ()) } } }
    , /* pf:collections () as string* */
      { .ns = PFns_lib, .loc = "collections",
        .arity = 0, .sig_count = 1, .sigs = { {
            .ret_ty = PFty_star( PFty_xs_string ()) } } }
    , /* fn:collection () as node* */
      { .ns = PFns_fn, .loc = "collection",
        .arity = 0, .sig_count = 1, .sigs = { {
            .ret_ty = PFty_star( PFty_xs_anyNode ()) } } }
    , /* fn:collection (string*) as node* */
      { .ns = PFns_fn, .loc = "collection",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_string () },
            .ret_ty = PFty_star( PFty_xs_anyNode ()) } } }
    , /* pf:nid (xs:element) as string */
      { .ns = PFns_lib, .loc = "nid",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_anyElement () },
            .ret_ty = PFty_xs_string () } } }
    , /* fn:id (string*) as element* */
      { .ns = PFns_fn, .loc = "id",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_xs_string ()) },
            .ret_ty = PFty_star (PFty_xs_anyElement ()) } } }
    , /* fn:id (string*, node) as element* */
      { .ns = PFns_fn, .loc = "id",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_xs_string ()),
                                PFty_node () },
            .ret_ty = PFty_star (PFty_xs_anyElement ()) } } }
    , /* fn:idref (string*) as element* */
      { .ns = PFns_fn, .loc = "idref",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_xs_string ()) },
            .ret_ty = PFty_star (PFty_xs_anyElement ()) } } }
    , /* fn:idref (string*, node) as element* */
      { .ns = PFns_fn, .loc = "idref",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_xs_string ()),
                                PFty_node () },
            .ret_ty = PFty_star (PFty_xs_anyElement ()) } } }
    , /* pf:distinct-doc-order-or-atomic-sequence (item*) as item* */
      { .ns = PFns_pf, .loc = "distinct-doc-order-or-atomic-sequence",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_item ()) },
            .ret_ty = PFty_star (PFty_item ()) } } }
    , /* pf:distinct-doc-order (node *) as node* */
      { .ns = PFns_pf, .loc = "distinct-doc-order",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_node ()) },
            .ret_ty = PFty_star (PFty_node ()) } },
        .alg = PFbui_pf_distinct_doc_order }
    , /* fn:exactly-one (item *) as item */
         /* Note that typecheck.brg implements a specific typing rule */
         /* replacing the occurrence indicator! */
      { .ns = PFns_fn, .loc = "exactly-one",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_item ()) },
            .ret_ty = PFty_item () } },
        .alg = PFbui_fn_exactly_one }
    , /* fn:zero-or-one (item *) as item? */
         /* Note that typecheck.brg implements a specific typing rule */
         /* replacing the occurrence indicator! */
      { .ns = PFns_fn, .loc = "zero-or-one",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_item ()) },
            .ret_ty = PFty_opt (PFty_item ()) } },
        .alg = PFbui_fn_zero_or_one }
    , /* fn:unordered (item *) as item */
      { .ns = PFns_fn, .loc = "unordered",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_item ()) },
            .ret_ty = PFty_opt (PFty_item ()) } },
        .alg = PFbui_fn_unordered }

    , /* fn:root () as node */
      { .ns = PFns_fn, .loc = "root",
        .arity = 0, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_none () },
            .ret_ty = PFty_node() } } }
    , /* fn:root (node?) as node? */
      { .ns = PFns_fn, .loc = "root",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_node ()) },
            .ret_ty = PFty_opt (PFty_node()) } } }
    , /* fn:position () as integer */
      { .ns = PFns_fn, .loc = "position",
        .arity = 0,  .sig_count = 1, .sigs = { {
            .ret_ty = PFty_xs_integer () } } }
    , /* fn:last () as integer */
      { .ns = PFns_fn, .loc = "last",
        .arity = 0, .sig_count = 1, .sigs = { {
            .ret_ty = PFty_xs_integer () } } }
    , /* fn:empty (item*) as boolean  (F&O 14.2.5) */
      { .ns = PFns_fn, .loc = "empty",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_item ()) },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_fn_empty }
    , /* fn:exists (item*) as boolean */
      { .ns = PFns_fn, .loc = "exists",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_item ()) },
            .ret_ty = PFty_xs_boolean () } } }
    , /* fn:not (boolean) as boolean  (F&O 7.3.1) */
      { .ns = PFns_fn, .loc = "not",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_boolean () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_fn_not_bln }
    , /* fn:not (item*) as boolean  (F&O 7.3.1) */
      /* Note: After type checking, fn:not(item*) should actually no      */
      /*       longer appear in Core trees.  The implicit semantics for   */
      /*       fn:not() in fs.brg wraps the argument of fn:not() into an  */
      /*       fn:boolean() call.  We need the signature fn:not(item*)    */
      /*       here nevertheless to determine the correct expected type   */
      /*       for fn:not() in fs.brg.                                    */
      /*       (see Rule FuncArgList: args(Expr, FuncArgList)             */
      { .ns = PFns_fn, .loc = "not",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_item ()) },
            .ret_ty = PFty_xs_boolean () } },
        .alg = NULL }
    , /* fn:true () as boolean */
      { .ns = PFns_fn, .loc = "true",
        .arity = 0, .sig_count = 1, .sigs = { {
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_fn_true }
    , /* fn:false () as boolean */
      { .ns = PFns_fn, .loc = "false",
        .arity = 0, .sig_count = 1, .sigs = { {
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_fn_false }
    , /* fn:boolean (boolean) as boolean */
      { .ns = PFns_fn, .loc = "boolean",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_boolean () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_fn_boolean_bln }
    , /* fn:boolean (boolean?) as boolean */
      { .ns = PFns_fn, .loc = "boolean",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_boolean ()) },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_fn_boolean_optbln }
    , /* fn:boolean ( */
      /*      node*|boolean|string|integer|decimal|double) as boolean */
      { .ns = PFns_fn, .loc = "boolean",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_choice (
                                    PFty_star (PFty_node ()),
                                    PFty_choice (
                                        PFty_xs_boolean (),
                                        PFty_choice (
                                            PFty_xs_string (),
                                            PFty_choice (
                                                PFty_xs_integer (),
                                                PFty_choice (
                                                    PFty_xs_decimal (),
                                                    PFty_xs_double ()))))) },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_fn_boolean_item }
    , /* fn:contains (string, string) as boolean */
      { .ns = PFns_fn, .loc = "contains",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_string (),
                                PFty_xs_string () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_fn_contains }
    , /* fn:contains (string?, string) as boolean */
      { .ns = PFns_fn, .loc = "contains",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()),
                                PFty_xs_string () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_fn_contains_opt }
    , /* fn:contains (string?, string?) as boolean */
      { .ns = PFns_fn, .loc = "contains",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()),
                                PFty_opt (PFty_xs_string ()) },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_fn_contains_opt_opt }
    , /* fn:error () as none */
      { .ns = PFns_fn, .loc = "error",
        .arity = 0,  .sig_count = 1, .sigs = { {
            .ret_ty = PFty_none () } } }
    , /* fn:error (string?) as none */
      { .ns = PFns_fn, .loc = "error",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()) },
            .ret_ty = PFty_none () } } }
    , /* fn:error (string?, string) as none */
      { .ns = PFns_fn, .loc = "error",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()),
                                PFty_xs_string () },
            .ret_ty = PFty_none () } } }
    , /* op:or (boolean, boolean) as boolean */
      { .ns = PFns_op, .loc = "or",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_boolean (), PFty_xs_boolean () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_or_bln }
    , /* op:and (boolean, boolean) as boolean */
      { .ns = PFns_op, .loc = "and",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_boolean (), PFty_xs_boolean () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_and_bln }
    , /* op:eq (integer, integer) as boolean */
      { .ns = PFns_op, .loc = "eq",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_integer (),
                                PFty_xs_integer () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_eq_int }
    , /* op:eq (integer?, integer?) as boolean? */
      { .ns = PFns_op, .loc = "eq",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_integer ()),
                                PFty_opt (PFty_xs_integer ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_eq_int }
    , /* op:eq (decimal, decimal) as boolean */
      { .ns = PFns_op, .loc = "eq",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_decimal (),
                                PFty_xs_decimal () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_eq_dec }
    , /* op:eq (decimal?, decimal?) as boolean? */
      { .ns = PFns_op, .loc = "eq",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_decimal ()),
                                PFty_opt (PFty_xs_decimal ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_eq_dec }
    , /* op:eq (double, double) as boolean */
      { .ns = PFns_op, .loc = "eq",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_double (),
                                PFty_xs_double () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_eq_dbl }
    , /* op:eq (double?, double?) as boolean? */
      { .ns = PFns_op, .loc = "eq",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_double ()),
                                PFty_opt (PFty_xs_double ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_eq_dbl }
    , /* op:eq (boolean, boolean) as boolean */
      { .ns = PFns_op, .loc = "eq",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_boolean (),
                                PFty_xs_boolean () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_eq_bln }
    , /* op:eq (boolean?, boolean?) as boolean? */
      { .ns = PFns_op, .loc = "eq",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_boolean ()),
                                PFty_opt (PFty_xs_boolean ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_eq_bln }
    , /* op:eq (string, string) as boolean */
      { .ns = PFns_op, .loc = "eq",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_string (),
                                PFty_xs_string () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_eq_str }
    , /* op:eq (string?, string?) as boolean? */
      { .ns = PFns_op, .loc = "eq",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()),
                                PFty_opt (PFty_xs_string ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_eq_str }

    , /* op:ne (integer, integer) as boolean */
      { .ns = PFns_op, .loc = "ne",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_integer (),
                                PFty_xs_integer () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_ne_int }
    , /* op:ne (integer?, integer?) as boolean? */
      { .ns = PFns_op, .loc = "ne",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_integer ()),
                                PFty_opt (PFty_xs_integer ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_ne_int }
    , /* op:ne (decimal, decimal) as boolean */
      { .ns = PFns_op, .loc = "ne",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_decimal (),
                                PFty_xs_decimal () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_ne_dec }
    , /* op:ne (decimal?, decimal?) as boolean? */
      { .ns = PFns_op, .loc = "ne",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_decimal ()),
                                PFty_opt (PFty_xs_decimal ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_ne_dec }
    , /* op:ne (double, double) as boolean */
      { .ns = PFns_op, .loc = "ne",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_double (),
                                PFty_xs_double () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_ne_dbl }
    , /* op:ne (double?, double?) as boolean? */
      { .ns = PFns_op, .loc = "ne",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_double ()),
                                PFty_opt (PFty_xs_double ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_ne_dbl }
    , /* op:ne (boolean, boolean) as boolean */
      { .ns = PFns_op, .loc = "ne",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_boolean (),
                                PFty_xs_boolean () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_ne_bln }
    , /* op:ne (boolean?, boolean?) as boolean? */
      { .ns = PFns_op, .loc = "ne",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_boolean ()),
                                PFty_opt (PFty_xs_boolean ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_ne_bln }
    , /* op:ne (string, string) as boolean */
      { .ns = PFns_op, .loc = "ne",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_string (),
                                PFty_xs_string () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_ne_str }
    , /* op:ne (string?, string?) as boolean? */
      { .ns = PFns_op, .loc = "ne",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()),
                                PFty_opt (PFty_xs_string ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_ne_str }

    , /* op:lt (integer, integer) as boolean */
      { .ns = PFns_op, .loc = "lt",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_integer (),
                                PFty_xs_integer () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_lt_int }
    , /* op:lt (integer?, integer?) as boolean? */
      { .ns = PFns_op, .loc = "lt",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_integer ()),
                                PFty_opt (PFty_xs_integer ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_lt_int }
    , /* op:lt (decimal, decimal) as boolean */
      { .ns = PFns_op, .loc = "lt",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_decimal (),
                                PFty_xs_decimal () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_lt_dec }
    , /* op:lt (decimal?, decimal?) as boolean? */
      { .ns = PFns_op, .loc = "lt",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_decimal ()),
                                PFty_opt (PFty_xs_decimal ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_lt_dec }
    , /* op:lt (double, double) as boolean */
      { .ns = PFns_op, .loc = "lt",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_double (),
                                PFty_xs_double () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_lt_dbl }
    , /* op:lt (double?, double?) as boolean? */
      { .ns = PFns_op, .loc = "lt",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_double ()),
                                PFty_opt (PFty_xs_double ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_lt_dbl }
    , /* op:lt (boolean, boolean) as boolean */
      { .ns = PFns_op, .loc = "lt",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_boolean (),
                                PFty_xs_boolean () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_lt_bln }
    , /* op:lt (boolean?, boolean?) as boolean? */
      { .ns = PFns_op, .loc = "lt",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_boolean ()),
                                PFty_opt (PFty_xs_boolean ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_lt_bln }
    , /* op:lt (string, string) as boolean */
      { .ns = PFns_op, .loc = "lt",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_string (),
                                PFty_xs_string () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_lt_str }
    , /* op:lt (string?, string?) as boolean? */
      { .ns = PFns_op, .loc = "lt",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()),
                                PFty_opt (PFty_xs_string ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_lt_str }

    , /* op:le (integer, integer) as boolean */
      { .ns = PFns_op, .loc = "le",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_integer (),
                                PFty_xs_integer () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_le_int }
    , /* op:le (integer?, integer?) as boolean? */
      { .ns = PFns_op, .loc = "le",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_integer ()),
                                PFty_opt (PFty_xs_integer ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_le_int }
    , /* op:le (decimal, decimal) as boolean */
      { .ns = PFns_op, .loc = "le",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_decimal (),
                                PFty_xs_decimal () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_le_dec }
    , /* op:le (decimal?, decimal?) as boolean? */
      { .ns = PFns_op, .loc = "le",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_decimal ()),
                                PFty_opt (PFty_xs_decimal ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_le_dec }
    , /* op:le (double, double) as boolean */
      { .ns = PFns_op, .loc = "le",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_double (),
                                PFty_xs_double () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_le_dbl }
    , /* op:le (double?, double?) as boolean? */
      { .ns = PFns_op, .loc = "le",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_double ()),
                                PFty_opt (PFty_xs_double ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_le_dbl }
    , /* op:le (boolean, boolean) as boolean */
      { .ns = PFns_op, .loc = "le",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_boolean (),
                                PFty_xs_boolean () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_le_bln }
    , /* op:le (boolean?, boolean?) as boolean? */
      { .ns = PFns_op, .loc = "le",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_boolean ()),
                                PFty_opt (PFty_xs_boolean ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_le_bln }
    , /* op:le (string, string) as boolean */
      { .ns = PFns_op, .loc = "le",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_string (),
                                PFty_xs_string () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_le_str }
    , /* op:le (string?, string?) as boolean? */
      { .ns = PFns_op, .loc = "le",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()),
                                PFty_opt (PFty_xs_string ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_le_str }

    , /* op:gt (integer, integer) as boolean */
      { .ns = PFns_op, .loc = "gt",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_integer (),
                                PFty_xs_integer () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_gt_int }
    , /* op:gt (integer?, integer?) as boolean? */
      { .ns = PFns_op, .loc = "gt",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_integer ()),
                                PFty_opt (PFty_xs_integer ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_gt_int }
    , /* op:gt (decimal, decimal) as boolean */
      { .ns = PFns_op, .loc = "gt",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_decimal (),
                                PFty_xs_decimal () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_gt_dec }
    , /* op:gt (decimal?, decimal?) as boolean? */
      { .ns = PFns_op, .loc = "gt",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_decimal ()),
                                PFty_opt (PFty_xs_decimal ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_gt_dec }
    , /* op:gt (double, double) as boolean */
      { .ns = PFns_op, .loc = "gt",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_double (),
                                PFty_xs_double () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_gt_dbl }
    , /* op:gt (double?, double?) as boolean? */
      { .ns = PFns_op, .loc = "gt",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_double ()),
                                PFty_opt (PFty_xs_double ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_gt_dbl }
    , /* op:gt (boolean, boolean) as boolean */
      { .ns = PFns_op, .loc = "gt",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_boolean (),
                                PFty_xs_boolean () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_gt_bln }
    , /* op:gt (boolean?, boolean?) as boolean? */
      { .ns = PFns_op, .loc = "gt",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_boolean ()),
                                PFty_opt (PFty_xs_boolean ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_gt_bln }
    , /* op:gt (string, string) as boolean */
      { .ns = PFns_op, .loc = "gt",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_string (),
                                PFty_xs_string () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_gt_str }
    , /* op:gt (string?, string?) as boolean? */
      { .ns = PFns_op, .loc = "gt",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()),
                                PFty_opt (PFty_xs_string ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_gt_str }

    , /* op:ge (integer, integer) as boolean */
      { .ns = PFns_op, .loc = "ge",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_integer (),
                                PFty_xs_integer () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_ge_int }
    , /* op:ge (integer?, integer?) as boolean? */
      { .ns = PFns_op, .loc = "ge",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_integer ()),
                                PFty_opt (PFty_xs_integer ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_ge_int }
    , /* op:ge (decimal, decimal) as boolean */
      { .ns = PFns_op, .loc = "ge",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_decimal (),
                                PFty_xs_decimal () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_ge_dec }
    , /* op:ge (decimal?, decimal?) as boolean? */
      { .ns = PFns_op, .loc = "ge",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_decimal ()),
                                PFty_opt (PFty_xs_decimal ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_ge_dec }
    , /* op:ge (double, double) as boolean */
      { .ns = PFns_op, .loc = "ge",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_double (),
                                PFty_xs_double () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_ge_dbl }
    , /* op:ge (double?, double?) as boolean? */
      { .ns = PFns_op, .loc = "ge",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_double ()),
                                PFty_opt (PFty_xs_double ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_ge_dbl }
    , /* op:ge (boolean, boolean) as boolean */
      { .ns = PFns_op, .loc = "ge",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_boolean (),
                                PFty_xs_boolean () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_ge_bln }
    , /* op:ge (boolean?, boolean?) as boolean? */
      { .ns = PFns_op, .loc = "ge",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_boolean ()),
                                PFty_opt (PFty_xs_boolean ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_ge_bln }
    , /* op:ge (string, string) as boolean */
      { .ns = PFns_op, .loc = "ge",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_string (),
                                PFty_xs_string () },
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_ge_str }
    , /* op:ge (string?, string?) as boolean? */
      { .ns = PFns_op, .loc = "ge",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()),
                                PFty_opt (PFty_xs_string ()) },
            .ret_ty = PFty_opt (PFty_xs_boolean ()) } },
        .alg = PFbui_op_ge_str }


    , /* fn:count (item*) as integer */
      { .ns = PFns_fn, .loc = "count",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_item ()) },
            .ret_ty = PFty_xs_integer () } },
        .alg = PFbui_fn_count }
    /* untypedAtomic needs to be casted into double therefore */
    /* fn:max (double*) is the last entry for fn:max */
    , /* fn:avg (double*) as double */
      { .ns = PFns_fn, .loc = "avg",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_xs_double ()) },
            .ret_ty = PFty_xs_double () } },
        .alg = PFbui_fn_avg }
    , /* fn:max (string*) as string */
      { .ns = PFns_fn, .loc = "max",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_xs_string ()) },
            .ret_ty = PFty_xs_string () } },
        .alg = PFbui_fn_max_str }
    , /* fn:max (integer*) as integer */
      { .ns = PFns_fn, .loc = "max",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_xs_integer ()) },
            .ret_ty = PFty_xs_integer () } },
        .alg = PFbui_fn_max_int }
    , /* fn:max (decimal*) as decimal */
      { .ns = PFns_fn, .loc = "max",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_xs_decimal ()) },
            .ret_ty = PFty_xs_decimal () } },
        .alg = PFbui_fn_max_dec }
    , /* fn:max (double*) as double */
      { .ns = PFns_fn, .loc = "max",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_xs_double ()) },
            .ret_ty = PFty_xs_double () } },
        .alg = PFbui_fn_max_dbl }
    , /* fn:min (string*) as string */
      { .ns = PFns_fn, .loc = "min",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_xs_string ()) },
            .ret_ty = PFty_xs_string () } },
        .alg = PFbui_fn_min_str }
    , /* fn:min (integer*) as integer */
      { .ns = PFns_fn, .loc = "min",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_xs_integer ()) },
            .ret_ty = PFty_xs_integer () } },
        .alg = PFbui_fn_min_int }
    , /* fn:min (decimal*) as decimal */
      { .ns = PFns_fn, .loc = "min",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_xs_decimal ()) },
            .ret_ty = PFty_xs_decimal () } },
        .alg = PFbui_fn_min_dec }
    , /* fn:min (double*) as double */
      { .ns = PFns_fn, .loc = "min",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_xs_double ()) },
            .ret_ty = PFty_xs_double () } },
        .alg = PFbui_fn_min_dbl }
    , /* fn:sum (integer*) as integer */
      { .ns = PFns_fn, .loc = "sum",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_xs_integer ()) },
            .ret_ty = PFty_xs_integer () } },
        .alg = PFbui_fn_sum_int }
    , /* fn:sum (decimal*) as decimal */
      { .ns = PFns_fn, .loc = "sum",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_xs_decimal ()) },
            .ret_ty = PFty_xs_decimal () } },
        .alg = PFbui_fn_sum_dec }
    , /* fn:sum (double*) as double */
      { .ns = PFns_fn, .loc = "sum",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_xs_double ()) },
            .ret_ty = PFty_xs_double () } },
        .alg = PFbui_fn_sum_dbl }
    , /* fn:sum (integer*, integer?) as integer */
      { .ns = PFns_fn, .loc = "sum",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_xs_integer ()),
                                PFty_opt (PFty_xs_integer ()) },
            .ret_ty = PFty_xs_integer () } },
        .alg = PFbui_fn_sum_zero_int }
    , /* fn:sum (decimal*, decimal?) as decimal */
      { .ns = PFns_fn, .loc = "sum",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_xs_decimal ()),
                                PFty_opt (PFty_xs_decimal ()) },
            .ret_ty = PFty_xs_decimal () } },
        .alg = PFbui_fn_sum_zero_dec }
    , /* fn:sum (double*, double?) as double */
      { .ns = PFns_fn, .loc = "sum",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_xs_double ()),
                                PFty_opt (PFty_xs_double ()) },
            .ret_ty = PFty_xs_double () } },
        .alg = PFbui_fn_sum_zero_dbl }
    , /* fn:abs (integer?) as integer? */
      { .ns = PFns_fn, .loc = "abs",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_integer ()) },
            .ret_ty = PFty_opt (PFty_xs_integer ()) } } }
    , /* fn:abs (decimal?) as decimal? */
      { .ns = PFns_fn, .loc = "abs",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_decimal ()) },
            .ret_ty = PFty_opt (PFty_xs_decimal ()) } } }
    , /* fn:abs (double?) as double? */
      { .ns = PFns_fn, .loc = "abs",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_double ()) },
            .ret_ty = PFty_opt (PFty_xs_double ()) } } }
    , /* fn:ceiling (integer?) as integer? */
      { .ns = PFns_fn, .loc = "ceiling",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_integer ()) },
            .ret_ty = PFty_opt (PFty_xs_integer ()) } } }
    , /* fn:ceiling (decimal?) as decimal? */
      { .ns = PFns_fn, .loc = "ceiling",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_decimal ()) },
            .ret_ty = PFty_opt (PFty_xs_decimal ()) } } }
    , /* fn:ceiling (double?) as double? */
      { .ns = PFns_fn, .loc = "ceiling",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_double ()) },
            .ret_ty = PFty_opt (PFty_xs_double ()) } } }
    , /* fn:floor (integer?) as integer? */
      { .ns = PFns_fn, .loc = "floor",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_integer ()) },
            .ret_ty = PFty_opt (PFty_xs_integer ()) } } }
    , /* fn:floor (decimal?) as decimal? */
      { .ns = PFns_fn, .loc = "floor",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_decimal ()) },
            .ret_ty = PFty_opt (PFty_xs_decimal ()) } } }
    , /* fn:floor (double?) as double? */
      { .ns = PFns_fn, .loc = "floor",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_double ()) },
            .ret_ty = PFty_opt (PFty_xs_double ()) } } }
    , /* fn:round (integer?) as integer? */
      { .ns = PFns_fn, .loc = "round",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_integer ()) },
            .ret_ty = PFty_opt (PFty_xs_integer ()) } } }
    , /* fn:round (decimal?) as decimal? */
      { .ns = PFns_fn, .loc = "round",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_decimal ()) },
            .ret_ty = PFty_opt (PFty_xs_decimal ()) } } }
    , /* fn:round (double?) as double? */
      { .ns = PFns_fn, .loc = "round",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_double ()) },
            .ret_ty = PFty_opt (PFty_xs_double ()) } } }
    , /* op:plus (integer, integer) as integer */
      { .ns = PFns_op, .loc = "plus",
        .arity = 2, .sig_count = 6, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_integer (),
                                   PFty_xs_integer () },
            .ret_ty = PFty_xs_integer () }, {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_integer ()),
                                   PFty_opt (PFty_xs_integer ()) },
            .ret_ty = PFty_opt (PFty_xs_integer ()) }, {
            .par_ty = (PFty_t[]) { PFty_xs_decimal (),
                                PFty_xs_decimal () },
            .ret_ty = PFty_xs_decimal () }, {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_decimal ()),
                                   PFty_opt (PFty_xs_decimal ()) },
            .ret_ty = PFty_opt (PFty_xs_decimal ()) }, {
            .par_ty = (PFty_t[]) { PFty_xs_double (),
                                   PFty_xs_double () },
            .ret_ty = PFty_xs_double () }, {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_double ()),
                                   PFty_opt (PFty_xs_double ()) },
            .ret_ty = PFty_opt (PFty_xs_double ()) } },
        .alg = PFbui_op_numeric_add }
    , /* op:minus (integer, integer) as integer */
      { .ns = PFns_op, .loc = "minus",
        .arity = 2, .sig_count = 6, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_integer (),
                                   PFty_xs_integer () },
            .ret_ty = PFty_xs_integer () }, {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_integer ()),
                                   PFty_opt (PFty_xs_integer ()) },
            .ret_ty = PFty_opt (PFty_xs_integer ()) }, {
            .par_ty = (PFty_t[]) { PFty_xs_decimal (),
                                PFty_xs_decimal () },
            .ret_ty = PFty_xs_decimal () }, {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_decimal ()),
                                   PFty_opt (PFty_xs_decimal ()) },
            .ret_ty = PFty_opt (PFty_xs_decimal ()) }, {
            .par_ty = (PFty_t[]) { PFty_xs_double (),
                                   PFty_xs_double () },
            .ret_ty = PFty_xs_double () }, {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_double ()),
                                   PFty_opt (PFty_xs_double ()) },
            .ret_ty = PFty_opt (PFty_xs_double ()) } },
        .alg = PFbui_op_numeric_subtract }
    , /* op:times (integer, integer) as integer */
      { .ns = PFns_op, .loc = "times",
        .arity = 2, .sig_count = 6, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_integer (),
                                   PFty_xs_integer () },
            .ret_ty = PFty_xs_integer () }, {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_integer ()),
                                   PFty_opt (PFty_xs_integer ()) },
            .ret_ty = PFty_opt (PFty_xs_integer ()) }, {
            .par_ty = (PFty_t[]) { PFty_xs_decimal (),
                                PFty_xs_decimal () },
            .ret_ty = PFty_xs_decimal () }, {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_decimal ()),
                                   PFty_opt (PFty_xs_decimal ()) },
            .ret_ty = PFty_opt (PFty_xs_decimal ()) }, {
            .par_ty = (PFty_t[]) { PFty_xs_double (),
                                   PFty_xs_double () },
            .ret_ty = PFty_xs_double () }, {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_double ()),
                                   PFty_opt (PFty_xs_double ()) },
            .ret_ty = PFty_opt (PFty_xs_double ()) } },
        .alg = PFbui_op_numeric_multiply }

    , /* op:div (decimal, decimal) as decimal */
      { .ns = PFns_op, .loc = "div",
        .arity = 2, .sig_count = 4, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_decimal (),
                                PFty_xs_decimal () },
            .ret_ty = PFty_xs_decimal () }, {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_decimal ()),
                                   PFty_opt (PFty_xs_decimal ()) },
            .ret_ty = PFty_opt (PFty_xs_decimal ()) }, {
            .par_ty = (PFty_t[]) { PFty_xs_double (),
                                   PFty_xs_double () },
            .ret_ty = PFty_xs_double () }, {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_double ()),
                                   PFty_opt (PFty_xs_double ()) },
            .ret_ty = PFty_opt (PFty_xs_double ()) } },
        .alg = PFbui_op_numeric_divide }
    , /* op:idiv (integer, integer) as integer */
      { .ns = PFns_op, .loc = "idiv",
        .arity = 2, .sig_count = 6, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_integer (),
                                   PFty_xs_integer () },
            .ret_ty = PFty_xs_integer () }, {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_integer ()),
                                   PFty_opt (PFty_xs_integer ()) },
            .ret_ty = PFty_opt (PFty_xs_integer ()) }, {
            .par_ty = (PFty_t[]) { PFty_xs_decimal (),
                                PFty_xs_decimal () },
            .ret_ty = PFty_xs_integer () }, {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_decimal ()),
                                   PFty_opt (PFty_xs_decimal ()) },
            .ret_ty = PFty_opt (PFty_xs_integer ()) }, {
            .par_ty = (PFty_t[]) { PFty_xs_double (),
                                   PFty_xs_double () },
            .ret_ty = PFty_xs_integer () }, {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_double ()),
                                   PFty_opt (PFty_xs_double ()) },
            .ret_ty = PFty_opt (PFty_xs_integer ()) } },
        .alg = PFbui_op_numeric_idivide }
    , /* op:mod (integer, integer) as integer */
      { .ns = PFns_op, .loc = "mod",
        .arity = 2, .sig_count = 6, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_integer (),
                                   PFty_xs_integer () },
            .ret_ty = PFty_xs_integer () }, {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_integer ()),
                                   PFty_opt (PFty_xs_integer ()) },
            .ret_ty = PFty_opt (PFty_xs_integer ()) }, {
            .par_ty = (PFty_t[]) { PFty_xs_decimal (),
                                PFty_xs_decimal () },
            .ret_ty = PFty_xs_decimal () }, {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_decimal ()),
                                   PFty_opt (PFty_xs_decimal ()) },
            .ret_ty = PFty_opt (PFty_xs_decimal ()) }, {
            .par_ty = (PFty_t[]) { PFty_xs_double (),
                                   PFty_xs_double () },
            .ret_ty = PFty_xs_double () }, {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_double ()),
                                   PFty_opt (PFty_xs_double ()) },
            .ret_ty = PFty_opt (PFty_xs_double ()) } },
        .alg = PFbui_op_numeric_modulo }


      /* the return type of pf:item-sequence-to-node-sequence is          */
      /* generated using a special typing rule during typechecking        */

    , /* pf:item-sequence-to-node-sequence (atomic) as text */
      { .ns = PFns_pf, .loc = "item-sequence-to-node-sequence",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_atomic ()},
            .ret_ty = PFty_text () } },
        .alg = PFbui_pf_item_seq_to_node_seq_single_atomic }
    , /* pf:item-sequence-to-node-sequence (atomic*) as text */
      { .ns = PFns_pf, .loc = "item-sequence-to-node-sequence",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_atomic ())},
            .ret_ty = PFty_text () } },
        .alg = PFbui_pf_item_seq_to_node_seq_atomic }
    , /* pf:item-sequence-to-node-sequence (attr*, atomic) as node* */
      { .ns = PFns_pf, .loc = "item-sequence-to-node-sequence",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_seq (
                                        PFty_star (PFty_xs_anyAttribute ()),
                                        PFty_atomic ())},
            .ret_ty = PFty_star (PFty_node ()) } },
        .alg = PFbui_pf_item_seq_to_node_seq_attr_single }
    , /* pf:item-sequence-to-node-sequence (attr*, atomic*) as node* */
      { .ns = PFns_pf, .loc = "item-sequence-to-node-sequence",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (
                                    PFty_choice (
                                        PFty_atomic (),
                                        PFty_xs_anyAttribute ()))},
            .ret_ty = PFty_star (PFty_node ()) } },
        .alg = PFbui_pf_item_seq_to_node_seq_attr }
    , /* pf:item-sequence-to-node-sequence (item*) as node* */
      { .ns = PFns_pf, .loc = "item-sequence-to-node-sequence",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (
                                    PFty_choice (
                                        PFty_xs_anyElement (),
                                        PFty_choice (
                                            PFty_doc (PFty_xs_anyType ()),
                                            PFty_choice (
                                                PFty_text (),
                                                PFty_choice (
                                                    PFty_pi (NULL),
                                                    PFty_choice (
                                                        PFty_atomic (),
                                                        PFty_comm ()))))))},
            .ret_ty = PFty_star (PFty_node ()) } },
        .alg = PFbui_pf_item_seq_to_node_seq_wo_attr }
    , /* pf:item-sequence-to-node-sequence (item*) as node* */
      { .ns = PFns_pf, .loc = "item-sequence-to-node-sequence",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_item ())},
            .ret_ty = PFty_star (PFty_node ()) } },
        .alg = PFbui_pf_item_seq_to_node_seq }
      /* FIXME:                                                     */
      /*   The W3C specs describe variants of is2uA for each node   */
      /*   (with differences in the empty sequence handling).       */
    , /* pf:item-sequence-to-untypedAtomic (item*) as untypedAtomic */
      { .ns = PFns_pf, .loc = "item-sequence-to-untypedAtomic",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_item ())},
            .ret_ty = PFty_untypedAtomic () } } }
    , /* pf:merge-adjacent-text-nodes (node*) as node* */
      { .ns = PFns_pf, .loc = "merge-adjacent-text-nodes",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_node ())},
            .ret_ty = PFty_star (PFty_node ()) } },
        .alg = PFbui_pf_merge_adjacent_text_nodes }

    , /* fn:resolve-QName (xs:string) as xs:QName */
      /* Note that we're off the specs here.  Refer to fs.brg for
       * details (computed element construction). */
      { .ns = PFns_fn, .loc = "resolve-QName",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t []) { PFty_xs_string () },
            .ret_ty = PFty_xs_QName () } },
        .alg = PFbui_fn_resolve_qname }

      /* FIXME: distinct-values should be changed to anyAtomicType* */
    , /* fn:distinct-values (atomic*) as atomic* */
      { .ns = PFns_fn, .loc = "distinct-values",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_atomic ())},
            .ret_ty = PFty_star (PFty_untypedAtomic ()) } },
        .alg = PFbui_fn_distinct_values }
    , /* op:is-same-node (node, node) as boolean */
      { .ns = PFns_op, .loc = "is-same-node",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_node (),
                                PFty_node ()},
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_is_same_node }
    , /* op:node-before (node, node) as boolean */
      { .ns = PFns_op, .loc = "node-before",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_node (),
                                PFty_node ()},
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_node_before }
    , /* op:node-after (node, node) as boolean */
      { .ns = PFns_op, .loc = "node-after",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_node (),
                                PFty_node ()},
            .ret_ty = PFty_xs_boolean () } },
        .alg = PFbui_op_node_after }
    , /* op:union (node*, node*) as node* */
      { .ns = PFns_op, .loc = "union",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_node ()),
                                PFty_star (PFty_node ()) },
            .ret_ty = PFty_star (PFty_node ()) } },
        .alg = PFbui_op_union }
    , /* op:intersect (node*, node*) as node* */
      { .ns = PFns_op, .loc = "intersect",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_node ()),
                                PFty_star (PFty_node ()) },
            .ret_ty = PFty_star (PFty_node ()) } },
        .alg = PFbui_op_intersect }
    , /* op:except (node*, node*) as node* */
      { .ns = PFns_op, .loc = "except",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_node ()),
                                PFty_star (PFty_node ()) },
            .ret_ty = PFty_star (PFty_node ()) } },
        .alg = PFbui_op_except }
    , /* op:to (integer, integer) as integer* */
      { .ns = PFns_op, .loc = "to",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_integer (), PFty_xs_integer () },
            .ret_ty = PFty_star (PFty_xs_integer ()) } } }
    , /* pf:typed-value (node) as untypedAtomic* */
      { .ns = PFns_pf, .loc = "typed-value",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_node () },
            .ret_ty = PFty_star (PFty_untypedAtomic ()) } },
        /* FIXME: does this still fit or is it string-value? */
        .alg = PFbui_pf_typed_value }
    , /* pf:string-value (attribute) as string */
      { .ns = PFns_pf, .loc = "string-value",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_anyAttribute () },
            .ret_ty = PFty_xs_string () } },
        .alg = PFbui_pf_string_value_attr }
    , /* pf:string-value (text) as string */
      { .ns = PFns_pf, .loc = "string-value",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_text () },
            .ret_ty = PFty_xs_string () } },
        .alg = PFbui_pf_string_value_text }
    , /* pf:string-value (processing-instruction) as string */
      { .ns = PFns_pf, .loc = "string-value",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_pi (NULL) },
            .ret_ty = PFty_xs_string () } },
        .alg = PFbui_pf_string_value_pi }
    , /* pf:string-value (comment) as string */
      { .ns = PFns_pf, .loc = "string-value",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_comm () },
            .ret_ty = PFty_xs_string () } },
        .alg = PFbui_pf_string_value_comm }
    , /* pf:string-value (elem) as string */
      { .ns = PFns_pf, .loc = "string-value",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_choice (
                                    PFty_xs_anyElement (),
                                    PFty_choice (
                                        PFty_text (),
                                        PFty_doc (PFty_xs_anyType ()))) },
            .ret_ty = PFty_xs_string () } },
        .alg = PFbui_pf_string_value_elem }
    , /* pf:string-value (elem, attr) as string */
      { .ns = PFns_pf, .loc = "string-value",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_choice (
                                    PFty_xs_anyElement (),
                                    PFty_choice (
                                        PFty_doc (PFty_xs_anyType ()),
                                        PFty_choice (
                                            PFty_text (),
                                            PFty_xs_anyAttribute ()))) },
            .ret_ty = PFty_xs_string () } },
        .alg = PFbui_pf_string_value_elem_attr }
    , /* pf:string-value (node) as string */
      { .ns = PFns_pf, .loc = "string-value",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_node () },
            .ret_ty = PFty_xs_string () } },
        .alg = PFbui_pf_string_value }
    , /* fn:name (node) as string */
      { .ns = PFns_fn, .loc = "name",
        .arity = 0,  .sig_count = 1, .sigs = { {
            .ret_ty = PFty_xs_string () } } }
    , /* fn:name (node) as string */
      { .ns = PFns_fn, .loc = "name",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_node ()) },
            .ret_ty = PFty_xs_string () } } }
    , /* fn:local-name (node) as string */
      { .ns = PFns_fn, .loc = "local-name",
        .arity = 0,  .sig_count = 1, .sigs = { {
            .ret_ty = PFty_xs_string () } } }
    , /* fn:local-name (node) as string */
      { .ns = PFns_fn, .loc = "local-name",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_node ()) },
            .ret_ty = PFty_xs_string () } } }
    , /* fn:namespace-uri (node) as string */
      { .ns = PFns_fn, .loc = "namespace-uri",
        .arity = 0,  .sig_count = 1, .sigs = { {
            .ret_ty = PFty_xs_string () } } }
    , /* fn:namespace-uri (node) as string */
      { .ns = PFns_fn, .loc = "namespace-uri",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_node ()) },
            .ret_ty = PFty_xs_string () } } }
    , /* fn:string () as string */
      { .ns = PFns_fn, .loc = "string",
        .arity = 0, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_none () },
            .ret_ty = PFty_xs_string () } },
        .alg = PFbui_fn_string}
    , /* fn:string (item?) as string */
      { .ns = PFns_fn, .loc = "string",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_item ()) },
            .ret_ty = PFty_xs_string () } },
        .alg = PFbui_fn_string}
    , /* fn:string-join (string*, string) as string */
      { .ns = PFns_fn, .loc = "string-join",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_xs_string ()),
                                PFty_xs_string () },
            .ret_ty = PFty_xs_string () } },
        .alg = PFbui_fn_string_join}
    , /* fn:concat (string, string) as string */
      /* This is more strict that the W3C variant. Maybe we can do with */
      /* that strict variant. */
      { .ns = PFns_fn, .loc = "concat",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_string(), PFty_xs_string() },
            .ret_ty = PFty_xs_string () } },
        .alg = PFbui_fn_concat}
    , /* fn:starts-with (string?, string?) as boolean */
      { .ns = PFns_fn, .loc = "starts-with",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()),
                                PFty_opt (PFty_xs_string ()) },
            .ret_ty = PFty_xs_boolean () } } }
    , /* fn:ends-with (string?, string?) as boolean */
      { .ns = PFns_fn, .loc = "ends-with",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()),
                                PFty_opt (PFty_xs_string ()) },
            .ret_ty = PFty_xs_boolean () } } }
    , /* fn:normalize-space () as string */
      { .ns = PFns_fn, .loc = "normalize-space",
        .arity = 0,  .sig_count = 1, .sigs = { {
            .ret_ty = PFty_xs_string () } } }
    , /* fn:normalize-space (string?) as string */
      { .ns = PFns_fn, .loc = "normalize-space",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()) },
            .ret_ty = PFty_xs_string () } } }
    , /* fn:lower-case (string?) as string */
      { .ns = PFns_fn, .loc = "lower-case",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()) },
            .ret_ty = PFty_xs_string () } } }
    , /* fn:upper-case (string?) as string */
      { .ns = PFns_fn, .loc = "upper-case",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()) },
            .ret_ty = PFty_xs_string () } } }
    , /* fn:substring (string?, double) as string */
      { .ns = PFns_fn, .loc = "substring",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()),
                                PFty_xs_double () },
            .ret_ty = PFty_xs_string () } } }
    , /* fn:substring (string?, double, double) as string */
      { .ns = PFns_fn, .loc = "substring",
        .arity = 3, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()),
                                PFty_xs_double (),
                                PFty_xs_double () },
            .ret_ty = PFty_xs_string () } } }
    , /* fn:substring-before (string?, string?) as string */
      { .ns = PFns_fn, .loc = "substring-before",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()),
                                PFty_opt (PFty_xs_string ()) },
            .ret_ty = PFty_xs_string () } } }
    , /* fn:substring-after (string?, string?) as string */
      { .ns = PFns_fn, .loc = "substring-after",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()),
                                PFty_opt (PFty_xs_string ()) },
            .ret_ty = PFty_xs_string () } } }
    , /* fn:string-length () as integer */
      { .ns = PFns_fn, .loc = "string-length",
        .arity = 0, .sig_count = 1, .sigs = { {
            .ret_ty = PFty_xs_integer () } } }
    , /* fn:string-length (string?) as integer */
      { .ns = PFns_fn, .loc = "string-length",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()) },
            .ret_ty = PFty_xs_integer () } } }
    , /* fn:translate (string?, string, string) as string */
      { .ns = PFns_fn, .loc = "translate",
        .arity = 3, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()),
                                PFty_xs_string (),
                                PFty_xs_string () },
            .ret_ty = PFty_xs_string () } } }
    , /* fn:matches(string?, string) as boolean */
      { .ns = PFns_fn, .loc = "matches",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()),
                                PFty_xs_string () },
            .ret_ty = PFty_xs_boolean () } } }
    , /* fn:matches (string?, string, string) as boolean */
      { .ns = PFns_fn, .loc = "matches",
        .arity = 3, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()),
                                PFty_xs_string (),
                                PFty_xs_string () },
            .ret_ty = PFty_xs_boolean () } } }
    , /* fn:replace (string?, string, string) as string */
      { .ns = PFns_fn, .loc = "replace",
        .arity = 3, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()),
                                PFty_xs_string (),
                                PFty_xs_string () },
            .ret_ty = PFty_xs_string () } } }
    , /* fn:replace (string?, string, string, string) as string */
      { .ns = PFns_fn, .loc = "replace",
        .arity = 4, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_xs_string ()),
                                PFty_xs_string (),
                                PFty_xs_string (),
                                PFty_xs_string () },
            .ret_ty = PFty_xs_string () } } }
    , /* fn:subsequence(item*, double) as item* */
      /* Note that typecheck.brg implements a specific typing rule! */
      { .ns = PFns_fn, .loc = "subsequence",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_item ()),
                                PFty_xs_double () },
            .ret_ty = PFty_star (PFty_item ()) } } }
    , /* fn:subsequence(item*, double, double) as item* */
      /* Note that typecheck.brg implements a specific typing rule! */
      { .ns = PFns_fn, .loc = "subsequence",
        .arity = 3, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_star (PFty_item ()),
                                PFty_xs_double (),
                                PFty_xs_double () },
            .ret_ty = PFty_star (PFty_item ()) } } }
    /* Below are the function declarations for the UpdateX functions */
    ,  /* upd:rename(node, xs:QName) as stmt */
      { .ns = PFns_upd, .loc = "rename",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_node (), PFty_xs_QName () },
            .ret_ty = PFty_stmt () } } }
#if 0
    /* This signature apparently is too strict (or our static type
     * inference to coarse).  Relaxed the type of the first argument
     * for the time being (see above). */
    ,  /* upd:rename(xs:anyElement | xs:anyAttribute | p-i, xs:QName) as stmt */
      { .ns = PFns_upd, .loc = "rename",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_choice (PFty_xs_anyElement (),
                                       PFty_choice (PFty_xs_anyAttribute (),
                                                    PFty_pi (NULL))),
                                   PFty_xs_QName () },
            .ret_ty = PFty_stmt () } } }
#endif

    ,  /* upd:delete (node) as stmt */
      { .ns = PFns_upd, .loc = "delete",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_node () },
            .ret_ty = PFty_stmt () } } }

    ,  /* upd:insertIntoAsFirst ((xs:anyElement | document-node())?,
                                 node*) as stmt */
       /* FIXME: should be `elem | doc, node+', which would make
        *        trouble during type checking.                     */
      { .ns = PFns_upd, .loc = "insertIntoAsFirst",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_choice (
                                     PFty_xs_anyElement (),
                                     PFty_doc (PFty_xs_anyNode ()))),
                                   PFty_star (PFty_node ()) },
            .ret_ty = PFty_stmt () } } }

    ,  /* upd:insertIntoAsLast ((xs:anyElement | document-node())?,
                                node*) as stmt */
       /* FIXME: should be `elem | doc, node+', which would make
        *        trouble during type checking.                     */
      { .ns = PFns_upd, .loc = "insertIntoAsLast",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_opt (PFty_choice (
                                     PFty_xs_anyElement (),
                                     PFty_doc (PFty_xs_anyNode ()))),
                                   PFty_star (PFty_node ()) },
            .ret_ty = PFty_stmt () } } }

    ,  /* upd:insertBefore (node, node*) as stmt */
       /* FIXME: should be node+, which would make trouble during
        *        type checking.                                    */
      { .ns = PFns_upd, .loc = "insertBefore",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_node (),
                                   PFty_star (PFty_node ()) },
            .ret_ty = PFty_stmt () } } }

    ,  /* upd:insertAfter (node, node*) as stmt */
       /* FIXME: should be node+, which would make trouble during
        *        type checking.                                    */
      { .ns = PFns_upd, .loc = "insertAfter",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_node (),
                                   PFty_star (PFty_node ()) },
            .ret_ty = PFty_stmt () } } }

    ,  /* upd:replaceValue (xs:anyAttribute, xdt:untypedAtomic) as stmt */
      { .ns = PFns_upd, .loc = "replaceValue",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_anyAttribute (),
                                   PFty_xdt_untypedAtomic () },
            .ret_ty = PFty_stmt () } } }

    ,  /* upd:replaceValue (text(), xdt:untypedAtomic) as stmt */
      { .ns = PFns_upd, .loc = "replaceValue",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_text (),
                                   PFty_xdt_untypedAtomic () },
            .ret_ty = PFty_stmt () } } }

    ,  /* upd:replaceValue (processing-instr(), xdt:untypedAtomic) as stmt */
      { .ns = PFns_upd, .loc = "replaceValue",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_pi (NULL),
                                   PFty_xdt_untypedAtomic () },
            .ret_ty = PFty_stmt () } } }

    ,  /* upd:replaceValue (comment(), xdt:untypedAtomic) as stmt */
      { .ns = PFns_upd, .loc = "replaceValue",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_comm (),
                                   PFty_xdt_untypedAtomic () },
            .ret_ty = PFty_stmt () } } }

    ,  /* pf:add-doc (string, string) as docmgmt */
      { .ns = PFns_lib, .loc = "add-doc",
        .arity = 2, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_string (),
                                   PFty_xs_string () },
            .ret_ty = PFty_docmgmt () } } }

    ,  /* pf:add-doc (string, string, string) as docmgmt */
      { .ns = PFns_lib, .loc = "add-doc",
        .arity = 3, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_string (),
                                   PFty_xs_string (),
                                   PFty_xs_string () },
            .ret_ty = PFty_docmgmt () } } }

    ,  /* pf:add-doc (string, string, int) as docmgmt */
      { .ns = PFns_lib, .loc = "add-doc",
        .arity = 3, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_string (),
                                   PFty_xs_string (),
                                   PFty_xs_integer() },
            .ret_ty = PFty_docmgmt () } } }

    ,  /* pf:add-doc (string, string, string, int) as docmgmt */
      { .ns = PFns_lib, .loc = "add-doc",
        .arity = 4, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_string (),
                                   PFty_xs_string (),
                                   PFty_xs_string (),
                                   PFty_xs_integer() },
            .ret_ty = PFty_docmgmt () } } }

    ,  /* pf:del-doc (string) as docmgmt */
      { .ns = PFns_lib, .loc = "del-doc",
        .arity = 1, .sig_count = 1, .sigs = { {
            .par_ty = (PFty_t[]) { PFty_xs_string () },
            .ret_ty = PFty_docmgmt () } } }

#ifdef HAVE_PFTIJAH
    , /* pf:tijah-command(string*) as boolean */
      { .ns = PFns_lib, .loc = "tijah-command",
        .arity = 1, .sig_count = 1, .sigs = { {
	     .par_ty = (PFty_t[]) { PFty_star (PFty_xs_string ()) },
             .ret_ty = PFty_xs_boolean () } } }
    , /* pf:tijah-query-id(item*, string) as integer */
      { .ns = PFns_lib, .loc = "tijah-query-id",
        .arity = 2, .sig_count = 1, .sigs = { {
	     .par_ty = (PFty_t[]) { PFty_star (PFty_xs_anyNode ()),
                                    PFty_xs_string () },
             .ret_ty = PFty_xs_integer () },
	     } }
    , /* pf:tijah-query-id(item, item*, string) as integer */
      { .ns = PFns_lib, .loc = "tijah-query-id",
        .arity = 3, .sig_count = 1, .sigs = { {
	     .par_ty = (PFty_t[]) { PFty_xs_anyNode (),
	     			    PFty_star (PFty_xs_anyNode ()),
                                    PFty_xs_string () },
             .ret_ty = PFty_xs_integer () },
	     } }
    , /* pf:tijah-query(item*, string) as node* */
      { .ns = PFns_lib, .loc = "tijah-query",
        .arity = 2, .sig_count = 1, .sigs = { {
	     .par_ty = (PFty_t[]) { PFty_star (PFty_xs_anyNode ()),
                                    PFty_xs_string () },
             .ret_ty = PFty_star (PFty_xs_anyNode ()) },
	     } }
    , /* pf:tijah-query(item, item*, string) as node* */
      { .ns = PFns_lib, .loc = "tijah-query",
        .arity = 3, .sig_count = 1, .sigs = { {
	     .par_ty = (PFty_t[]) { PFty_xs_anyNode (),
	     			    PFty_star (PFty_xs_anyNode ()),
                                    PFty_xs_string () },
             .ret_ty = PFty_star (PFty_xs_anyNode ()) },
	     } }
    , /* pf:tijah-nodes(integer) as node* */
      { .ns = PFns_lib, .loc = "tijah-nodes",
        .arity = 1, .sig_count = 1, .sigs = { {
	     .par_ty = (PFty_t[]) { PFty_xs_integer () },
             .ret_ty = PFty_star (PFty_xs_anyNode ()) } } }
    , /* pf:tijah-score(integer, node) as double */
      { .ns = PFns_lib, .loc = "tijah-score",
        .arity = 2, .sig_count = 1, .sigs = { {
	     .par_ty = (PFty_t[]) { PFty_xs_integer (),
	                            PFty_xs_anyNode () },
             .ret_ty = PFty_xs_double () } } }
    , /* pf:tijah-tokenize(string?) as string */
      { .ns = PFns_lib, .loc = "tijah-tokenize",
        .arity = 1, .sig_count = 1, .sigs = { {
	     .par_ty = (PFty_t[]) { PFty_xs_string () },
             .ret_ty = PFty_xs_string () } } }
#endif
    , { .loc = 0 }
    };

    PFqname_t    qn;
    unsigned int n;

    PFfun_env = PFenv ();

    for (n = 0; xquery_fo[n].loc; n++) {
        assert (xquery_fo[n].sig_count <= XQUERY_FO_MAX_SIGS);

        /* construct function name */
        qn = PFqname (xquery_fo[n].ns, xquery_fo[n].loc);

        /* insert built-in XQuery F&O into function environment */
        PFenv_bind (PFfun_env,
                    qn,
                    (void *) PFfun_new (qn,
                                        xquery_fo[n].arity,
                                        true,
                                        xquery_fo[n].sig_count,
                                        xquery_fo[n].sigs,
                                        xquery_fo[n].alg,
                                        NULL));
    }
}

/* vim:set shiftwidth=4 expandtab: */
