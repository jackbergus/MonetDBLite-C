let $items := fn:subsequence(fn:doc("dataset.xml")//Asset, 1, 100)
let $assets := for $item in $items return $item cast as xs:anyNode
let $albums := $assets/parent::*
for $album in $albums
  for $asset in $album/Asset
  where $asset/TrackNr = 1
  return <Result><Album> { $album/Title }
</Album><Track> { $asset/Title } </Track></Result>
