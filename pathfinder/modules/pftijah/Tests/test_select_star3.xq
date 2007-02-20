let $opt := <TijahOptions 
                collection="thesis" 
                txtmodel_model="LMS" 
                txtmodel_returnall="false"
                debug="0"/>

let $query := "//section[about(.,information retrieval)]//*[about(.,XML)]"

for $n at $r in pf:tijah-query($opt,(),$query)
return <node rank="{$r}">{$n}</node>
