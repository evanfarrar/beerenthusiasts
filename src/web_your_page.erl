-module (web_your_page).
-include ("wf.inc").
-export ([main/0, event/1]).

main () ->    
    {ok, Results, _} = rfc4627:decode(couchdb_util:doc_get_all (wf:user())),
    %io:format ("~w~n", [Results]),
    case Results of
        {obj,[{"total_rows",_TotalRows},
              {"offset", _Offset},
              {"rows",
               Recipes}]} ->
            Links = create_links (Recipes);
        {obj,[{"total_rows",_TotalRows},
              {"rows",
               Recipes}]} ->
            Links = create_links (Recipes)
    end,
    io:format ("~w~n", [Links]),
    Body = #body { body=#panel { style="margin: 50px;", 
                                 body=["Your Recipes:",
                                       #br{},
                                       %Links,
                                       #flash { id=flash },
                                       #panel { id=test }
                                      ]}},
    wf:render(Body).

event (_) ->
    ok.
 
create_links (Recipes) ->
    [wf:update(test, #link { text=ID, url="view_doc?user="++ wf:user() ++"&doc_id="++ID}) 
     || {obj, [{"id", ID},
               {"key", Key},
               {"value", {obj,[{"rev", Rev}]}}]} <- Recipes].                         

