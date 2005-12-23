let $auction := doc("auctionG.xml") return
for $b in $auction/site/open_auctions/open_auction
let $c := $b/bidder[1]/increase/text()
order by zero-or-one($c) descending empty least
return if ($c) then $c else -1

