<result>
 {
    for $uid in distinct-values(doc("bids.xml")//userid)
    for $u in doc("users.xml")//user_tuple[userid = $uid]
    let $b := doc("bids.xml")//bid_tuple[userid = $uid]
    order by zero-or-one($u/userid)
    return
        <bidder>
            { $u/userid }
            { $u/name }
            <bidcount>{ count($b) }</bidcount>
            <avgbid>{ avg($b/bid) }</avgbid>
        </bidder>
  }
</result>
