-module (web_view_doc).
-include ("wf.inc").
-export ([main/0, event/1]).

main () ->    
    case wf:user() of        
        undefined ->
            Header = "new_user_header";
        _ ->
            Header = "user_header",
            ok
    end,
    

    DocId = wf:q (doc_id),
    User = wf:q (user),
    Doc = rfc4627:encode(couchdb_util:doc_get (User, DocId)),

    Template = #template {file="main_template", title="View Recipe",
                          section1 = #panel { style="margin: 50px;", 
                                              body=[
                                                    #file { file=Header },     
                                                    "Recipe:",
                                                    #br{},
                                                    Doc,
                                                    #flash { id=flash },
                                                    #panel { id=test }
                                      ]}},
    wf:render(Template).

event (_) ->
    ok.
 
