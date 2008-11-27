-module (web_view_doc).
-include ("wf.inc").
-export ([main/0, event/1]).

main () ->    
    DocId = wf:q (doc_id),
    User = wf:q (user),
    Doc = rfc4627:encode(couchdb_util:doc_get (User, DocId)),
    Body = #body { body=#panel { style="margin: 50px;", 
                                 body=["Recipe:",
                                       #br{},
                                       Doc,
                                       #flash { id=flash },
                                       #panel { id=test }
                                      ]}},
    wf:render(Body).

event (_) ->
    ok.
 
