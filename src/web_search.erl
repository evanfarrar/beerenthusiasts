-module (web_search).
-include ("wf.inc").
-export ([main/0, event/1]).

main () ->    
    Terms = wf:q (terms),
    Results = get_results (Terms),
    Body = #body { body=#panel { style="margin: 50px;", 
                                 body=["Results:",
                                       #br{},
                                       rfc4627:encode(Results),
                                       #flash { id=flash },
                                       #panel { id=test }
                                      ]}},
    wf:render(Body).

event (_) -> 
    ok.

get_results (_Terms) ->
    couchdb_util:doc_get_all ("kung").
