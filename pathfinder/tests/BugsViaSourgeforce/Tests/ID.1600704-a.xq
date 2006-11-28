let $d := doc("<TSTSRCDIR>/ID.1600704.xml")
let $nodes := for $i in $d//noot
              where $i/@id
              return $i
return 
element { "result" } {
    element { "count" } { count($nodes) },
    for $i in subsequence($nodes, 11, 20)
    return element { name($i) } { $i/@* } 
}
