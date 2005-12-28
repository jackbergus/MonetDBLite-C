module namespace xmark = "http://www.cwi.nl/~boncz/xmark/mod/";

declare function xmark:convert($v as xs:decimal?) as xs:decimal?
{
  2.20371 * $v (: convert Dfl to Euro :)
};

declare function xmark:q01($doc as xs:string, $id as xs:string) as xs:anyNode*
{
  let $auction := doc($doc)
  for $b in $auction/site/people/person[@id=$id]
  return $b/name/text()
};

declare function xmark:q02($doc as xs:string) as xs:anyNode*
{
  let $auction := doc($doc)
  for $b in $auction/site/open_auctions/open_auction
  return <increase> { $b/bidder[1]/increase/text() } </increase>
};

declare function xmark:q03($doc as xs:string) as xs:anyNode* 
{
  let $auction := doc($doc)
  for $b in $auction/site/open_auctions/open_auction
  where exactly-one($b/bidder[1]/increase/text()) * 2 <= $b/bidder[last()]/increase/text()
  return <increase first="{ $b/bidder[1]/increase/text() }"
                   last="{ $b/bidder[last()]/increase/text() }"/>

};

declare function xmark:q04($doc as xs:string, $person1 as xs:string, $person2 as xs:string) as xs:anyNode*
{
  let $auction := doc($doc)
  for $b in $auction/site/open_auctions/open_auction
  where some $pr1 in $b/bidder/personref[@person=$person1],
             $pr2 in $b/bidder/personref[@person=$person2] satisfies $pr1 << $pr2
  return <history> { $b/reserve/text() } </history>
};

declare function xmark:q05($doc as xs:string, $min as xs:double) as xs:integer
{
  let $auction := doc($doc)
  return
  count(for $i in $auction/site/closed_auctions/closed_auction
        where  $i/price/text() >= $min
        return $i/price)
};

declare function xmark:q06($doc as xs:string) as xs:integer*
{
  let $auction := doc($doc)
  for $b in $auction//site/regions
  return count($b//item)
};

declare function xmark:q07($doc as xs:string) as xs:integer*
{
  let $auction := doc($doc)
  for $p in $auction/site
  return count($p//description) + count($p//annotation) + count($p//emailaddress)
};

declare function xmark:q08($doc as xs:string) as xs:anyNode*
{
  let $auction := doc($doc)
  for $p in $auction/site/people/person
  let $a := for $t in $auction/site/closed_auctions/closed_auction
            where $t/buyer/@person = $p/@id
            return $t
  return <item person="{ $p/name/text() }"> { count($a) } </item>
};

declare function xmark:q09($doc as xs:string) as xs:anyNode*
{
  let $auction := doc($doc)
  let $ca := $auction/site/closed_auctions/closed_auction
  let $ei := $auction/site/regions/europe/item
  for $p in $auction/site/people/person
  let $a :=
    for $t in $ca
    where $p/@id = $t/buyer/@person
    return
    let $n :=
    for $t2 in $ei
      where $t/itemref/@item = $t2/@id
      return $t2
    return <item>{$n/name/text()}</item>
  return <person name="{$p/name/text()}">{$a}</person>
};

declare function xmark:q10($doc as xs:string) as xs:anyNode*
{
  let $auction := doc($doc)
  for $i in distinct-values($auction/site/people/person/profile/interest/@category)
  let $p := 
    for $t in $auction/site/people/person
    where $t/profile/interest/@category = $i
    return <personne>
  <statistiques>
    <sexe> { $t/profile/gender/text() } </sexe>
    <age> { $t/profile/age/text() } </age>
    <education> { $t/profile/education/text() } </education>
    <revenu> { fn:data($t/profile/@income) } </revenu>
  </statistiques>
  <coordonnees>
    <nom> { $t/name/text() } </nom>
    <rue> { $t/address/street/text() } </rue>
    <ville> { $t/address/city/text() } </ville>
    <pays> { $t/address/country/text() } </pays>
    <reseau>
      <courrier> { $t/emailaddress/text() } </courrier>
      <pagePerso> { $t/homepage/text() } </pagePerso>
    </reseau>
  </coordonnees>
  <cartePaiement> { $t/creditcard/text() } </cartePaiement>
</personne>
  return <categorie>
  <id> { $i } </id>
  { $p }
</categorie>
};

declare function xmark:q11($doc as xs:string, $factor as xs:integer) as xs:anyNode*
{
  let $auction := doc($doc)
  for $p in $auction/site/people/person
  let $l := for $i in $auction/site/open_auctions/open_auction/initial
            where $p/profile/@income > ($factor * exactly-one($i/text()))
            return $i
  return <items name="{ $p/name/text() }"> { count($l) } </items>
};

declare function xmark:q12($doc as xs:string, $factor as xs:integer, $min as xs:double) as xs:anyNode*
{
  let $auction := doc($doc)
  for $p in $auction/site/people/person
  let $l := for $i in $auction/site/open_auctions/open_auction/initial
            where $p/profile/@income > ($factor * exactly-one($i/text()))
            return $i
  where  $p/profile/@income > $min 
  return <items person="{ $p/profile/@income }"> { count($l) } </items>
};

declare function xmark:q13($doc as xs:string) as xs:anyNode*
{
  let $auction := doc($doc)
  for $i in $auction/site/regions/australia/item
  return <item name="{ $i/name/text() }"> { $i/description } </item>
};

declare function xmark:q14($doc as xs:string, $kind as xs:string) as xs:anyNode*
{
  let $auction := doc($doc)
  for $i in $auction/site//item
  where contains(string(exactly-one($i/description)),$kind)
  return $i/name/text()
};

declare function xmark:q15($doc as xs:string) as xs:anyNode*
{
  let $auction := doc($doc)
  for $a in $auction/site/closed_auctions/closed_auction/annotation/description/parlist/listitem/parlist/listitem/text/emph/keyword/text()
   return <text> { $a } </text>
};

declare function xmark:q16($doc as xs:string) as xs:anyNode*
{
  let $auction := doc($doc)
  for $a in $auction/site/closed_auctions/closed_auction
  where not(empty($a/annotation/description/parlist/listitem/parlist/listitem/text/emph/keyword/text()))
  return <person id="{ $a/seller/@person }"/>
};

declare function xmark:q17($doc as xs:string) as xs:anyNode*
{
  let $auction := doc($doc)
  for $p in $auction/site/people/person
  where empty($p/homepage/text())
  return <person name="{ $p/name/text() }"/>
};

declare function xmark:q18($doc as xs:string) as xs:decimal*
{
  let $auction := doc($doc)
  for $i in $auction/site/open_auctions/open_auction
  return xmark:convert(fn:zero-or-one($i/reserve))
};

declare function xmark:q19($doc as xs:string) as xs:anyNode*
{
  let $auction := doc($doc)
  for $b in $auction/site/regions//item
  let $k := $b/name/text()
  order by zero-or-one($b/location)
  return <item name="{ $k }"> { $b/location/text() } </item>
};

declare function xmark:q20($doc as xs:string, $lo as xs:double, $hi as xs:double) as xs:anyNode*
{
  let $auction := doc($doc)
  return <result>
  <preferred>
    { count($auction/site/people/person/profile[@income >= $hi]) }
  </preferred>
  <standard>
    { count($auction/site/people/person/profile[@income < $hi and @income >= $lo]) }
  </standard>
  <challenge>
    { count($auction/site/people/person/profile[@income < $lo]) }
  </challenge>
  <na>
    { count(for $p in $auction/site/people/person
            where empty($p/profile/@income)
            return $p) }
  </na>
</result>
};
