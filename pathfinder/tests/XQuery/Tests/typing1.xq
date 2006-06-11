(: Semantics of `as xs:decimal':

    - Check if bound expression is subtype of xs:decimal during
      static typing.
    - Set $a's *static* type to xs:decimal.

   The *dynamic* type of $a, however, is *not* affected by the
   `as xs:decimal'.  $a (and thus the result as well) will have
   dynamic type xs:integer

   This query will not be handled correctly by the milprint_summer
   back-end.  The test, however, is a reminder to do it better in
   the algebra branch.
:)
let $a as xs:decimal := 42 return $a
