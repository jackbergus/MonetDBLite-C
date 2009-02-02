let $opt := <TijahOptions 
                ft-index="thesis" 
                ir-model="LMS" 
                return-all="false"
                debug="0"/>

let $query := "//chapter[about(.,information retrieval)]//section[about(.,pathfinder)]"

for $n at $r in tijah:queryall($query,$opt)
return <node rank="{$r}">{$n}</node>
