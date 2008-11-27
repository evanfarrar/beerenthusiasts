-module (web_index).
-include ("wf.inc").
-export ([main/0, event/1]).

main () ->    
    case wf:user() of
        undefined ->
            Header = "new_user_header";
        _ ->
            Header = "user_header"
    end,

    Template = #template {file="post_template", title="Beer Enthusiasts",
                          section1 = #panel { style="margin: 50px;", 
                                             body=[
                                                   #file { file=Header },
                                                   #br{}, #br{},
                                                   #textbox { id=terms },
                                                   #br{},
                                                   "<input type=\"submit\" value=\"Search\" />",
                                                   #flash { id=flash },
                                                   #panel { id=test }
                                                  ]}},
    
    wf:render (Template).

event (_) -> 
    ok.
