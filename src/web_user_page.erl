-module (web_user_page).
-include ("wf.inc").
-export ([main/0, event/1]).

main () ->    
    User = hd(wf:q(user)),
    Recipes = couchdb_util:doc_get_all (User),    
    Body = #body { body=#panel { style="margin: 50px;", 
                                 body=[User ++ " Recipes:",
                                       #br{},
                                       %rfc4627:encode(Recipes),
                                       #flash { id=flash },
                                       #panel { id=test }
                                      ]}},
    wf:render(Body).

event (_) ->
    ok.
