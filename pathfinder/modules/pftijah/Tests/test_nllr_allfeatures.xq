let $opt := <TijahOptions 
                ft-index="thesis" 
                ir-model="NLLR" 
                return-all="false"
                debug="0"/>

let $query := "//chapter[about(.//title,information) and about(.//title,retrieval)]//section[about(.,XML) or about(.,SGML)]"

for $n at $r in tijah:queryall($query,$opt)
return <node rank="{$r}">{$n}</node>
